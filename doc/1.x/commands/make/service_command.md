# `service` Command

---

## 📝 Description

Generate service files

---

## ⚙️ Usage

```bash
gexd service [options]
```

---

## 📖 Detailed Usage

```text
Generate service files

Usage: gexd make service

Arguments:
  <name>          Service name (e.g., Auth, Profile)
                  [Optional: Run without arguments for interactive mode]

Options:
-h, --help                             Print this usage information.
    --on=<value>                         Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)
    --force                              Force overwrite existing files without prompting

Examples:
  gexd make service                                      # Interactive mode
  gexd make service Api                                  # Smart mode (interactive if exists)

  # Service (use --on for custom subdirectory):
  gexd make service Storage                              # service
  gexd make service App --on settings                    # service in subdirectory
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
