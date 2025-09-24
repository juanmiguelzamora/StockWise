import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/data/product/models/product_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProductRemoteDataSource {
  final String baseUrl;
  final http.Client client;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ProductRemoteDataSource({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  ///Helper: get stored JWT token
  Future<String?> _getToken() async {
    return await storage.read(key: 'access_token'); // ✅ matches AuthApiService
  }

  /// GET /api/products/
  Future<List<ProductModel>> fetchProducts() async {
    final token = await _getToken();
    final uri = Uri.parse('${baseUrl}products/');
    final response = await client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body) as List<dynamic>;
      return decoded.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode} ${response.body}');
    }
  }

  /// PATCH /api/products/{sku}/ with payload: { "quantity": int }
  Future<ProductModel> updateQuantity(String sku, int newQuantity) async {
    final token = await _getToken();
    final uri = Uri.parse('${baseUrl}products/$sku/'); 
    final body = json.encode({'quantity': newQuantity});

    final response = await client.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body) as Map<String, dynamic>;
      return ProductModel.fromJson(decoded);
    } else {
      throw Exception('Failed to update product: ${response.statusCode} ${response.body}');
    }
  }

   /// GET /api/products/{sku}/
  Future<ProductModel> fetchProductBySku(String sku) async {
    final token = await _getToken();
    final uri = Uri.parse('${baseUrl}products/$sku/');

    final response = await client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return ProductModel.fromJson(decoded);
    } else {
      throw Exception(
          'Failed to load product $sku: ${response.statusCode} ${response.body}');
    }
  }
}
