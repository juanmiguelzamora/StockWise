import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/data/inventory/models/inventory_model.dart';

const storage = FlutterSecureStorage();

abstract class InventoryRemoteDataSource {
  Future<List<InventoryModel>> getInventory();
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final String baseUrl;

  InventoryRemoteDataSourceImpl(this.baseUrl);

  Future<Map<String, String>> _getHeaders() async {
    var headers = {'Content-Type': 'application/json'};
    var token = await storage.read(key: 'access_token');
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      throw Exception('No access token found. Please log in.');
    }
    return headers;
  }

  @override
  Future<List<InventoryModel>> getInventory() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}inventory/'), // Adjusted to match Django URL
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => InventoryModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch inventory: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching inventory: $e');
    }
  }
}