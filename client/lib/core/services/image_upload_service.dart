import 'dart:io';

import 'package:dio/dio.dart';

import '../api/api_client.dart';

/// Response from presigned URL request.
class PresignedUrlResponse {
  final String uploadUrl;
  final String publicUrl;
  final String objectKey;
  final int expiresInMinutes;

  PresignedUrlResponse({
    required this.uploadUrl,
    required this.publicUrl,
    required this.objectKey,
    required this.expiresInMinutes,
  });

  factory PresignedUrlResponse.fromJson(Map<String, dynamic> json) {
    return PresignedUrlResponse(
      uploadUrl: json['uploadUrl'] as String,
      publicUrl: json['publicUrl'] as String,
      objectKey: json['objectKey'] as String,
      expiresInMinutes: json['expiresInMinutes'] as int,
    );
  }
}

/// Service for uploading images to R2 storage via presigned URLs.
class ImageUploadService {
  final ApiClient _apiClient;

  // Separate Dio instance for direct uploads (no auth headers needed)
  final Dio _uploadDio = Dio();

  ImageUploadService(this._apiClient);

  /// Get content type from file extension.
  String _getContentType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  /// Upload an image file and return the public URL.
  ///
  /// [imageFile] - The image file to upload.
  /// [folder] - The folder/category (e.g., "products", "profiles").
  ///
  /// Returns the public URL of the uploaded image.
  Future<String> uploadImage(
    File imageFile, {
    String folder = 'products',
  }) async {
    final fileName = imageFile.path.split('/').last;
    final contentType = _getContentType(fileName);

    // 1. Get presigned URL from backend
    final presignedResponse = await _getPresignedUrl(
      fileName: fileName,
      contentType: contentType,
      folder: folder,
    );

    // 2. Upload directly to R2 using presigned URL
    await _uploadToR2(
      uploadUrl: presignedResponse.uploadUrl,
      file: imageFile,
      contentType: contentType,
    );

    // 3. Return the public URL
    return presignedResponse.publicUrl;
  }

  /// Request a presigned upload URL from the backend.
  Future<PresignedUrlResponse> _getPresignedUrl({
    required String fileName,
    required String contentType,
    required String folder,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/storage/presigned-url',
      data: {
        'fileName': fileName,
        'contentType': contentType,
        'folder': folder,
      },
    );

    return PresignedUrlResponse.fromJson(response.data!);
  }

  /// Upload file directly to R2 using presigned URL.
  Future<void> _uploadToR2({
    required String uploadUrl,
    required File file,
    required String contentType,
  }) async {
    final bytes = await file.readAsBytes();

    await _uploadDio.put(
      uploadUrl,
      data: bytes,
      options: Options(
        headers: {'Content-Type': contentType, 'Content-Length': bytes.length},
      ),
    );
  }

  /// Check if storage service is available.
  Future<bool> isStorageAvailable() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/storage/status',
      );
      return response.data?['configured'] == true;
    } catch (e) {
      return false;
    }
  }
}
