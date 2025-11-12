# GEXD CLI Documentation

<div align="center">
  <img src="https://github.com/altwaireb/gexd/raw/main/assets/gexd-logo.svg" alt="GEXD Logo" width="400"/>
</div>

{% hint style="success" %}
**Welcome to GEXD!** A powerful Flutter project generator for clean architecture.
{% endhint %}

GEXD is a comprehensive Flutter project scaffolding tool that helps you create scalable applications using the **GetX pattern** with **clean architecture principles**. Generate complete project structures with predefined templates, manage configurations, and maintain consistent code organization.

## ✨ What is GEXD?

GEXD (GetX Development) is a CLI tool that automates the creation of Flutter projects with:
- **Clean Architecture** structure
- **GetX State Management** integration  
- **Predefined Templates** for rapid development
- **Configuration Management** for project settings
- **Best Practices** enforcement

---

## 🚀 Quick Start

```bash
# Install GEXD globally
dart pub global activate gexd

# Create a new project
gexd create my_app

# Get help
gexd --help
```

---

## 📋 Available Commands

### Project Commands
- **[Create](commands/create_command.md)** - Create a new Flutter project using gexd templates
- **[Init](commands/init_command.md)** - Initialize an existing Flutter project with gexd structure
- **[Add](commands/add_command.md)** - Add packages to your Flutter project
- **[Remove](commands/remove_command.md)** - Remove packages from your Flutter project
- **[Upgrade](commands/upgrade_command.md)** - Upgrade packages in your Flutter project
- **[Self-update](commands/self_update_command.md)** - Update gexd CLI tool to the latest version

### Information Commands
- **[Info](commands/info_command.md)** - Display project and template information
- **[Config](commands/info/config_command.md)** - Show current project configuration
- **[Template](commands/info/template_command.md)** - Display template information and structure

### Localization Commands
- **[Locale](commands/locale_command.md)** - Manage GetX locale translations
- **[Generate](commands/locales/generate_command.md)** - Generate locale files from JSON

### Component Generation Commands
- **[Make](commands/make_command.md)** - Generate various project files and components
- **[Binding](commands/make/binding_command.md)** - Generate binding files for dependency injection
- **[Controller](commands/make/controller_command.md)** - Generate controller files for state management
- **[View](commands/make/view_command.md)** - Generate view files for UI components
- **[Widget](commands/make/widget_command.md)** - Generate reusable Flutter widgets
- **[Screen](commands/make/screen_command.md)** - Generate complete screen with controller and view
- **[Service](commands/make/service_command.md)** - Generate service files for business logic
- **[Repository](commands/make/repository_command.md)** - Generate repository files for data access
- **[Provider](commands/make/provider_command.md)** - Generate provider files for data providers
- **[Model](commands/make/model_command.md)** - Generate model files for data structures
- **[Entity](commands/make/entity_command.md)** - Generate domain entities for Clean Architecture
- **[Interface](commands/make/interface_command.md)** - Generate interface files for abstractions
- **[Util](commands/make/util_command.md)** - Generate utility helper classes
- **[Constant](commands/make/constant_command.md)** - Generate constant files
- **[Exception](commands/make/exception_command.md)** - Generate custom exception classes
- **[Middleware](commands/make/middleware_command.md)** - Generate middleware files for routing

---

## ✨ Features

- 🏗️ **Clean Architecture** - Well-structured project templates
- 🎨 **GetX Integration** - State management and routing
- 📱 **Flutter Ready** - Mobile-first development
- ⚡ **Fast Setup** - Get started in seconds
- 🛠️ **Customizable** - Flexible project configuration

---

## 📖 Navigation

Use the sidebar to explore detailed documentation for each command.
Each command page includes usage examples, available options, and practical guides.

_This documentation is generated automatically by `gexd_doc`_
