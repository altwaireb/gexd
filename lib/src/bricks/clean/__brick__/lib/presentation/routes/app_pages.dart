// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:get/get.dart';

import '../pages/errors/not_found/bindings/not_found_binding.dart';
import '../pages/errors/not_found/views/not_found_view.dart';
import '../pages/home/bindings/home_binding.dart';
import '../pages/home/views/home_view.dart';

part 'app_routes.dart';

/// Application Pages & Routes
class AppPages {
  AppPages._();

  /// Initial route
  static const INITIAL = Routes.HOME;

  /// Unknown route (fallback for 404)
  static final UNKNOWN = GetPage(
    name: _Paths.NOT_FOUND,
    page: () => const NotFoundView(),
    binding: NotFoundBinding(),
  );

  /// All application routes
  static final routes = <GetPage>[
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    UNKNOWN,
  ];
}
