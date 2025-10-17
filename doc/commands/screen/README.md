# 🎯 Screen Command Documentation

The Screen Command is a powerful code generation tool that creates complete screen modules with controllers, views, and bindings for Flutter applications using GetX or Clean Architecture patterns.

## 🚀 Quick Start

```bash
# Create a basic screen
gexd make screen Login

# Create a form screen with validation
gexd make screen Register --type form

# Create a screen with state management and model
gexd make screen UserProfile --type withState --has-model
```

## 📋 Command Syntax

```bash
gexd make screen <screen_name> [options]
```

### Required Arguments

- `<screen_name>`: The name of the screen to create (PascalCase or camelCase)

### Available Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--type` | `-t` | Type of screen to create (`basic`, `form`, `withState`) | `basic` |
| `--model` | `-m` | Specify a model class name to use | - |
| `--has-model` | | Use a model with the same name as the screen | `false` |
| `--skip-route` | `-s` | Skip automatic route generation | `false` |
| `--on` | `-o` | Create screen in a subdirectory | - |
| `--force` | `-f` | Overwrite existing files | `false` |
| `--help` | `-h` | Show help information | - |

## 🏗️ Screen Types

### Basic Screen (`--type basic`)
Creates a simple screen with minimal boilerplate.

**Generated Files:**
- Controller: Basic GetX controller
- View: Simple StatelessWidget
- Binding: Dependency injection binding

**Example:**
```bash
gexd make screen Home --type basic
```

### Form Screen (`--type form`)
Creates a screen optimized for forms with validation.

**Generated Files:**
- Controller: Controller with form validation logic
- View: Form widget with TextFormField components
- Binding: Standard binding

**Features:**
- Form validation setup
- Text controllers management
- Form submission handling

**Example:**
```bash
gexd make screen ContactForm --type form
```

### State Management Screen (`--type withState`)
Creates a screen with advanced state management capabilities.

**Generated Files:**
- Controller: Enhanced controller with state management
- View: Reactive UI components
- Binding: Advanced binding setup

**Features:**
- Reactive state management
- Loading states
- Error handling
- Optional model integration

**Example:**
```bash
gexd make screen Dashboard --type withState
```

## 🎭 Model Integration

### Using `--model` Flag
Specify an existing model class to integrate with your screen.

```bash
gexd make screen UserList --type withState --model User
```

**Requirements:**
- Model class must exist in `lib/app/data/models/` (GetX) or `lib/core/models/` (Clean)
- Model class must be properly defined

### Using `--has-model` Flag
Automatically detect and use a model with the same name as the screen.

```bash
gexd make screen Product --type withState --has-model
```

**Behavior:**
- Looks for a model class with the exact same name as the screen
- Screen name: `Product` → Model: `Product` class in `product.dart`
- Fails if model is not found

## 🗂️ Directory Structure

### GetX Template Structure
```
lib/app/modules/
└── screen_name/
    ├── controllers/
    │   └── screen_name_controller.dart
    ├── views/
    │   └── screen_name_view.dart
    └── bindings/
        └── screen_name_binding.dart
```

### Clean Template Structure  
```
lib/presentation/pages/
└── screen_name/
    ├── controllers/
    │   └── screen_name_controller.dart
    ├── views/
    │   └── screen_name_view.dart
    └── bindings/
        └── screen_name_binding.dart
```

### Subdirectory Creation (`--on`)
Create screens in custom subdirectories:

```bash
gexd make screen Profile --on auth/user
```

**Result:**
```
lib/app/modules/auth/user/profile/
├── controllers/
├── views/
└── bindings/
```

## 🛣️ Route Management

### Automatic Route Updates
By default, the Screen Command automatically:

1. **Updates `app_routes.dart`**: Adds route constant
2. **Updates `app_pages.dart`**: Adds route definition with binding

**Example Route Addition:**
```dart
// app_routes.dart
class Routes {
  static const LOGIN = '/login';
  // ... other routes
}

// app_pages.dart
class AppPages {
  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    // ... other pages
  ];
}
```

### Skipping Route Updates (`--skip-route`)
Use when you want to handle routing manually:

```bash
gexd make screen CustomScreen --skip-route
```

## ⚡ Advanced Usage Examples

### Create Multiple Related Screens
```bash
# Authentication flow
gexd make screen Login --type form
gexd make screen Register --type form  
gexd make screen ForgotPassword --type form

# User management with models
gexd make screen UserList --type withState --has-model
gexd make screen UserDetail --type withState --model User
gexd make screen CreateUser --type form --model User
```

### Organize by Features
```bash
# E-commerce feature
gexd make screen ProductList --on ecommerce --type withState --has-model
gexd make screen ProductDetail --on ecommerce --type withState --model Product
gexd make screen Cart --on ecommerce --type withState
gexd make screen Checkout --on ecommerce --type form

# Admin feature  
gexd make screen Dashboard --on admin --type withState
gexd make screen UserManagement --on admin --type withState
gexd make screen Settings --on admin --skip-route
```

### Development Workflow
```bash
# Development - use force to iterate quickly
gexd make screen TestScreen --force

# Production - let it fail if exists to prevent overwrites
gexd make screen ProductionScreen
```

## 🚨 Error Handling

### Common Errors and Solutions

#### Validation Errors
- **Empty screen name**: Provide a valid screen name
- **Invalid characters**: Use only letters, numbers, and underscores
- **Invalid screen type**: Use `basic`, `form`, or `withState`

#### Model Detection Errors
- **Model not found**: Ensure model file exists in correct directory
- **Model class not found**: Verify class name matches file name
- **Invalid model path**: Check model file location and naming

#### File System Errors
- **Permission denied**: Check write permissions
- **File already exists**: Use `--force` to overwrite or choose different name
- **Directory creation failed**: Check parent directory permissions

#### Route Update Errors
- **Route files not found**: Ensure you're in a valid Flutter project
- **Route parsing failed**: Route files may have syntax errors
- **Import resolution failed**: Check project structure

## 🔧 Troubleshooting

### Debug Mode
Run with verbose output to see detailed information:

```bash
gexd make screen TestScreen --verbose
```

### Verify Installation
Check if gexd is properly installed:

```bash
gexd --version
gexd --help
```

### Check Project Structure
Ensure you're in a Flutter project with proper structure:

```bash
# Should show Flutter project files
ls -la
# pubspec.yaml, lib/, etc.
```

### Template Verification
Verify your project template:

```bash
# Check if using GetX template
ls lib/app/modules/

# Check if using Clean template  
ls lib/presentation/pages/
```

## 📊 Performance Tips

1. **Use `--skip-route`** when creating many screens to speed up generation
2. **Batch operations** instead of creating screens one by one
3. **Use `--force` carefully** to avoid unnecessary overwrites
4. **Organize with `--on`** to maintain clean project structure

## 🧪 Testing

Run the complete test suite:

```bash
./scripts/test_screen_command.sh
```

Individual test categories:
```bash  
# Integration tests
dart test test/e2e/commands/make/screen/make_screen_command_test.dart

# Validation tests
dart test test/e2e/commands/make/screen/screen_validation_test.dart

# Performance tests  
dart test test/e2e/commands/make/screen/screen_performance_test.dart
```

## 📚 Related Commands

- [`gexd create`](../create/README.md) - Create new Flutter projects
- [`gexd make controller`](../controller/README.md) - Create standalone controllers
- [`gexd make service`](../service/README.md) - Create service classes

## 🤝 Contributing

See [CONTRIBUTING.md](../../../CONTRIBUTING.md) for guidelines on contributing to the Screen Command.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details.