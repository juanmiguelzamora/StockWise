import 'package:mobile/domain/trends/repositories/trends_repositories.dart';

class GetPredictions {
  final TrendsRepository repository;

  GetPredictions(this.repository);

  Future<List<String>> call(int topN) {
    return repository.getPredictions(topN);
  }
}