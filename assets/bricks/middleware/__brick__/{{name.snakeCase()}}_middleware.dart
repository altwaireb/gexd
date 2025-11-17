import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// {{name.pascalCase()}}Middleware
///
/// Middleware class for route interception.
///
/// You can use priority to control the execution order.
/// The lower the priority number, the earlier it runs.
class {{name.pascalCase()}}Middleware extends GetMiddleware {
  /// Priority of this middleware.
  /// Lower numbers run earlier.
  final int _priority;

  {{name.pascalCase()}}Middleware({int priority = 1}) : _priority = priority;

  @override
  int get priority => _priority;

  /// Called before navigating to a route.
  /// Return `null` to continue or a `RouteSettings` to redirect.
  @override
  RouteSettings? redirect(String? route) {
    // Example:
    // if (!AuthService.to.isLoggedIn) {
    //   return const RouteSettings(name: '/login');
    // }
    return null;
  }

  /// Called just before the page is created.
  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    // print('Building page for $route');
    return super.onPageBuildStart(page);
  }

  /// Called right after the page is built.
  @override
  Widget onPageBuilt(Widget page) {
    // Add wrappers or decorations if needed
    return page;
  }

  /// Called right after navigation is completed.
  @override
  void onPageDispose() {
    // print('Disposed middleware for $route');
    super.onPageDispose();
  }
}
