import 'package:gexd/gexd.dart';

abstract class RouteUpdateServiceInterface {
  Future<bool> addScreenRoute({
    required String screenName,
    required String? subPath,
    required ProjectTemplate template,
  });
}
