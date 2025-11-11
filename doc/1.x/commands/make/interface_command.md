# `interface` Command

---

## 📝 Description

Generate interface files for abstraction layers

---

## ⚙️ Usage

```bash
gexd interface [options]
```

---

## 📖 Detailed Usage

```text
Generate interface files for abstraction layers

Usage: gexd make interface

Arguments:
  <name>          Interface name (e.g., User)
                  [Optional: Run without arguments for interactive mode]

Options:
-h, --help                             Print this usage information.
-t, --type=<basic|form|withState>        Interface type to generate
          [basic]                   Simple screen setup.
          [form]                    Form with validation.
          [withState]               Reactive data screen.

    --model=<value>                      Specify model class for CRUD interfaces (enables typed interface methods)
-l, --location=<core|shared|screen>      Interface location in project structure
          [core]                    Global application bindings in core folder.
          [shared]                  Shared bindings in shared folder.
          [screen]                  Screen-specific bindings in screen folder.

    --on=<value>                         Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)
    --force                              Force overwrite existing files without prompting

Interface Types:
  crud            Interface with common CRUD operations
  empty           Empty interface for custom method definitions

Interface Locations:
  domain          Domain layer interfaces
  repositories    Repositories layer interfaces
  datasources     Datasources layer interfaces

Examples:
  gexd make interface                                   # Interactive mode
  gexd make interface User                              # Smart mode (interactive if exists)
  gexd make interface User --type crud                  # Generate CRUD interface type
  gexd make interface User --type crud --model User     # Generate typed CRUD interface with User model
  gexd make interface User --force                      # Force overwrite without prompting
  gexd make interface User --location repositories      # Create in repositories location
  gexd make interface User --on auth                    # Create in subdirectory
```

---

## ⚙️ Options

### `--type` (`-t`)

**Description:** Interface type to generate

**Format:** `basic|form|withState`

**Available Options:**
- `basic` → Simple screen setup.
- `form` → Form with validation.
- `withState` → Reactive data screen.

---

### `--model`

**Description:** Specify model class for CRUD interfaces (enables typed interface methods)

---

### `--location` (`-l`)

**Description:** Interface location in project structure

**Format:** `core|shared|screen`

**Available Options:**
- `core` → Global application bindings in core folder.
- `shared` → Shared bindings in shared folder.
- `screen` → Screen-specific bindings in screen folder.

---

### `--on`

**Description:** Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)

---

## 🚩 Flags

- **`--force`** → Force overwrite existing files without prompting

---

_Generated automatically by `gexd_doc`_
