# `upgrade` Command

---

## 📝 Description

The `upgrade` command updates all packages in your Flutter project to their latest compatible versions. It intelligently manages version constraints, resolves conflicts, and ensures your project remains stable while benefiting from the latest improvements.

---

## ⚙️ Usage

```bash
gexd upgrade [package_name] [options]
gexd upgrade [options]
```

### 📋 **Basic Examples:**

```bash
# Upgrade all packages
gexd upgrade

# Upgrade specific package
gexd upgrade http

# Upgrade multiple specific packages
gexd upgrade http dio shared_preferences

# Preview upgrades without applying
gexd upgrade --dry-run

# Major version upgrades
gexd upgrade --major-versions

# Upgrade dev dependencies only
gexd upgrade --dev-dependencies
```

---

## 🚩 Flags

| Flag | Description |
|------|-------------|
| `--dry-run` | Show available upgrades without applying changes |
| `--major-versions` | Allow major version upgrades |
| `--dev-dependencies` | Upgrade dev dependencies only |
| `--no-dev-dependencies` | Skip dev dependencies |
| `--force` | Force upgrade without compatibility checks |
| `--precompile` | Precompile executables after upgrade |

---

## 🎯 **Upgrade Process:**

1. **📊 Dependency Analysis** - Analyzes current package versions
2. **🔍 Version Discovery** - Finds latest compatible versions
3. **⚠️ Conflict Detection** - Identifies potential breaking changes
4. **📋 Upgrade Plan** - Shows what will be changed
5. **✅ User Confirmation** - Asks for approval before applying
6. **⬇️ Package Update** - Downloads and installs new versions

---

## 📊 **Examples by Scope:**

### **Full Project Upgrade:**
```bash
# Upgrade everything safely
gexd upgrade

# Preview all available upgrades
gexd upgrade --dry-run

# Upgrade with major versions (risky)
gexd upgrade --major-versions
```

### **Targeted Upgrades:**
```bash
# Upgrade specific package
gexd upgrade flutter_svg

# Upgrade state management packages
gexd upgrade get riverpod bloc

# Upgrade dev tools only
gexd upgrade --dev-dependencies
```

### **Safe Upgrades:**
```bash
# Minor and patch updates only
gexd upgrade --no-major-versions

# With compatibility verification
gexd upgrade --verify-compatibility
```

---

## ✅ **What It Does:**

1. **📋 Version Analysis** - Compares current vs available versions
2. **🔍 Compatibility Check** - Ensures version compatibility
3. **📝 pubspec.yaml Update** - Updates version constraints
4. **⬇️ Package Resolution** - Resolves and downloads packages
5. **🧪 Build Test** - Optionally tests build after upgrade
6. **📊 Upgrade Report** - Shows summary of changes

---

## 🛡️ **Safety Features:**

- **⚠️ Breaking Change Detection:** Warns about major version changes
- **🔄 Dependency Resolution:** Solves version conflicts automatically
- **💾 Backup Creation:** Backs up pubspec.yaml before changes
- **🧪 Build Verification:** Tests compilation after upgrade
- **📋 Detailed Reporting:** Shows exactly what changed

---

## 📊 **Upgrade Strategies:**

### **Conservative (Recommended):**
```bash
# Minor and patch updates only
gexd upgrade
```

### **Moderate:**
```bash
# Include compatible minor versions
gexd upgrade --minor-versions
```

### **Aggressive (Risky):**
```bash
# Allow major version updates
gexd upgrade --major-versions
```

---

## 🔧 **Advanced Options:**

### **Selective Upgrades:**
```bash
# Upgrade specific categories
gexd upgrade --category ui          # UI packages
gexd upgrade --category networking  # Network packages
gexd upgrade --category testing     # Test packages
```

### **Constraint Management:**
```bash
# Update constraints in pubspec.yaml
gexd upgrade --update-constraints

# Lock to exact versions
gexd upgrade --lock-versions
```

---

## ⚠️ **Potential Issues:**

### **Breaking Changes:**
- **🔍 API Changes:** New versions might have different APIs
- **⚡ Performance Impact:** New versions might affect performance
- **🧩 Dependency Conflicts:** Packages might have conflicting requirements

### **Recovery:**
```bash
# Restore from backup
gexd upgrade --restore-backup

# Downgrade specific package
gexd downgrade package_name version

# Reset to working state
git checkout pubspec.yaml pubspec.lock
dart pub get
```

---

## 📅 **Best Practices:**

1. **🧪 Test Before Committing:** Run tests after upgrade
2. **📦 Incremental Upgrades:** Update few packages at a time
3. **📋 Read Release Notes:** Check changelog for breaking changes
4. **💾 Version Control:** Commit before upgrading
5. **🔄 CI/CD Verification:** Ensure pipeline still passes

---

## ⚠️ **Notes:**

- **📊 Semantic Versioning:** Follows semver for safe upgrades
- **🔍 Pub.dev Integration:** Fetches latest versions from pub.dev
- **⚡ Performance Impact:** Larger projects take longer to analyze
- **🔒 Network Required:** Needs internet to check for updates

---

_Generated automatically by `gexd_doc`_
