import 'package:mobile/domain/product/entity/product.dart';
import 'package:mobile/domain/product/repository/product_repository.dart';

class UpdateProductQuantityUseCase {
  final ProductRepository repository;
  UpdateProductQuantityUseCase(this.repository);

  Future<Product> call(String sku, int newQuantity) async {
    if (newQuantity < 0) {
      throw ArgumentError('Quantity must not be negative');
    }
    return repository.updateProductQuantity(sku, newQuantity);
  }
}