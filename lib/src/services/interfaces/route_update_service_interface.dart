import 'package:gexd/gexd.dart';

/// Interface for RouteUpdateService
/// Defines method for adding screen routes
/// to a project based on its template type
abstract class RouteUpdateServiceInterface {
  Future<bool> addScreenRoute({
    required String screenName,
    required String? subPath,
    required ProjectTemplate template,
  });
}
