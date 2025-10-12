import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class InitServiceFactory {
  final Logger logger;
  InitServiceFactory(this.logger);

  MasonService createMason() => MasonService(logger: logger);
  DependencyService createDependency() => DependencyService(logger: logger);
  PostGenerationService createPostGen() =>
      PostGenerationService(logger: logger);
}
