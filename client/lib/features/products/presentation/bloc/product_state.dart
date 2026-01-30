part of 'product_bloc.dart';

sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

final class ProductInitial extends ProductState {
  const ProductInitial();
}

final class ProductLoading extends ProductState {
  const ProductLoading();
}

final class ProductLoadSuccess extends ProductState {
  final List<Product> products;

  const ProductLoadSuccess(this.products);

  @override
  List<Object> get props => [products];
}

final class ProductOperationSuccess extends ProductState {
  final String message;

  const ProductOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

final class ProductFailure extends ProductState {
  final String message;

  const ProductFailure(this.message);

  @override
  List<Object> get props => [message];
}
