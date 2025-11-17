# {{project_name.titleCase()}}

A Flutter project created with **Gexd CLI** using {{template}}.

## 🏗️ Architecture

This project uses **{{template}}** pattern with the following structure:

```
lib/
├── core/
│   ├── bindings/              # Dependency injection
│   └── themes/                # App theming & styles
│       ├── app_colors.dart    # Color definitions
│       └── app_theme.dart     # Theme configuration
├── presentation/              # UI Layer
│   ├── pages/                 # Screen widgets
│   │   ├── home/              # Home page
│   │   │   ├── bindings/      # Page bindings
│   │   │   ├── controllers/   # Page controllers
│   │   │   └── views/         # Page views
│   │   └── errors/            # Error pages
│   │       └── not_found/     # 404 page
│   └── routes/                # Navigation & routing
│       ├── app_pages.dart     # Page definitions
│       └── app_routes.dart    # Route constants
└── main.dart                  # App entry point
```

## 🏛️ Clean Architecture Principles

This template follows Clean Architecture principles:

### 🎯 **Separation of Concerns**
- **Presentation Layer**: UI components, pages, and controllers
- **Core Layer**: Business logic, themes, and shared functionality

### 📁 **Layer Organization**
- **`presentation/`**: Contains all UI-related code
- **`core/`**: Contains business logic and shared resources

### 🔗 **Dependency Rule**
- Inner layers don't depend on outer layers
- Business logic is independent of UI frameworks
- Easy to test and maintain

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Gexd CLI

### Installation & Running

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

3. **Build for production:**
   ```bash
   # Android
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   
   # Web
   flutter build web --release
   ```

## 🛠️ Gexd Commands

### Generate Components
```bash
# Create a new page (Clean Architecture)
gexd make view ProfileView

# Create a controller
gexd make controller Profile

# Create a widget
gexd make widget CustomButton

# Create a model
gexd make model User
```

### Project Management
```bash
# Initialize Gexd in existing project
gexd init --template {{template}}

# Setup additional dependencies
gexd setup

# Generate project documentation
gexd docs
```

## 📁 Project Structure

### Key Directories
- **`lib/presentation/pages/`** - UI pages organized by feature
- **`lib/core/`** - Core application functionality & themes
- **`lib/presentation/routes/`** - Navigation and routing
- **`lib/core/themes/`** - Theme configuration & colors

### Generated Files
- **`lib/main.dart`** - Application entry point
- **`lib/presentation/routes/app_pages.dart`** - Route definitions
- **`lib/core/bindings/initial_binding.dart`** - Global dependencies
- **`lib/core/themes/app_theme.dart`** - Theme configuration

## 🎨 Theming

The project includes a comprehensive theming system:

```dart
// Light and dark theme support
ThemeMode.system // Follows system preference

// Custom colors and styles
AppTheme.lightTheme
AppTheme.darkTheme
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📚 Learn More

### Documentation
- [Gexd Documentation](https://gexd.gitbook.io/gexd-docs)
- [Flutter Documentation](https://docs.flutter.dev/)
- [GetX Documentation](https://github.com/jonataslaw/getx)

### Architecture Guides
- [{{template_type.toUpperCase()}} Architecture Pattern](https://github.com/altwaireb/gexd/doc/{{template_type}})
- [State Management Best Practices](https://github.com/altwaireb/gexd/doc/state-management)
- [Project Structure Guidelines](https://github.com/altwaireb/gexd/doc/structure)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Gexd CLI** - For the amazing project generation
- **Flutter Team** - For the incredible framework
- **GetX Team** - For the powerful state management solution

---

**Generated with ❤️ by [Gexd CLI](https://github.com/altwaireb/gexd)**

📚 **[Complete Documentation](https://gexd.gitbook.io/gexd-docs)** | 🚀 **[Quick Start Guide](https://gexd.gitbook.io/gexd-docs)**

> Ready to build something amazing? Start coding! 🚀
