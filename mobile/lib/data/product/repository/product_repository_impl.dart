import 'package:mobile/data/product/models/product_model.dart';
import 'package:mobile/data/product/source/product_remote_datasource.dart';
import 'package:mobile/domain/product/entity/product.dart';
import 'package:mobile/domain/product/repository/product_repository.dart';

/// It maps between data models and domain entities.
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Product>> getProducts() async {
    final models = await remoteDataSource.fetchProducts();
    return models.map((m) => m as Product).toList();
  }

  @override
  Future<Product> updateProductQuantity(String sku, int newQuantity) async {
    final ProductModel updated = await remoteDataSource.updateQuantity(sku, newQuantity);
    return updated;
  }
}