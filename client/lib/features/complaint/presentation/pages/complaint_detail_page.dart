import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/models/complaint_model.dart';
import '../../data/repositories/complaint_repository.dart';
import '../bloc/complaint_bloc.dart';

/// Page for viewing complaint details.
class ComplaintDetailPage extends StatefulWidget {
  final int complaintId;

  const ComplaintDetailPage({super.key, required this.complaintId});

  @override
  State<ComplaintDetailPage> createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage> {
  ComplaintModel? _complaint;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadComplaint();
  }

  Future<void> _loadComplaint() async {
    try {
      final complaint = await context.read<ComplaintRepository>().getComplaint(
        widget.complaintId,
      );
      setState(() {
        _complaint = complaint;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _statusColor() {
    switch (_complaint?.status) {
      case ComplaintStatus.open:
        return Colors.orange;
      case ComplaintStatus.inReview:
        return Colors.blue;
      case ComplaintStatus.resolved:
        return Colors.green;
      case ComplaintStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showResolveDialog() {
    final resolutionController = TextEditingController();
    bool accepted = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tanggapi Keluhan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Terima'),
                      value: true,
                      groupValue: accepted,
                      onChanged: (v) => setDialogState(() => accepted = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Tolak'),
                      value: false,
                      groupValue: accepted,
                      onChanged: (v) => setDialogState(() => accepted = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resolutionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: accepted ? 'Tanggapan' : 'Alasan Penolakan',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (resolutionController.text.trim().length < 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tanggapan minimal 10 karakter'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                context.read<ComplaintBloc>().add(
                  ResolveComplaint(
                    id: widget.complaintId,
                    resolution: resolutionController.text.trim(),
                    accepted: accepted,
                  ),
                );
                _loadComplaint(); // Reload after resolving
              },
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Keluhan')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Keluhan')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error ?? 'Keluhan tidak ditemukan'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    final complaint = _complaint!;
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Keluhan'),
        actions: [
          // Show resolve button only if open and user is consignor
          if (complaint.status == ComplaintStatus.open)
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: _showResolveDialog,
              tooltip: 'Tanggapi',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _statusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: _statusColor()),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${complaint.status.displayName}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _statusColor(),
                        ),
                      ),
                      Text(
                        'Dibuat ${dateFormat.format(complaint.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Product Info
          _SectionCard(
            title: 'Produk',
            children: [
              ListTile(
                leading: const Icon(Icons.inventory_2),
                title: Text(complaint.productName),
                subtitle: Text('Toko: ${complaint.shopName}'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category & Description
          _SectionCard(
            title: 'Detail Keluhan',
            children: [
              ListTile(
                leading: const Icon(Icons.category),
                title: Text(complaint.category.displayName),
                subtitle: const Text('Kategori'),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(complaint.description),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Media
          if (complaint.mediaUrls.isNotEmpty) ...[
            _SectionCard(
              title: 'Bukti (${complaint.mediaUrls.length})',
              children: [
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    itemCount: complaint.mediaUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          complaint.mediaUrls[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Resolution
          if (complaint.resolution != null) ...[
            _SectionCard(
              title: 'Tanggapan',
              children: [
                ListTile(
                  leading: Icon(
                    complaint.status == ComplaintStatus.resolved
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: complaint.status == ComplaintStatus.resolved
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(
                    complaint.status == ComplaintStatus.resolved
                        ? 'Diterima'
                        : 'Ditolak',
                  ),
                  subtitle: complaint.resolvedAt != null
                      ? Text(dateFormat.format(complaint.resolvedAt!))
                      : null,
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(complaint.resolution!),
                ),
                if (complaint.resolvedByName != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Oleh: ${complaint.resolvedByName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}
