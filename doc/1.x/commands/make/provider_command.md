# `provider` Command

---

## 📝 Description

Generate provider files

---

## ⚙️ Usage

```bash
gexd provider [options]
```

---

## 📖 Detailed Usage

```text
Generate provider files

Usage: gexd make provider

Arguments:
  <name>          Provider name (e.g., User)
                  [Optional: Run without arguments for interactive mode]

Options:
-h, --help                             Print this usage information.
    --on=<value>                         Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)
    --force                              Force overwrite existing files without prompting

Examples:
  gexd make provider                                      # Interactive mode
  gexd make provider User                                 # Smart mode (interactive if exists)

  # Provider (use --on for custom subdirectory):
  gexd make provider Item                                 # provider
  gexd make provider Project --on foo                     # provider in subdirectory
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
