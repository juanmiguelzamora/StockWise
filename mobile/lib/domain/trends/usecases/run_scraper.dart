import 'package:mobile/domain/trends/entity/trend.dart';
import 'package:mobile/domain/trends/repositories/trends_repositories.dart';

class RunScraper {
  final TrendsRepository repository;

  RunScraper(this.repository);

  Future<List<Trend>> call() {
    return repository.runScraper();
  }
}
