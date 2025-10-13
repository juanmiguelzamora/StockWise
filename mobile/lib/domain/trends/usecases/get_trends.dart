import 'package:mobile/domain/trends/entity/trend.dart';
import 'package:mobile/domain/trends/repositories/trends_repositories.dart';

class GetTrends {
  final TrendsRepository repository;

  GetTrends(this.repository);

  Future<List<Trend>> call(String season) {
    return repository.getTrends(season);
  }
}