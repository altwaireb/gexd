# `add` Command

---

## 📝 Description

The `add` command allows you to easily add new packages to your Flutter project's `pubspec.yaml`. It provides an interactive way to search, select, and install packages from pub.dev with proper dependency management.

---

## ⚙️ Usage

```bash
gexd add [package_name] [options]
gexd add [package_name] [version] [options]
```

### 📋 **Basic Examples:**

```bash
# Add a package interactively
gexd add

# Add a specific package
gexd add http

# Add a package with specific version
gexd add http ^1.1.0

# Add multiple packages
gexd add http dio shared_preferences

# Add as dev dependency
gexd add --dev test mockito

# Preview changes without applying
gexd add http --dry-run
```

---

## 🚩 Flags

| Flag | Description |
|------|-------------|
| `--dev` | Add package as a dev dependency |
| `--dry-run` | Show what would be added without making changes |
| `--git-url <url>` | Add package from git repository |
| `--git-ref <ref>` | Specify git branch/tag/commit |
| `--path <path>` | Add package from local path |
| `--hosted-url <url>` | Add package from custom pub server |

---

## 🎯 **Interactive Mode**

When run without package name, `add` enters interactive mode:

1. **🔍 Search packages** on pub.dev
2. **📋 Browse results** with descriptions and ratings
3. **✅ Select packages** to add
4. **⚙️ Choose dependency type** (regular/dev)
5. **📦 Install automatically**

---

## 📊 **Examples by Use Case:**

### **Web Packages:**
```bash
gexd add dio http url_launcher
```

### **State Management:**
```bash
gexd add get riverpod bloc
```

### **UI Components:**
```bash
gexd add flutter_svg cached_network_image
```

### **Development Tools:**
```bash
gexd add --dev test flutter_test mockito
```

### **Git Dependencies:**
```bash
gexd add my_package --git-url https://github.com/user/repo.git
gexd add my_package --git-url https://github.com/user/repo.git --git-ref develop
```

---

## ✅ **What It Does:**

1. **📦 Package Search** - Finds packages on pub.dev
2. **📝 Version Resolution** - Determines compatible versions
3. **✏️ pubspec.yaml Update** - Adds dependency entries
4. **⬇️ Package Installation** - Runs `dart pub get`
5. **🔧 Import Suggestions** - Shows import statements

---

## ⚠️ **Notes:**

- **🔍 Version Constraints:** Uses compatible version ranges by default
- **⚡ Conflict Resolution:** Automatically resolves version conflicts
- **🔄 Project Validation:** Ensures project is a valid Flutter/Dart project
- **📋 Dependency Analysis:** Checks for existing dependencies

---

_Generated automatically by `gexd_doc`_
