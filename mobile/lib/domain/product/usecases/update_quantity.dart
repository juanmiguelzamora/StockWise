import 'package:mobile/domain/product/entity/product.dart';

abstract class UpdateQuantityUseCase {
  Future<Product> call(String sku, int newQuantity);
}