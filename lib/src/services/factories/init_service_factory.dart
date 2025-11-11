import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

/// Factory class to create various services used in project initialization
/// Provides methods to instantiate services with shared Logger
/// such as MasonService, DependencyService, PostGenerationService
class InitServiceFactory {
  final Logger logger;
  InitServiceFactory(this.logger);

  MasonService createMason() => MasonService(logger: logger);
  DependencyService createDependency() => DependencyService(logger: logger);
  PostGenerationService createPostGen() =>
      PostGenerationService(logger: logger);
}
