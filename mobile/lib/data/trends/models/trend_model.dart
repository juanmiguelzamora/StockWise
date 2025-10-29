
import 'package:mobile/domain/trends/entity/trend.dart';

class TrendModel extends Trend {
  TrendModel({
    required super.keyword,
    required super.season,
    required super.score,
    required super.source,
  });

  factory TrendModel.fromJson(Map<String, dynamic> json) {
    return TrendModel(
      keyword: json['keyword'],
      season: json['season'],
      score: (json['score'] as num).toDouble(),
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'season': season,
      'score': score,
      'source': source,
    };
  }
}
