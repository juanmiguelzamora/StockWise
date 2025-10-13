import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ai_response_model.dart';

class AiRemoteDataSource {
  final String baseUrl;
  AiRemoteDataSource(this.baseUrl);

  Future<AiResponseModel> askInventory(String query) async {
    final response = await http.post(
      Uri.parse('${baseUrl}ai/ask/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'query': query}),
    );

    if (kDebugMode) {  // IMPROVED: Use kDebugMode instead of debugPrint
      print("➡️ POST ${response.request?.url}");
      print("➡️ Body: ${jsonEncode({'query': query})}");
      print("⬅️ Status: ${response.statusCode}");
      print("⬅️ Response: ${response.body}");
    }

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return AiResponseModel.fromJson(jsonBody);
    } else {
      // IMPROVED: Parse error JSON if available
      try {
        final errorJson = jsonDecode(response.body);
        final errorMsg = errorJson['error']?['friendly_message'] ?? 'Unknown error';
        throw Exception(errorMsg);  // Custom message for BLoC
      } catch (e) {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    }
  }
}