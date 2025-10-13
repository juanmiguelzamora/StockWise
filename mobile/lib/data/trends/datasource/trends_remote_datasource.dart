import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/data/trends/models/trend_model.dart';

abstract class TrendsRemoteDataSource {
  Future<List<TrendModel>> getTrends(String season);
  Future<List<String>> getPredictions(int topN);
  Future<List<TrendModel>> runScraper();
}

class TrendsRemoteDataSourceImpl implements TrendsRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  TrendsRemoteDataSourceImpl({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<List<TrendModel>> getTrends(String season) async {
    final response = await client.get(Uri.parse('${baseUrl}trends/?season=$season'));
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final items = body['predictions'] as List;
      return items.map((e) => TrendModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch trends");
    }
  }

  @override
  Future<List<String>> getPredictions(int topN) async {
    final response = await client.get(Uri.parse('${baseUrl}trends/predict/?top_n=$topN'));
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return List<String>.from(body['predictions']);
    } else {
      throw Exception("Failed to fetch predictions");
    }
  }

  @override
  Future<List<TrendModel>> runScraper() async {
    final response = await client.post(Uri.parse('${baseUrl}trends/scrape/'));
    if (response.statusCode == 201) {
      final body = json.decode(response.body);
      final items = body['items'] as List;
      return items.map((e) => TrendModel.fromJson(e)).toList();
    } else {
      throw Exception("Scraper failed");
    }
  }
}