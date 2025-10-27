تمام ✅ وصلتني كل المعلومات 👌

📌 إذن سأجهز لك النسخة النهائية بكل الملفات مخصصة لك:
OWNER ✅: `altwaireb`
REPO ✅: `gexd`
PUB PUBLISH ✅: **مُعطّل الآن** — لكن جاهز للإضافة مستقبلاً بدون تغيير كبير

---

## ✅ جاهز يا بطل — النسخة النهائية لكل ملفات GitHub Actions

انسخ وضعهم مباشرة داخل:

```
.github/
  ├─ ISSUE_TEMPLATE/
  └─ workflows/
```

---

### ✅ 1️⃣ `.github/ISSUE_TEMPLATE/config.yml`

```yaml
blank_issues_enabled: false
contact_links:
  - name: Feature Request 💡
    url: https://github.com/altwaireb/gexd/discussions/new?category=ideas
    about: Propose a new feature or enhancement.
  - name: Ask a Question ❓
    url: https://github.com/altwaireb/gexd/discussions/new?category=q-a
    about: Seek help from community or maintainers.
```

---

### ✅ 2️⃣ `.github/workflows/formatting-analyze.yml`

✅ يعمل عند push على الـ feature branches فقط — توفيرًا للتكلفة

```yaml
name: Formatting & Analyze ✨

on:
  push:
    branches:
      - 'feature/**'
      - 'hotfix/**'

jobs:
  format-analyze:
    runs-on: ubuntu-latest
    timeout-minutes: 5

    steps:
      - uses: actions/checkout@v5

      - uses: dart-lang/setup-dart@v1
        with:
          sdk: stable

      - uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: ${{ runner.os }}-pub-${{ hashFiles('pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-

      - name: Install dependencies
        run: dart pub get

      - name: Check formatting
        run: dart format --output=none --set-exit-if-changed lib/ test/ bin/

      - name: Analyze code
        run: dart analyze --fatal-warnings --fatal-infos
```

---

### ✅ 3️⃣ `.github/workflows/run-tests.yml`

✅ عند الـ Pull Request إلى `develop` أو `main`

```yaml
name: Run Tests ✅

on:
  pull_request:
    types: [opened, synchronize, reopened]
    branches:
      - develop
      - main

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - uses: actions/checkout@v5

      - uses: dart-lang/setup-dart@v1
        with:
          sdk: stable

      - uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: ${{ runner.os }}-pub-${{ hashFiles('pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-

      - name: Install dependencies
        run: dart pub get

      - name: Build runner
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Run unit tests
        run: dart test --tags unit --reporter github --concurrency=4

      - name: Run build tests
        run: dart test --tags build --reporter github --concurrency=4
```

---

### ✅ 4️⃣ `.github/workflows/release.yml`

✅ يشتغل فقط عند وجود tag مثل: `v1.0.0`
✅ مثالي لعمل Release لـ gexd CLI
✅ E2E disabled الآن (نضيفها عند جاهزية الأوامر أكثر)

```yaml
name: Release 🚀

on:
  push:
    tags:
      - 'v*.*.*'

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    timeout-minutes: 20

    steps:
      - uses: actions/checkout@v5

      - uses: dart-lang/setup-dart@v1
        with:
          sdk: stable

      - uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: ${{ runner.os }}-pub-${{ hashFiles('pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-

      - name: Install dependencies
        run: dart pub get

      - name: Run unit tests (CI Safety)
        run: dart test --tags unit --reporter expanded

      - name: Compile executable
        run: dart compile exe bin/gexd.dart -o build/gexd

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: build/gexd
```

> ✅ جاهز لإضافة `pub publish` عندما تطلب ذلك
> (نضيف خطوة dart pub publish ب token سرّي)

---

### ✅ 5️⃣ `.github/workflows/dependabot-auto-merge.yml`

