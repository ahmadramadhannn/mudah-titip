import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/product.dart';
import '../../data/models/product_request.dart';
import '../../data/repositories/product_repository.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc(this._productRepository) : super(const ProductInitial()) {
    on<ProductsLoadRequested>(_onLoadRequested);
    on<AvailableProductsLoadRequested>(_onLoadAvailableProducts);
    on<ProductCreateRequested>(_onCreateRequested);
    on<ProductUpdateRequested>(_onUpdateRequested);
    on<ProductDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
    ProductsLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final products = await _productRepository.getMyProducts();
      emit(ProductLoadSuccess(products));
    } on Failure catch (e) {
      emit(ProductFailure(e.message));
    }
  }

  Future<void> _onLoadAvailableProducts(
    AvailableProductsLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final products = await _productRepository.getAvailableProducts(
        category: event.category,
      );
      emit(ProductLoadSuccess(products));
    } on Failure catch (e) {
      emit(ProductFailure(e.message));
    }
  }

  Future<void> _onCreateRequested(
    ProductCreateRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      await _productRepository.createProduct(event.request);
      emit(const ProductOperationSuccess('Produk berhasil ditambahkan'));
      add(const ProductsLoadRequested());
    } on Failure catch (e) {
      emit(ProductFailure(e.message));
    }
  }

  Future<void> _onUpdateRequested(
    ProductUpdateRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      await _productRepository.updateProduct(event.id, event.request);
      emit(const ProductOperationSuccess('Produk berhasil diperbarui'));
      add(const ProductsLoadRequested());
    } on Failure catch (e) {
      emit(ProductFailure(e.message));
    }
  }

  Future<void> _onDeleteRequested(
    ProductDeleteRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      await _productRepository.deleteProduct(event.id);
      emit(const ProductOperationSuccess('Produk berhasil dihapus'));
      add(const ProductsLoadRequested());
    } on Failure catch (e) {
      emit(ProductFailure(e.message));
    }
  }
}
