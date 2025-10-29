import 'package:mobile/domain/product/entity/product.dart';
import 'package:mobile/domain/product/repository/product_repository.dart';
import 'package:mobile/domain/product/usecases/get_product_by_sku.dart';

class GetProductBySkuImpl implements GetProductBySku {
  @override
  final ProductRepository repository;

  GetProductBySkuImpl(this.repository);

  @override
  Future<Product> call(String sku) {
    return repository.getProductBySku(sku);
  }
}