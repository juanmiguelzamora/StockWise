import 'package:flutter/material.dart';
import 'package:mobile/domain/trends/entity/trend.dart';
import 'package:mobile/domain/trends/usecases/get_predictions.dart';
import 'package:mobile/domain/trends/usecases/get_trends.dart';
import 'package:mobile/domain/trends/usecases/run_scraper.dart';

class TrendsProvider extends ChangeNotifier {
  final GetTrends getTrends;
  final GetPredictions getPredictions;
  final RunScraper runScraper;

  List<Trend> trends = [];
  List<String> predictions = [];
  bool isLoading = false;

  TrendsProvider({
    required this.getTrends,
    required this.getPredictions,
    required this.runScraper,
  });

  Future<void> fetchTrends(String season) async {
    isLoading = true;
    notifyListeners();
    trends = await getTrends(season);
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPredictions(int topN) async {
    predictions = await getPredictions(topN);
    notifyListeners();
  }

  Future<void> runScraperAndFetch() async {
    isLoading = true;
    notifyListeners();
    trends = await runScraper();
    isLoading = false;
    notifyListeners();
  }
}