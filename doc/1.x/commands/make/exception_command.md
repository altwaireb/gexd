# `exception` Command

---

## 📝 Description

Generate exception files

---

## ⚙️ Usage

```bash
gexd exception [options]
```

---

## 📖 Detailed Usage

```text
Generate exception files

Usage: gexd make exception

Arguments:
  <name>          Service name (e.g., Network, Validation)
                  [Optional: Run without arguments for interactive mode]

Options:
-h, --help                             Print this usage information.
    --on=<value>                         Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)
    --force                              Force overwrite existing files without prompting

Examples:
  gexd make exception                                      # Interactive mode
  gexd make exception Network                              # Smart mode (interactive if exists)

  # Exception (use --on for custom subdirectory):
  gexd make exception Network                              # exception
  gexd make exception InputValidation --on validations     # exception in subdirectory
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
