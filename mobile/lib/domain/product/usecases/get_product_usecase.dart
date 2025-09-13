import 'package:mobile/domain/product/entity/product.dart';
import 'package:mobile/domain/product/repository/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;
  GetProductsUseCase(this.repository);

  Future<List<Product>> call() async {
    return repository.getProducts();
  }
}