import 'package:mobile/data/trends/datasource/trends_remote_datasource.dart';
import 'package:mobile/domain/trends/entity/trend.dart';
import 'package:mobile/domain/trends/repositories/trends_repositories.dart';

class TrendsRepositoryImpl implements TrendsRepository {
  final TrendsRemoteDataSource remoteDataSource;

  TrendsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Trend>> getTrends(String season) {
    return remoteDataSource.getTrends(season);
  }

  @override
  Future<List<String>> getPredictions(int topN) {
    return remoteDataSource.getPredictions(topN);
  }

  @override
  Future<List<Trend>> runScraper() {
    return remoteDataSource.runScraper();
  }
}