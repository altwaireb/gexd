# `entity` Command

---

## 📝 Description

Generate domain entity files for supported project templates

---

## ⚙️ Usage

```bash
gexd entity [options]
```

---

## 📖 Detailed Usage

```text
Generate domain entity files for supported project templates

Usage: gexd make entity

Arguments:
  <name>          Entity name (e.g., User, Profile, Product)
                  [Optional: Run without arguments for interactive mode]

Options:
-h, --help                             Print this usage information.
-f, --file=<value>                       Path to JSON file for entity generation
-u, --url=<value>                        URL to fetch JSON data for entity generation
-s, --style=<value>                      Choose entity generation style
    --on=<value>                         Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)
    --with-model                         Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)
    --force                              Force overwrite existing files without prompting

Examples:
  gexd make entity                                       # Interactive mode
  gexd make entity User                                  # Simple entity from template

  # Entity from JSON file:
  gexd make entity User --file assets/user.json         # From local file

  # Entity from API endpoint:
  gexd make entity User --url https://api.example.com/user/123

  # Entity with different styles:
  gexd make entity User --style plain                   # Plain class
  gexd make entity User --style immutable               # Immutable with Equatable (default)
  gexd make entity User --style freezed                 # Freezed style

  # Entity with corresponding Model:
  gexd make entity User --with-model                    # Generate both entity and model

  # Entity in subdirectory:
  gexd make entity User --on auth/user                  # Entity in subdirectory

  # Force overwrite:
  gexd make entity User --force                         # Skip confirmation prompts
```

---

## ⚙️ Options

### `--file` (`-f`)

**Description:** Path to JSON file for entity generation

---

### `--url` (`-u`)

**Description:** URL to fetch JSON data for entity generation

---

### `--style` (`-s`)

**Description:** Choose entity generation style

---

### `--on`

**Description:** Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)

---

## 🚩 Flags

- **`--with-model`** → Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)
- **`--force`** → Force overwrite existing files without prompting

---

_Generated automatically by `gexd_doc`_
