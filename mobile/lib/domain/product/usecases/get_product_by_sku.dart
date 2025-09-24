
import 'package:mobile/domain/product/entity/product.dart';
import 'package:mobile/domain/product/repository/product_repository.dart';

class GetProductBySku {
  final ProductRepository repository;

  GetProductBySku(this.repository);

  Future<Product> call(String sku) {
    return repository.getProductBySku(sku);
  }
}