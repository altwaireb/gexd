import 'package:get/get.dart';

/// {{name.pascalCase()}} Binding
/// 
/// This class is responsible for injecting dependencies for the {{name.pascalCase()}} module.
{{#is_core}}/// This is a core binding that is loaded at application startup.{{/is_core}}
{{#is_shared}}/// This is a shared binding for common functionality.{{/is_shared}}
{{#is_screen}}/// This is a screen-specific binding for {{name.pascalCase()}} in the {{screenName}} screen.{{/is_screen}}
class {{name.pascalCase()}}Binding extends Bindings {
  @override
  void dependencies() {
    // Add your dependency injections here
    // Example:
    // Get.lazyPut<YourService>(() => YourService());
    // Get.put<YourRepository>(YourRepository());
  }
}