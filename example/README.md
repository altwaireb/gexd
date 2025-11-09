# 🚀 Gexd CLI - Complete Flutter Development Toolkit

> **Generate production-ready Flutter apps with GetX & Clean Architecture in seconds**

[![pub package](https://img.shields.io/pub/v/gexd.svg)](https://pub.dartlang.org/packages/gexd)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Gexd (GetX Developer) is an advanced CLI tool that revolutionizes Flutter development by providing intelligent code generation, architectural templates, and powerful automation features.

## ✨ Key Features

🏗️ **Multiple Architecture Templates**
- **GetX Standard**: Modular GetX architecture
- **Clean Architecture**: Domain-driven design with layered architecture

🎯 **Intelligent Code Generation**
- Type-safe model generation from JSON/API
- Smart screen components with state management
- Automated dependency injection setup
- Repository pattern implementation

🌍 **Internationalization Ready**
- Automatic locale file generation
- Multi-language support out of the box

🔧 **Developer Experience**
- Interactive CLI with smart defaults
- Force overwrite protection
- Flexible project structure
- Live reload integration

---

## 🚀 Quick Start

### 1. Installation
```bash
dart pub global activate gexd
```

### 2. Create Your First Project

#### 🎨 GetX Standard Architecture
```bash
gexd create my_todo_app
```
**Perfect for:** Rapid prototyping, medium-sized apps, GetX enthusiasts

#### 🏛️ Clean Architecture
```bash
gexd create my_todo_app --template clean
```
**Perfect for:** Enterprise apps, complex business logic, scalable architecture

### 3. Initialize Existing Projects
```bash
# Add GetX structure to existing Flutter project
gexd init --template getx

# Add Clean Architecture with full structure
gexd init --template clean --full
```

---

## 🛠️ Code Generation Commands

### 📱 Screen Generation
Generate complete screen components with controller, view, and binding:

```bash
# 🎯 Interactive mode - Smart prompts guide you
gexd make screen

# 🚀 Quick generation
gexd make screen Login

# 📝 Form screen with validation
gexd make screen Login --type form

# 🔄 Stateful screen with reactive data
gexd make screen UserList --type withState --model User
```

**Screen Types:**
- `basic` - Simple controller with lifecycle methods
- `form` - Form validation and submission handling  
- `withState` - Reactive state management with loading states

### 🗂️ Model Generation
Create type-safe models with advanced features:

```bash
# 📊 From JSON file
gexd make model User --file assets/user.json

# 🌐 From API endpoint
gexd make model User --url https://api.example.com/user/123

# 🛡️ Immutable model with features
gexd make model User --immutable --copyWith --equatable

# ❄️ Freezed-style models
gexd make model User --style freezed --immutable
```

**Model Features:**
- JSON serialization/deserialization
- Immutable data structures
- Copy methods for state updates
- Equatable integration
- Relationship detection

### 🎯 Binding Management
Organize dependency injection efficiently:

```bash
# 🌐 Global application bindings
gexd make binding Config --location core

# 🤝 Shared module bindings
gexd make binding Auth --location shared

# 📱 Screen-specific bindings
gexd make binding Profile --location screen --on-screen login

# 📁 Subdirectory organization
gexd make binding Tools --location core --on utilities
```

### 🗄️ Repository Pattern
Implement clean data access layers:

```bash
# 📚 CRUD repository with type safety
gexd make repository User --type crud --model User --interface

# 🔧 Custom repository
gexd make repository PaymentGateway --type empty --interface

# 📂 Organized structure
gexd make repository User --on auth/data --type crud
```

### 🔧 Services & Controllers
Build robust business logic:

```bash
# 🏢 Business service layer
gexd make service AuthService --on auth

# 🎮 Standalone controller
gexd make controller ChatController --type withState

# 📡 API interfaces
gexd make interface PaymentInterface --type crud --model Payment
```

### 🌍 Internationalization
Multi-language support made easy:

```bash
# 🗣️ Generate locale files from JSON
gexd locale generate
```

---

## 🏗️ Architecture Overview

### GetX Standard Architecture
```
lib/
├── app/
│   ├── modules/           # Feature modules
│   │   ├── auth/
│   │   │   ├── controllers/
│   │   │   ├── views/
│   │   │   └── bindings/
│   │   └── home/
│   ├── core/             # Core utilities
│   │   ├── bindings/
│   │   ├── routes/
│   │   └── themes/
│   └── data/            # Data layer
└── main.dart
```

### Clean Architecture
```
lib/
├── core/                # Core utilities
├── presentation/        # UI layer
│   ├── pages/
│   ├── controllers/
│   └── bindings/
├── domain/             # Business logic
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/              # Data layer
│   ├── models/
│   ├── repositories/
│   └── datasources/
└── main.dart
```

---

## 🎯 Advanced Features

### 💡 Smart Defaults & Interactive Mode
Gexd automatically detects your project structure and provides intelligent suggestions:

```bash
# Interactive mode guides you through options
gexd make screen  # Auto-detects project type and suggests best practices
```

### 🔄 Type-Safe State Management
Generate controllers with proper typing:

```bash
# Generates typed controller with User model integration
gexd make screen UserProfile --type withState --has-model
```

### 📁 Flexible Organization
Organize your code with subdirectories:

```bash
# Create nested structures
gexd make screen LoginForm --on auth/forms
gexd make model UserProfile --on auth/models  
gexd make repository UserRepo --on auth/data
```

### ⚡ Force & Skip Options
Control generation behavior:

```bash
# Force overwrite existing files
gexd make screen Login --force

# Skip automatic route registration
gexd make screen Settings --skip-route
```

---

## 📚 Example Projects

Explore complete examples in this directory:

| Example | Description | Features |
|---------|-------------|----------|
| 📝 [**Simple Todo**](simple_todo_example/) | Complete CRUD app tutorial | Basic GetX patterns, state management |
| 🛒 [**E-commerce**](ecommerce_example.md) | Full shopping app | Clean architecture, complex state |
| 🌐 [**Multi-language**](multilang_example.md) | Internationalization | Locale generation, translations |
| 🔌 [**API Integration**](api_integration_example.md) | REST API & offline | Repository pattern, caching |

---

## 🚀 Getting Started Checklist

- [ ] Install Gexd CLI: `dart pub global activate gexd`
- [ ] Create new project: `gexd create my_app --template clean`
- [ ] Generate your first screen: `gexd make screen Home`
- [ ] Add a model: `gexd make model User --file user.json`
- [ ] Set up repository: `gexd make repository User --type crud --interface`
- [ ] Add localization: `gexd locale generate`

---

## 💡 Pro Tips

1. **Use Interactive Mode** - Run commands without arguments for guided setup
2. **Organize with Subdirectories** - Use `--on` to create clean folder structures  
3. **Type-Safe Models** - Always specify models for withState screens
4. **Interface Generation** - Use `--interface` flag for better architecture
5. **Force When Needed** - Use `--force` to quickly iterate during development

---

Ready to build amazing Flutter apps? Choose an example above and start coding! 🚀