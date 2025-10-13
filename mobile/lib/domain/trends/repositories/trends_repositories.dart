import 'package:mobile/domain/trends/entity/trend.dart';

abstract class TrendsRepository {
  Future<List<Trend>> getTrends(String season);
  Future<List<String>> getPredictions(int topN);
  Future<List<Trend>> runScraper();
}