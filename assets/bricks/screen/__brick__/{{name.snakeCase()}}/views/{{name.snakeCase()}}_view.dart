import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/{{name.snakeCase()}}_controller.dart';
{{#has_model}}
{{#modelExists}}
import '{{{modelImport}}}';
{{/modelExists}}
{{/has_model}}

{{#is_basic}}
/// Basic screen view with simple UI
/// Shows welcome content with loading state
class {{name.pascalCase()}}View extends GetView<{{name.pascalCase()}}Controller> {
  const {{name.pascalCase()}}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{name.titleCase()}}'),
        centerTitle: true,
      ),
      body: Obx(() {
        // Show loading spinner while isLoading is true
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show main content when loading is complete
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flutter_dash,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(height: 24),
              Text(
                '{{name.titleCase()}} Screen',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome to your new screen!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
{{/is_basic}}

{{#is_form}}
/// Form screen view with input validation
/// Contains text fields with real-time validation and submit button
class {{name.pascalCase()}}View extends GetView<{{name.pascalCase()}}Controller> {
  const {{name.pascalCase()}}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("{{name.titleCase()}} Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              // Name input field with validation
              Obx(() => TextFormField(
                    controller: controller.nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      errorText: controller.nameError.value,
                    ),
                    validator: (value) =>
                        value?.isEmpty == true ? "Name is required" : null,
                  )),
              const SizedBox(height: 12),
              // Email input field with validation
              Obx(() => TextFormField(
                    controller: controller.emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: controller.emailError.value,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }
                      if (!GetUtils.isEmail(value)) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 24),
              // Submit button with loading state
              Obx(() => ElevatedButton(
                    onPressed:
                        controller.isSubmitting.value ? null : controller.submit,
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Submit"),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
{{/is_form}}


{{#is_state}}
/// State management screen view with automatic state handling
/// Uses controller.obx() to automatically show loading, error, empty states
/// Perfect for screens that load data from API
class {{name.pascalCase()}}View extends GetView<{{name.pascalCase()}}Controller> {
  const {{name.pascalCase()}}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        {{#has_model}}
        {{#modelExists}}
        title: const Text('{{modelName}}s'),
        {{/modelExists}}
        {{^modelExists}}
        title: const Text('{{modelName}}s (TODO: Create Model)'),
        {{/modelExists}}
        {{/has_model}}
        {{^has_model}}
        title: const Text('{{name.titleCase()}}'),
        {{/has_model}}
        centerTitle: true,
        actions: [
          // Refresh button to reload data
          IconButton(
            onPressed: controller.refreshData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      // obx() automatically handles all states based on controller.change()
      body: controller.obx(
        // Success state - show the actual data
        (state) => _buildDataState(context, state!),
        // Loading state - show progress indicator
        onLoading: const Center(child: CircularProgressIndicator()),
        // Empty state - show when no data found
        {{#has_model}}
        onEmpty: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              {{#modelExists}}
              Text('No {{modelName}}s found', style: Theme.of(context).textTheme.headlineSmall),
              Text('Pull down to refresh', style: Theme.of(context).textTheme.bodyMedium),
              {{/modelExists}}
              {{^modelExists}}
              Text('No {{modelName}}s found', style: Theme.of(context).textTheme.headlineSmall),
              Text('TODO: Implement {{modelName}} data loading', style: Theme.of(context).textTheme.bodyMedium),
              {{/modelExists}}
            ],
          ),
        ),
        {{/has_model}}
        {{^has_model}}
        onEmpty: const Center(child: Text('No data found')),
        {{/has_model}}
        // Error state - show error message with retry
        onError: (err) => _buildErrorState(context, err),
      ),
    );
  }

  /// Build the main content when data is loaded successfully
  /// Shows a list with pull-to-refresh functionality
  {{#has_model}}
  {{#modelExists}}
  Widget _buildDataState(BuildContext context, List<{{modelName}}> items) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            // TODO: Customize display based on {{modelName}} properties
            title: Text(item.toString()), // Replace with item.name or relevant property
            subtitle: Text('{{modelName}} #${index + 1}'),
            // TODO: Add more {{modelName}}-specific UI elements
            // Example: trailing: Text(item.status),
          );
        },
      ),
    );
  }
  {{/modelExists}}
  {{^modelExists}}
  Widget _buildDataState(BuildContext context, List<Map<String, dynamic>> items) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(item['name']?.toString() ?? '{{modelName}} #${index + 1}'),
            subtitle: Text('TODO: Create {{modelName}} model class'),
            // TODO: Replace Map<String, dynamic> with proper {{modelName}} model
            trailing: Icon(Icons.warning, color: Colors.orange),
          );
        },
      ),
    );
  }
  {{/modelExists}}
  {{/has_model}}
  {{^has_model}}
  Widget _buildDataState(BuildContext context, List<dynamic> items) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(item.toString()),
          );
        },
      ),
    );
  }
  {{/has_model}}

  /// Build error screen with retry button
  /// Shows when data loading fails
  Widget _buildErrorState(BuildContext context, String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            {{#has_model}}
            {{#modelExists}}
            Text('Failed to load {{modelName}}s',
                style: Theme.of(context).textTheme.headlineSmall),
            {{/modelExists}}
            {{^modelExists}}
            Text('Failed to load {{modelName}}s',
                style: Theme.of(context).textTheme.headlineSmall),
            {{/modelExists}}
            {{/has_model}}
            {{^has_model}}
            Text('Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall),
            {{/has_model}}
            const SizedBox(height: 8),
            Text(error ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.retry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
{{/is_state}}
