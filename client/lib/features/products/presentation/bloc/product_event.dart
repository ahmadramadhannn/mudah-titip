part of 'product_bloc.dart';

sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

final class ProductsLoadRequested extends ProductEvent {
  const ProductsLoadRequested();
}

final class ProductCreateRequested extends ProductEvent {
  final CreateProductRequest request;

  const ProductCreateRequested(this.request);

  @override
  List<Object> get props => [request];
}

final class ProductUpdateRequested extends ProductEvent {
  final String id;
  final UpdateProductRequest request;

  const ProductUpdateRequested({required this.id, required this.request});

  @override
  List<Object> get props => [id, request];
}

final class ProductDeleteRequested extends ProductEvent {
  final String id;

  const ProductDeleteRequested(this.id);

  @override
  List<Object> get props => [id];
}