```yaml
name: Dependabot Auto Merge 🤖

on:
  pull_request_target:

permissions:
  pull-requests: write
  contents: write

jobs:
  dependabot:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    if: ${{ github.actor == 'dependabot[bot]' }}

    steps:
      - name: Fetch metadata
        id: metadata
        uses: dependabot/fetch-metadata@v2
        with:
          github-token: "${{ secrets.GITHUB_TOKEN }}"

      - name: Auto merge minor updates
        if: ${{ steps.metadata.outputs.update-type == 'version-update:semver-minor' }}
        run: gh pr merge --auto --merge "$PR_URL"
        env:
          PR_URL: ${{ github.event.pull_request.html_url }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Auto merge patch updates
        if: ${{ steps.metadata.outputs.update-type == 'version-update:semver-patch' }}
        run: gh pr merge --auto --merge "$PR_URL"
        env:
          PR_URL: ${{ github.event.pull_request.html_url }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 🚀 جاهز للاستخدام — بدون أي تكاليف إضافية

| الحالة              | ما الذي يحدث؟                    |
| ------------------- | -------------------------------- |
| push إلى feature    | ✅ Formatting + Analyze فقط       |
| PR إلى develop/main | ✅ Unit + Build Tests             |
| Tag إصدار           | ✅ Release + Build أكيد           |
| Dependabot          | ✅ Auto Merge للـ updates البسيطة |

---

## 🎯 ميزة إضافية جاهزة لك

يمكنني إضافة:
✅ شارات (Badges) للـREADME
✅ Codecov
✅ Workflow يشغّل Dart Fix تلقائيًا
✅ E2E عندما تتضح أوامر CLI

---

## ما هو الخطوة التالية؟

بعد أن ترفع هذه الملفات…

سأحتاج منك فقط:
🔹 أن تعلّمني بمجرد أول Push أو أول PR
وسأراقب CI logs معك إلى أن يصبح ✅ أخضر 100%

---

إذا تحب، أقدر أضيف لك الآن:
✅ Badges للوحة الـ README
✅ حماية لفروع: main + develop
✅ إعدادات PR تلقائية

هل تريدني أقوم بذلك الآن؟ 🚀






















رائع ✅ إذن سأجهز لك **ملف E2E مستقل جاهز للاستخدام**، مع جميع الإعدادات المحترفة لتقليل التكلفة، استخدام matrix مضبوط، caching، وإمكانية التشغيل يدويًا عند الحاجة.

---

### `.github/workflows/e2e-tests.yml`

```yaml
name: E2E Tests 🚀

on:
  pull_request:
    branches:
      - develop
      - main
  workflow_dispatch: # لتشغيل يدوي عند الحاجة

