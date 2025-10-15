import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class ScreenServiceFactory {
  final Logger logger;
  ScreenServiceFactory(this.logger);
  MasonService createMason() => MasonService(logger: logger);
  RouteUpdateService createRoute() => RouteUpdateService(logger: logger);
}
