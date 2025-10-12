import 'package:get/get.dart';

import 'package:{{project_name.snakeCase()}}/app/core/routes/app_pages.dart';

class NotFoundController extends GetxController {
  /// Navigate back to home
  void goHome() {
    Get.offAllNamed(Routes.HOME);
  }

  /// Navigate back in history
  void goBack() {
    if (Get.previousRoute.isNotEmpty) {
      Get.back();
    } else {
      goHome();
    }
  }

  /// Retry current route
  void retry() {
    final currentRoute = Get.currentRoute;
    if (currentRoute != Routes.NOT_FOUND) {
      Get.offNamed(currentRoute);
    } else {
      goHome();
    }
  }
}
