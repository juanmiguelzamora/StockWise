import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/data/inventory/models/inventory_model.dart';

abstract class InventoryRemoteDataSource {
  Future<List<InventoryModel>> getInventory();
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final String baseUrl;

  InventoryRemoteDataSourceImpl(this.baseUrl);

  @override
  Future<List<InventoryModel>> getInventory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final idToken = await user.getIdToken();

    final response = await http.get(
      Uri.parse("$baseUrl/api/inventory/"),
      headers: {
        "Authorization": "Bearer $idToken",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => InventoryModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch inventory: ${response.body}");
    }
  }
}