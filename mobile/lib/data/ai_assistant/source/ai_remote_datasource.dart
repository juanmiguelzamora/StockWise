import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/ai_response_model.dart';

class AiRemoteDataSource {
  final String baseUrl;

  AiRemoteDataSource(this.baseUrl);

  Future<AiResponseModel> askInventory(String query) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai_assistant/ask_llm/'),
      headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json', 
      },
      body: jsonEncode({'query': query}),
    );

    debugPrint("➡️ POST ${response.request?.url}");
    debugPrint("➡️ Body: ${jsonEncode({'query': query})}");
    debugPrint("⬅️ Status: ${response.statusCode}");
    debugPrint("⬅️ Response: ${response.body}");


    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return AiResponseModel.fromJson(jsonBody);
    } else {
      throw Exception('Failed to get response');
    }
  }
}