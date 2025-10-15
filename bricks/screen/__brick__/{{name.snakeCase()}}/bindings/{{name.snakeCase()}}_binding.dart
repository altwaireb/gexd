import 'package:get/get.dart';
import '../controllers/{{name.snakeCase()}}_controller.dart';

/// Dependency injection for {{name.titleCase()}} screen
/// Manages controller lifecycle automatically with GetX
class {{name.pascalCase()}}Binding extends Bindings {
  @override
  void dependencies() {
    /// lazyPut: Creates controller only when needed (memory efficient)
    /// Controller will be automatically disposed when screen is removed
    Get.lazyPut<{{name.pascalCase()}}Controller>(
      () => {{name.pascalCase()}}Controller(),
    );
  }
}
