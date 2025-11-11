# `remove` Command

---

## 📝 Description

The `remove` command safely removes packages from your Flutter project's `pubspec.yaml`. It handles dependency cleanup, version conflicts resolution, and ensures your project remains in a consistent state.

---

## ⚙️ Usage

```bash
gexd remove [package_name] [options]
gexd remove [package_name] [package_name2] [options]
```

### 📋 **Basic Examples:**

```bash
# Remove a specific package
gexd remove http

# Remove multiple packages
gexd remove http dio shared_preferences

# Preview removal without applying changes
gexd remove http --dry-run

# Remove dev dependencies
gexd remove --dev mockito test_coverage

# Interactive removal (select from list)
gexd remove
```

---

## 🚩 Flags

| Flag | Description |
|------|-------------|
| `--dry-run` | Show what would be removed without making changes |
| `--dev` | Remove from dev dependencies only |
| `--all-dev` | Remove all dev dependencies |
| `--unused` | Remove unused dependencies automatically |
| `--force` | Skip confirmation prompts |

---

## 🎯 **Interactive Mode**

When run without package name, `remove` enters interactive mode:

1. **📋 List current dependencies** (regular and dev)
2. **✅ Select packages** to remove
3. **🔍 Show dependency usage** analysis
4. **⚠️ Warn about breaking changes**
5. **🗑️ Remove safely**

---

## 📊 **Examples by Use Case:**

### **Clean Unused Packages:**
```bash
# Analyze and remove unused dependencies
gexd remove --unused

# Preview unused packages
gexd remove --unused --dry-run
```

### **Remove Development Tools:**
```bash
# Remove specific dev dependencies
gexd remove --dev test mockito flutter_test

# Remove all dev dependencies
gexd remove --all-dev
```

### **Bulk Removal:**
```bash
# Remove multiple related packages
gexd remove dio http chopper retrofit

# Remove with force (no confirmation)
gexd remove old_package --force
```

---

## ✅ **What It Does:**

1. **🔍 Dependency Analysis** - Checks if package is actually used
2. **⚠️ Impact Assessment** - Shows what might break
3. **📝 pubspec.yaml Update** - Removes dependency entries
4. **🧹 Lock File Cleanup** - Updates pubspec.lock
5. **⬇️ Dependency Resolution** - Runs `dart pub get`
6. **📋 Import Cleanup** - Suggests removing unused imports

---

## 🛡️ **Safety Features:**

- **🔒 Usage Detection:** Warns if package is used in code
- **📊 Dependency Tree:** Shows dependent packages
- **✅ Confirmation Prompts:** Asks before removal
- **🔄 Rollback Option:** Can undo changes
- **⚠️ Breaking Change Alerts:** Warns about major version changes

---

## ⚠️ **Notes:**

- **🔍 Code Scanning:** Analyzes imports in your project
- **🏗️ Build Verification:** Ensures project still compiles
- **📦 Transitive Dependencies:** Handles nested dependency removal
- **🎯 Selective Removal:** Can target specific dependency types

---

_Generated automatically by `gexd_doc`_