jobs:
  e2e-tests:
    name: Run E2E Tests
    runs-on: ubuntu-latest
    timeout-minutes: 20
    strategy:
      fail-fast: false
      matrix:
        test_group: [
          'CreateCommand E2E Tests',
          'InitCommand E2E Tests',
          'ScreenCommand E2E Tests',
          'BindingCommand E2E Tests',
          'ServiceCommand E2E Tests',
          'ViewCommand E2E Tests',
          'ModelCommand E2E Tests'
        ]

    steps:
      - name: Checkout repository
        uses: actions/checkout@v5

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Cache pub packages
        uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: ${{ runner.os }}-pub-${{ hashFiles('pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-

      - name: Install dependencies
        run: dart pub get

      - name: Run E2E test - ${{ matrix.test_group }}
        run: dart test --tags e2e --plain-name "${{ matrix.test_group }}" --reporter expanded --concurrency=1
        timeout-minutes: 20
```

---

### 🔹 ميزات هذا الملف

1. **مستقل تمامًا** عن CI و Unit Tests
2. **Matrix مضبوط** لكل مجموعة E2E كما طلبت
3. **Cache** لحزم Dart لتسريع التشغيل
4. **workflow_dispatch** لتشغيل يدوي عند الحاجة — لتوفير Action Minutes
5. **Timeout مضبوط** لكل خطوة على 20 دقيقة لتجنب توقفات غير محسوبة

---

💡 **اقتراح مستقبلي:**
يمكن إضافة شرط **تشغيل E2E فقط عند tag** عند إصدار نسخة رئيسية، لتوفير أكثر للـ Action Minutes.

---

إذا أحببت، أقدر الآن أصنع لك **نسخة متكاملة لكل Workflows في `.github/workflows/`** جاهزة للعمل **مع كل الربط بين CI / E2E / Release / Dependabot** بحيث يصبح مشروعك جاهز تمامًا للإنتاج والصيانة ✅

هل تريد أن أفعل ذلك الآن؟








تمام 🔥 إذن سأجهز لك **نسخة متكاملة لكل ملفات Workflows** في `.github/workflows/` بحيث تكون جاهزة للإنتاج والصيانة، مع تنظيم كامل:

* **CI الرئيسي**: Formatting + Analyze + Unit/Build Tests
* **E2E مستقل**: كما صممناه للتشغيل على PR أو يدويًا
* **Release**: بناء الـ CLI عند وجود tag، مع إمكانية إضافة pub.dev لاحقًا
* **Dependabot Auto Merge**: لتحديث الحزم تلقائيًا
* **Caching متقن لكل Workflow** لتقليل وقت التنفيذ وتوفير Action Minutes

---

### الهيكلة النهائية المقترحة

```
.github/workflows/
 ├── formatting-analyze.yml   # Formatting + Analyze (feature branches)
 ├── run-tests.yml            # Unit + Build Tests (PR إلى develop/main)
 ├── e2e-tests.yml            # End-to-End Tests (PR + يدوي)
 ├── release.yml              # Build / Release / لاحقاً pub.dev
 └── dependabot-auto-merge.yml
```

---

### 1️⃣ `formatting-analyze.yml`

```yaml
name: Formatting & Analyze ✨

on:
  push:
    branches:
      - 'feature/**'
      - 'hotfix/**'

jobs:
  format-analyze:
    runs-on: ubuntu-latest
    timeout-minutes: 5

    steps:
      - uses: actions/checkout@v5
      - uses: dart-lang/setup-dart@v1
        with:
          sdk: stable
      - uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: ${{ runner.os }}-pub-${{ hashFiles('pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-
      - name: Install dependencies
        run: dart pub get
      - name: Check formatting
        run: dart format --output=none --set-exit-if-changed lib/ test/ bin/
      - name: Analyze code
        run: dart analyze --fatal-warnings --fatal-infos
```

---

### 2️⃣ `run-tests.yml`

```yaml
name: Run Tests ✅

on:
  pull_request:
    types: [opened, synchronize, reopened]
    branches:
      - develop
      - main

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - uses: actions/checkout@v5
      - uses: dart-lang/setup-dart@v1
        with:
          sdk: stable
      - uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: ${{ runner.os }}-pub-${{ hashFiles('pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-
      - name: Install dependencies
        run: dart pub get
      - name: Build runner
        run: dart run build_runner build --delete-conflicting-outputs
      - name: Run unit tests
        run: dart test --tags unit --reporter github --concurrency=4
      - name: Run build tests
        run: dart test --tags build --reporter github --concurrency=4
```

---

### 3️⃣ `e2e-tests.yml`

```yaml
name: E2E Tests 🚀

on:
  pull_request:
    branches:
      - develop
      - main
  workflow_dispatch:

jobs:
  e2e-tests:
    name: Run E2E Tests
    runs-on: ubuntu-latest
    timeout-minutes: 20
    strategy:
      fail-fast: false
      matrix:
        test_group: [
          'CreateCommand E2E Tests',
          'InitCommand E2E Tests',
          'ScreenCommand E2E Tests',
          'BindingCommand E2E Tests',
          'ServiceCommand E2E Tests',
          'ViewCommand E2E Tests',
          'ModelCommand E2E Tests'
        ]

    steps:
      - uses: actions/checkout@v5
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: ${{ runner.os }}-pub-${{ hashFiles('pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-
      - name: Install dependencies
        run: dart pub get
      - name: Run E2E test - ${{ matrix.test_group }}
        run: dart test --tags e2e --plain-name "${{ matrix.test_group }}" --reporter expanded --concurrency=1
        timeout-minutes: 20
```

---

### 4️⃣ `release.yml`

```yaml
name: Release 🚀

on:
  push:
    tags:
      - 'v*.*.*'

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    timeout-minutes: 20

    steps:
      - uses: actions/checkout@v5
      - uses: dart-lang/setup-dart@v1
        with:
          sdk: stable
      - uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: ${{ runner.os }}-pub-${{ hashFiles('pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-
      - name: Install dependencies
        run: dart pub get
      - name: Run unit tests
        run: dart test --tags unit --reporter expanded
      - name: Compile executable
        run: dart compile exe bin/gexd.dart -o build/gexd
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: build/gexd
```

---

### 5️⃣ `dependabot-auto-merge.yml`

```yaml
name: Dependabot Auto Merge 🤖

on:
  pull_request_target:

permissions:
  pull-requests: write
  contents: write

jobs:
  dependabot:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    if: ${{ github.actor == 'dependabot[bot]' }}

    steps:
      - name: Fetch metadata
        id: metadata
        uses: dependabot/fetch-metadata@v2
        with:
          github-token: "${{ secrets.GITHUB_TOKEN }}"

      - name: Auto merge minor updates
        if: ${{ steps.metadata.outputs.update-type == 'version-update:semver-minor' }}
        run: gh pr merge --auto --merge "$PR_URL"
        env:
          PR_URL: ${{ github.event.pull_request.html_url }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Auto merge patch updates
        if: ${{ steps.metadata.outputs.update-type == 'version-update:semver-patch' }}
        run: gh pr merge --auto --merge "$PR_URL"
        env:
          PR_URL: ${{ github.event.pull_request.html_url }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

### 🔹 ملاحظات مهمة

1. كل Workflow **مستقل وموفر للـ Action Minutes**
2. E2E يمكن تشغيله يدويًا فقط عند الحاجة باستخدام `workflow_dispatch`
3. نشر pub.dev جاهز للإضافة لاحقًا عند إصدار tag
4. Dependabot يدمج التحديثات البسيطة تلقائيًا

---

إذا أحببت، أقدر أجهز لك **ملف README Badges + حماية الفروع + إعدادات PR تلقائية** لتكمل CI/CD على أعلى مستوى.

هل تريد أن أفعل ذلك الآن؟











تمام 🔥 إذن سأجهز لك **ملف README Badges** جاهز، يعرض حالة كل Workflow مباشرة على GitHub، بحيث ترى:

* Formatting ✅
* Analyze ✅
* Unit Tests ✅
* E2E ✅
* Release ✅

---

### مثال كامل لإضافة Badges في README.md

```markdown
# Gexd CLI

![Formatting](https://github.com/altwaireb/gexd/actions/workflows/formatting-analyze.yml/badge.svg)
![Unit & Build Tests](https://github.com/altwaireb/gexd/actions/workflows/run-tests.yml/badge.svg)
![E2E Tests](https://github.com/altwaireb/gexd/actions/workflows/e2e-tests.yml/badge.svg)
![Release](https://github.com/altwaireb/gexd/actions/workflows/release.yml/badge.svg)
![Dependabot](https://github.com/altwaireb/gexd/actions/workflows/dependabot-auto-merge.yml/badge.svg)

---

## وصف المشروع

Gexd هو CLI متطور لإدارة المشاريع باستخدام Dart/Flutter، يدعم:  
- إنشاء شاشات و Commands و Services  
- اختبارات Unit و Build و E2E  
- نشر الإصدار مع GitHub Release  
- إدارة التحديثات التلقائية عبر Dependabot
```

---

### 🔹 ملاحظات

1. كل Badge **يشير مباشرة إلى Workflow محدد**
2. Badges ستظهر باللون **أخضر عند النجاح، أحمر عند الفشل**
3. يمكنك إضافة Badges إضافية لاحقًا لأي Workflow جديد

---

إذا أحببت، أقدر الآن أصنع لك **نسخة جاهزة تمامًا من README.md كاملة مع كل الأقسام الأساسية** + Badges + تعليمات تشغيل CI/CD، بحيث تكون جاهزة للنشر على GitHub مباشرة.

هل أصنعها لك الآن؟


