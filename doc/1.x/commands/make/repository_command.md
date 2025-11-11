# `repository` Command

---

## 📝 Description

Generate repository files for data access layers

---

## ⚙️ Usage

```bash
gexd repository [options]
```

---

## 📖 Detailed Usage

```text
Generate repository files for data access layers

Usage: gexd make repository

Arguments:
  <name>          Interface name (e.g., User)
                  [Optional: Run without arguments for interactive mode]

Options:
-h, --help                             Print this usage information.
-t, --type=<basic|form|withState>        Interface type to generate
          [basic]                   Simple screen setup.
          [form]                    Form with validation.
          [withState]               Reactive data screen.

    --model=<value>                      Specify model class for CRUD repositories (enables typed repository methods)
    --entity=<value>                     Specify entity class for CRUD repositories (enables typed repository methods with entities)
    --on=<value>                         Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)
    --interface                          Force overwrite existing files without prompting

Repository Types:
  crud            Repository with common CRUD operations
  empty           Empty repository for custom method definitions

Examples:
  gexd make repository                                   # Interactive mode
  gexd make repository User                              # Smart mode (interactive if exists)
  gexd make repository User --type crud                  # Generate CRUD repository type
  gexd make repository User --type crud --interface      # Generate CRUD repository type with interface
  gexd make repository User --type crud --model User     # Generate typed CRUD repository with User model
  gexd make repository User --type crud --entity User    # Generate typed CRUD repository with User entity
  gexd make repository User --force                      # Force overwrite without prompting
  gexd make repository User --on auth                    # Create in subdirectory
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

**Description:** Specify model class for CRUD repositories (enables typed repository methods)

---

### `--entity`

**Description:** Specify entity class for CRUD repositories (enables typed repository methods with entities)

---

### `--on`

**Description:** Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)

---

## 🚩 Flags

- **`--interface`** → Force overwrite existing files without prompting

---

_Generated automatically by `gexd_doc`_
