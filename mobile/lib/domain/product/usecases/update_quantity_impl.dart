
import 'package:mobile/domain/product/entity/product.dart';
import 'package:mobile/domain/product/repository/product_repository.dart';
import 'package:mobile/domain/product/usecases/update_quantity.dart';

class UpdateQuantityImpl implements UpdateQuantityUseCase {
  final ProductRepository repository;

  UpdateQuantityImpl(this.repository);

  @override
  Future<Product> call(String sku, int newQuantity) {
    return repository.updateProductQuantity(sku, newQuantity);
  }
}