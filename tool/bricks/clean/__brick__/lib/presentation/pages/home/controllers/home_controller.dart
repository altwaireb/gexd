// ignore_for_file: unnecessary_overrides

import 'package:get/get.dart';

class HomeController extends GetxController {
  // Show a snackbar with a message
  void sayHello() {
    Get.snackbar('Hello World', 'Generated with Gexd CLI');
  }

  // called when the controller is initialized
  @override
  void onInit() {
    super.onInit();
    // Initialize controller
  }

  // Called when the controller is ready
  @override
  void onReady() {
    super.onReady();
    // Controller is ready
  }

  // Called when the controller is closed
  @override
  void onClose() {
    super.onClose();
    // dispose controller resources
  }
}
