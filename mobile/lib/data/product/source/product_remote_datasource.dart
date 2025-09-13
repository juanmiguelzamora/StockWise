import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/data/product/models/product_model.dart';

class ProductRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  ProductRemoteDataSource({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  /// GET /api/products/
  Future<List<ProductModel>> fetchProducts() async {
    final uri = Uri.parse('$baseUrl/api/products/');
    final response = await client.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body) as List<dynamic>;
      return decoded.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  /// PATCH /api/products/{sku}/ with payload: { "quantity": <int> }
  Future<ProductModel> updateQuantity(String sku, int newQuantity) async {
    final uri = Uri.parse('$baseUrl/api/products/$sku/');
    final body = json.encode({'quantity': newQuantity});
    final response = await client.patch(uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body) as Map<String, dynamic>;
      return ProductModel.fromJson(decoded);
    } else {
      throw Exception('Failed to update product: ${response.statusCode} ${response.body}');
    }
  }
}