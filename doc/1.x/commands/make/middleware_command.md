# `middleware` Command

---

## 📝 Description

Generate middleware files

---

## ⚙️ Usage

```bash
gexd middleware [options]
```

---

## 📖 Detailed Usage

```text
Generate middleware files

Usage: gexd make middleware

Arguments:
  <name>          Service name (e.g., Auth, Profile)
                  [Optional: Run without arguments for interactive mode]

Options:
-h, --help                             Print this usage information.
    --on=<value>                         Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)
    --force                              Force overwrite existing files without prompting

Examples:
  gexd make middleware                                      # Interactive mode
  gexd make middleware Api                                  # Smart mode (interactive if exists)

  # Middleware (use --on for custom subdirectory):
  gexd make middleware Storage                              # middleware
  gexd make middleware App --on settings                    # middleware in subdirectory
```

---

## ⚙️ Options

### `--on`

**Description:** Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)

---

## 🚩 Flags

- **`--force`** → Force overwrite existing files without prompting

---

_Generated automatically by `gexd_doc`_
