{{#is_form}}
import 'package:flutter/material.dart';
{{/is_form}}
import 'package:get/get.dart';

{{#is_basic}}
/// Basic screen controller with minimal functionality
/// Use this for simple screens that don't require complex state management
class {{name.pascalCase()}}Controller extends GetxController {
  /// Loading state for UI feedback
  /// Example: show spinner while data loads
  final isLoading = false.obs;

  /// Initialize screen data and setup
  /// Called once when screen is created
  void init{{name.pascalCase()}}() {
    // Add any init logic here
  }

  /// Handle user actions and interactions
  /// Example: button taps, navigation, etc.
  void handleAction() {
    // Add action handling logic here
  }

  /// Called when controller is first created
  /// Perfect place to initialize data
  @override
  void onInit() {
    super.onInit();

    init{{name.pascalCase()}}();

    // Simulate loading state (remove in real app)
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
    });
  }

  /// Called after UI is built and ready
  /// Use for animations or post-build actions
  @override
  void onReady() {
    super.onReady();
    // Called after the UI is rendered
  }

  /// Called when screen is closed/disposed
  /// Clean up resources here (timers, subscriptions, etc.)
  @override
  void onClose() {
    super.onClose();
    // Dispose controllers 
  }
}

{{/is_basic}}


{{#is_form}}

/// Form screen controller with validation and submission
/// Use this for screens with input fields and form validation
class {{name.pascalCase()}}Controller extends GetxController {
  /// Form validation key - required for form validation
  final formKey = GlobalKey<FormState>();

  /// Text input controllers - manage text field values
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  /// Custom error messages - shown below input fields
  final nameError = RxnString();
  final emailError = RxnString();

  /// Loading state during form submission
  final isSubmitting = false.obs;

  /// Validate form inputs and submit data
  /// Returns true if valid, shows errors if invalid
  void submit() {
    if (formKey.currentState?.validate() ?? false) {
      isSubmitting.value = true;

      // Custom validation using GetX utilities
      nameError.value =
          nameController.text.isEmpty ? "Name is required" : null;
      emailError.value = (!GetUtils.isEmail(emailController.text))
          ? "Invalid email address"
          : null;

      // Stop if validation errors exist
      if (nameError.value != null || emailError.value != null) {
        isSubmitting.value = false;
        return;
      }

      // TODO: Replace with real API call or database save
      Future.delayed(const Duration(seconds: 2), () {
        isSubmitting.value = false;
        Get.snackbar("Success", "Form submitted successfully");
      });
    }
  }

  /// Controller lifecycle - called when created
  @override
  void onInit() {
    super.onInit();
    // Called before the UI is rendered
  }

  /// Controller lifecycle - called after UI is ready
  @override
  void onReady() {
    super.onReady();
    // Called after the UI is rendered
  }

  /// Controller lifecycle - called when disposed
  /// IMPORTANT: Always dispose TextEditingController to prevent memory leaks
  @override
  void onClose() {
    // Dispose controllers 
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
{{/is_form}}


{{#is_state}}
{{#has_model}}
{{#modelExists}}
import '{{{modelImport}}}';
{{/modelExists}}
{{/has_model}}

/// State management controller with automatic loading/error/empty states
/// Use this for screens that load data from API or database
/// StateMixin automatically handles: loading, success, error, empty states
class {{name.pascalCase()}}Controller extends GetxController with StateMixin<{{#has_model}}{{#modelExists}}List<{{modelName}}>{{/modelExists}}{{^modelExists}}List<Map<String, dynamic>> /* TODO: Create {{modelName}} model */{{/modelExists}}{{/has_model}}{{^has_model}}List<dynamic>{{/has_model}}> {
  /// Load data from API/database
  /// Shows loading spinner automatically
  Future<void> loadData() async {
    try {
      change(null, status: RxStatus.loading());
      await Future.delayed(const Duration(seconds: 2)); // simulate API

      {{#has_model}}
      {{#modelExists}}
      // TODO: Replace with real API call that returns List<{{modelName}}>
      final items = <{{modelName}}>[];
      // Example: final items = await apiService.get{{modelName}}s();
      {{/modelExists}}
      {{^modelExists}}
      // TODO: Create {{modelName}} model class and replace Map<String, dynamic>
      final items = <Map<String, dynamic>>[];
      // Example: final items = await apiService.get{{modelName}}s();
      {{/modelExists}}
      {{/has_model}}
      {{^has_model}}
      final items = List.generate(10, (i) => 'Item ${i + 1}');
      {{/has_model}}
      
      change(items, status: RxStatus.success());
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  /// Refresh data (called by pull-to-refresh)
  /// Updates existing data with new content
  Future<void> refreshData() async {
    try {
      change(null, status: RxStatus.loading());
      await Future.delayed(const Duration(seconds: 1));

      {{#has_model}}
      {{#modelExists}}
      // TODO: Replace with real API refresh call
      final refreshed = <{{modelName}}>[];
      // Example: final refreshed = await apiService.refresh{{modelName}}s();
      {{/modelExists}}
      {{^modelExists}}
      // TODO: Create {{modelName}} model and replace Map
      final refreshed = <Map<String, dynamic>>[];
      {{/modelExists}}
      {{/has_model}}
      {{^has_model}}
      final refreshed = List.generate(10, (i) => 'Refreshed Item ${i + 1}');
      {{/has_model}}
      
      change(refreshed, status: RxStatus.success());
    } catch (e) {
      change(null, status: RxStatus.error('Failed to refresh: $e'));
    }
  }

  /// Retry loading after error
  /// Called when user taps "Retry" button
  void retry() => loadData();

  /// Auto-start loading when controller is created
  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// Called after UI is ready
  @override
  void onReady() {
    super.onReady();
    // Called after the UI is rendered
  }

  /// Clean up when controller is disposed
  @override
  void onClose() {
    super.onClose();
    // Dispose controllers 
  }
}
{{/is_state}}