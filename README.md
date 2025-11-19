# 🧩 Gexd CLI

<div align="center">
  <img src="https://raw.githubusercontent.com/altwaireb/gexd/main/assets/logos/gexd-cli.svg" alt="GEXD Logo" width="400"/>
</div>

[![Format & Analyze](https://github.com/altwaireb/gexd/actions/workflows/formatting-analyze.yml/badge.svg)](https://github.com/altwaireb/gexd/actions/workflows/formatting-analyze.yml)
[![Run Tests](https://github.com/altwaireb/gexd/actions/workflows/run-tests.yml/badge.svg)](https://github.com/altwaireb/gexd/actions/workflows/run-tests.yml)
[![E2E Tests](https://github.com/altwaireb/gexd/actions/workflows/e2e-tests.yml/badge.svg)](https://github.com/altwaireb/gexd/actions/workflows/e2e-tests.yml)
[![Release](https://github.com/altwaireb/gexd/actions/workflows/release.yml/badge.svg)](https://github.com/altwaireb/gexd/actions/workflows/release.yml)
[![Latest Release](https://img.shields.io/github/v/release/altwaireb/gexd)](https://github.com/altwaireb/gexd/releases/latest)
[![pub package](https://img.shields.io/pub/v/gexd.svg)](https://pub.dev/packages/gexd)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Documentation](https://img.shields.io/badge/docs-GitBook-blue.svg)](https://gexd.gitbook.io/gexd-docs)

> A modern CLI tool for generating Flutter projects using **GetX** and **Clean Architecture**, designed for scalability, maintainability, and developer productivity.

📚 **[Complete Documentation](https://gexd.gitbook.io/gexd-docs)**

---

## 🎬 Demo

<div align="center">
  <img src="https://raw.githubusercontent.com/altwaireb/gexd/main/assets/gexd-demo.gif" alt="Gexd Demo" width="600"/>
  <p><em>See Gexd in action! Generate screens, models, and more with simple commands.</em></p>
</div>

---

## ⚡ Overview

`Gexd` helps Flutter developers scaffold complete applications using GetX + Clean Architecture, with strong typing, modular folder structure, and SOLID design principles.

### ✨ Highlights
- 🏗️ **Project Scaffolding** — GetX and Clean Architecture templates  
- 🧠 **Typed Model Integration** — Type-safe Repositories, Services, and Providers  
- 🧩 **Smart Code Generation** — Models from JSON/API, Screens with state management  
- 🛡️ **SOLID Principles** — Clean folder hierarchy and separation of concerns  
- 🌍 **Advanced Localization** — Multi-language with variables and pluralization  
- 📱 **Screen Templates** — Basic, Form, and withState screen types  
- 🔗 **Repository Pattern** — CRUD and custom repositories with interfaces  
- 🎯 **Interactive CLI** — Smart prompts and guided setup  

---

## 🚀 Installation

```bash
# Install from pub.dev (Using Dart)
dart pub global activate gexd

# Alternative: Install using Flutter
flutter pub global activate gexd

# Verify installation
gexd --version
````

### 📦 Pre-built Binaries

| Platform                 | Download                                                                                                   | Status  |
| ------------------------ | ---------------------------------------------------------------------------------------------------------- | ------- |
| 🐧 Linux (x64)           | [📥 gexd-linux-x64](https://github.com/altwaireb/gexd/releases/latest/download/gexd-linux-x64)             | ✅ Ready |
| 🪟 Windows (x64)         | [📥 gexd-windows-x64.exe](https://github.com/altwaireb/gexd/releases/latest/download/gexd-windows-x64.exe) | ✅ Ready |
| 🍎 macOS (Intel)         | [📥 gexd-macos-x64](https://github.com/altwaireb/gexd/releases/latest/download/gexd-macos-x64)             | ✅ Ready |
| 🍎 macOS (Apple Silicon) | [📥 gexd-macos-arm64](https://github.com/altwaireb/gexd/releases/latest/download/gexd-macos-arm64)         | ✅ Ready |

---

## 🧭 Quick Start

### Create a New Project

```bash
gexd create my_app                 # Default GetX project
gexd create my_app --template clean
gexd create my_app --org com.example
```

### Initialize Existing Project

```bash
gexd init --template clean
```

---

## 🧱 Core Commands

### 🏗️ Create

Create a new Flutter project.

```bash
gexd create <project_name> --template <getx|clean>
```

### 🔨 Make

Generate code components for your project:

| Command        | Example                                              | Description                     |
| -------------- | ---------------------------------------------------- | ------------------------------- |
| **Entity**     | `gexd make entity User --style immutable --with-model` | Domain entities for Clean Architecture |
| **Model**      | `gexd make model User --file user.json --immutable` | Smart models from JSON/API     |
| **Screen**     | `gexd make screen Login --type form`                 | Complete screen components      |
| **Repository** | `gexd make repository User --type crud --interface` | Typed CRUD repositories         |
| **Service**    | `gexd make service Auth --on auth`                   | Business logic services         |
| **Controller** | `gexd make controller Profile --type withState`     | Reactive controllers            |
| **Binding**    | `gexd make binding Home --location core`             | Dependency injection            |
| **Provider**   | `gexd make provider Api --model User`                | Typed API providers             |
| **Interface**  | `gexd make interface Repository --type crud`         | Abstract interfaces             |
| **Middleware** | `gexd make middleware Auth`                          | Route middleware                |
| **Exception**  | `gexd make exception ValidationError`                | Custom exceptions               |

### 🎯 Advanced Generation Features

#### 📱 Smart Screen Generation
```bash
gexd make screen Login --type form           # Form with validation
gexd make screen UserList --type withState   # Reactive state management  
gexd make screen Profile --has-model         # Type-safe with User model
```

#### 🗂️ Smart Model Generation
```bash
gexd make model User --file assets/user.json      # From JSON file
gexd make model User --url https://api.com/user   # From API endpoint
gexd make model User --immutable --copyWith        # Immutable with features
gexd make model User --style freezed               # Freezed-style models
```

#### 🗄️ Repository Pattern
```bash
gexd make repository User --type crud --interface  # Full CRUD with interface
gexd make repository User --model User             # Type-safe repository
```

#### 🎯 Flexible Organization
```bash
--on <subfolder>        # Generate in subdirectory (auth/user)
--location <type>       # Binding locations (core|shared|screen)
--model <ModelName>     # Enable typed integration
--interface            # Generate abstract interface
--force                # Overwrite existing files
```

---

## 🌍 Advanced Localization

Generate powerful multi-language support with advanced features:

```bash
gexd locale generate assets/locales --key-style dot --sort-keys
```

### 🚀 Localization Features

#### 🔗 Variable Replacement
```dart
// Dynamic content with named variables
Text('welcome'.trVars({'name': 'John'}))        // "Welcome John"
Text(LocaleKeys.welcome.trVars({'name': 'John'}))  // Type-safe version

// Multiple variables  
Text(LocaleKeys.greeting.trVars({'name': 'Ali', 'time': 'morning'}))  // "Good morning, Ali!"
```

#### 🔢 Smart Pluralization
```dart
// Universal pluralization for all languages
Text('items'.trCount({'count': '0'}))           // "No items"
Text(LocaleKeys.items.trCount({'count': '0'}))  // Type-safe version

// Rich Arabic pluralization (zero, one, two, few, many, other)
Text(LocaleKeys.notifications.trCount({'count': '2'}))   // "لديك إشعاران"
Text(LocaleKeys.notifications.trCount({'count': '15'}))  // "لديك 15 إشعاراً"
```

#### 🌟 Combined Features
```dart
// Pluralization with additional variables
Text(LocaleKeys.messages.trCount({'count': '5', 'sender': 'Ali'}))  // "5 messages from Ali"
```

#### 🔑 Type-Safe Keys  
```dart
// Generated LocaleKeys for compile-time safety
Text(LocaleKeys.welcome.tr)                     // Simple translation
Text(LocaleKeys.validation_required.trVars({'field': 'Email'}))  // With variables
Text(LocaleKeys.items.trCount({'count': '10'})) // With pluralization
```

**Supported Languages:** English, Arabic (RTL), French, and easily extensible to any language.

---

## 🧰 Dependency Management

```bash
gexd add http dio              # Add dependencies
gexd upgrade dio               # Upgrade dependencies
gexd remove dio                # Remove dependencies
```

---

## 🧠 Architecture Templates

### GetX Structure

```
lib/
├── app/
│   ├── modules/
│   ├── routes/
│   └── core/
├── data/
│   ├── models/
│   └── repositories/
└── domain/
    └── services/
```

### Clean Architecture

```
lib/
├── core/
├── data/
├── domain/
└── presentation/
```

---

## ⚙️ Advanced Options

### 🎛️ Generation Options
| Option                    | Description                               |
| ------------------------- | ----------------------------------------- |
| `--interactive`           | Run guided interactive mode               |
| `--type <crud\|form\|withState>` | Component type and behavior       |
| `--interface`             | Generate abstract interface               |
| `--model <Model>`         | Enable typed model integration            |
| `--immutable`             | Generate immutable data classes           |
| `--copyWith`              | Add copyWith methods                      |
| `--equatable`             | Use Equatable for value equality          |
| `--relationships-in-folder` | Organize model relationships           |

### 🎨 Style Options  
| Style      | Description                    | Best For              |
| ---------- | ------------------------------ | --------------------- |
| `plain`    | Simple Dart classes            | Basic models          |
| `json`     | JSON serializable models       | API integration       |
| `freezed`  | Freezed-style immutable models | Complex data handling |

### 🏗️ Architecture Options
| Template | Description              | Use Case                    |
| -------- | ------------------------ | --------------------------- |
| `getx`   | GetX modular architecture| Rapid development          |
| `clean`  | Clean Architecture (DDD) | Enterprise applications    |

---

## 💡 Help & Troubleshooting

```bash
gexd --help
gexd make repository --help
```

**Common Issues**

* ❌ *Command not found*: add Dart global path

  ```bash
  export PATH="$PATH":"$HOME/.pub-cache/bin"
  ```
* ⚙️ *Permission denied*:

  ```bash
  chmod +x gexd-macos-x64
  ```
* 🧩 *Model not found*: generate it first

  ```bash
  gexd make model User
  ```

---

## 🚀 Complete Workflow Example

Create a full-featured Flutter app in minutes:

```bash
# 1. Create Clean Architecture project
gexd create my_ecommerce_app --template clean

# 2. Generate User model from JSON
gexd make model User --file assets/models/user.json --immutable --copyWith

# 3. Generate typed repository with interface
gexd make repository User --type crud --interface --on auth/data

# 4. Generate authentication service  
gexd make service Auth --on auth

# 5. Generate login screen with form validation
gexd make screen Login --type form --on auth

# 6. Generate user profile screen with state management
gexd make screen UserProfile --type withState --has-model --on auth

# 7. Generate multi-language support
gexd locale generate assets/locales --key-style dot --sort-keys

# 8. Generate core bindings
gexd make binding App --location core
```

**Result:** A complete, production-ready Flutter app with Clean Architecture, type-safe repositories, reactive screens, and multi-language support! 🎉

---

## 🤝 Contributing

We welcome contributions!

* [Open an Issue](https://github.com/altwaireb/gexd/issues/new)
* [Start a Discussion](https://github.com/altwaireb/gexd/discussions)
* [Feature Requests](https://github.com/altwaireb/gexd/discussions/new?category=ideas)

Clone and setup for development:

```bash
git clone https://github.com/altwaireb/gexd.git
cd gexd
```

---

## 📄 License

Licensed under the **MIT License** — see [LICENSE](LICENSE).

---

## 📚 Documentation & Examples

* [📘 Complete Examples](./example/README.md) - Comprehensive usage examples
* [🗂️ Model Examples](./example/assets/models/) - JSON examples for model generation  
* [🌍 Locale Examples](./example/assets/locales/) - Multi-language examples
* [🚀 Advanced Features](./example/assets/LOCALE_FEATURES.md) - trVars & trCount usage
* [📦 pub.dev](https://pub.dev/packages/gexd)
* [💬 Discussions](https://github.com/altwaireb/gexd/discussions)

---

<div align="center">
  <img src="https://raw.githubusercontent.com/altwaireb/gexd/main/assets/logos/icon_with_text/svg/logo.svg" alt="GEXD" width="350"/>
  <br><br>
  <strong>Made with ❤️ for the Flutter community.</strong>
</div>