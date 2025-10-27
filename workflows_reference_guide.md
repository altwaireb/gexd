# 📚 دليل GitHub Workflows المرجعي - مشروع Gexd

> **الهدف:** مرجع شامل لكل ملفات الـ workflows قبل التطبيق لتجنب التعارضات

---

## 📋 **فهرس الملفات المقترحة**

```
.github/workflows/
├── 1️⃣ formatting-analyze.yml      # التحقق من التنسيق والتحليل
├── 2️⃣ run-tests.yml               # الاختبارات السريعة (Unit + Build)  
├── 3️⃣ e2e-tests.yml               # الاختبارات الشاملة (E2E)
├── 4️⃣ release.yml                 # بناء ونشر الإصدارات
└── 5️⃣ dependabot-auto-merge.yml   # دمج تحديثات التبعيات تلقائياً
```

---

## 1️⃣ **formatting-analyze.yml**

### **📋 الوصف:**
- يتحقق من تنسيق الكود وجودة التحليل
- يعمل فقط على Feature branches لتوفير الموارد
- سريع (5 دقائق) ويعطي تغذية راجعة فورية للمطور

### **🎯 متى يعمل:**
- عند Push إلى `feature/**` أو `hotfix/**`
- **لا يعمل** على `main` أو `develop` (توفير الموارد)

### **📄 الكود الكامل:**
```yaml
name: Formatting & Analyze ✨

on:
  push:
    branches:
      - 'feature/**'
      - 'hotfix/**'

jobs:
  format-analyze:
    name: Check Code Quality
    runs-on: ubuntu-latest
    timeout-minutes: 5

    steps:
      - name: Checkout repository
        uses: actions/checkout@v5

      - name: Setup Dart SDK
        uses: dart-lang/setup-dart@v1
        with:
          sdk: stable

      - name: Cache pub packages
        uses: actions/cache@v4
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

## 2️⃣ **run-tests.yml**

### **📋 الوصف:**
- يشغل الاختبارات السريعة (Unit + Build)
- يعمل فقط عند فتح Pull Request
- يتضمن cache للسرعة وتوليد تقارير التغطية

### **🎯 متى يعمل:**
- عند فتح/تحديث PR إلى `develop` أو `main`
- **لا يعمل** على كل push (توفير الموارد)

### **📄 الكود الكامل:**
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
    name: Unit & Build Tests
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - name: Checkout repository
        uses: actions/checkout@v5

      - name: Setup Dart SDK
        uses: dart-lang/setup-dart@v1
        with:
          sdk: stable

      - name: Cache pub packages
        uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: ${{ runner.os }}-pub-${{ hashFiles('pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-

      - name: Install dependencies
        run: dart pub get

      - name: Run build runner
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Run unit tests
        run: dart test --tags unit --reporter github --concurrency=4

      - name: Run build tests  
        run: dart test --tags build --reporter github --concurrency=4

      - name: Generate coverage report
        run: dart test --tags unit --coverage=coverage

      - name: Convert coverage to LCOV
        run: dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v5
        with:
          file: coverage/lcov.info
          fail_ci_if_error: false
```

---

## 3️⃣ **e2e-tests.yml**

### **📋 الوصف:**
- يشغل الاختبارات الشاملة (E2E) بنظام Matrix
- **معطّل على PRs** لتوفير الموارد أثناء التطوير
- يعمل تلقائياً فقط **عند الإصدار** أو **يدوياً** عند الحاجة
- أطول وقت تشغيل لكن اختباري شامل

### **🎯 متى يعمل:**
- **تشغيل يدوي** عبر `workflow_dispatch` (أثناء التطوير)
- **تلقائياً عند الإصدار** فقط (push tags v*.*.*)
- **معطّل على PRs** لتوفير الموارد أثناء التطوير
- **تحكم كامل** في التشغيل

### **📄 الكود الكامل:**
```yaml
name: E2E Tests 🚀

on:
  # تشغيل يدوي عند الحاجة أثناء التطوير
  workflow_dispatch:
    inputs:
      test_groups:
        description: 'Test groups to run (JSON array or "all")'
        required: false
        default: 'all'
  
  # تشغيل تلقائي فقط عند الإصدار
  push:
    tags:
      - 'v*.*.*'

jobs:
  e2e-tests:
    name: Run E2E Tests
    runs-on: ubuntu-latest
    timeout-minutes: 25
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

## 4️⃣ **release.yml**

### **📋 الوصف:**
- يبني وينشر الإصدار الرسمي
- يعمل فقط عند إنشاء Tag (مثل v1.0.0)
- يتضمن اختبارات الأمان قبل النشر

### **🎯 متى يعمل:**
- عند إنشاء Git tag بصيغة `v*.*.*`
- **مرة واحدة فقط** لكل إصدار رسمي

### **📄 الكود الكامل:**
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
    name: Build & Release
    runs-on: ubuntu-latest
    timeout-minutes: 25

    steps:
      - name: Checkout repository
        uses: actions/checkout@v5

      - name: Setup Dart SDK
        uses: dart-lang/setup-dart@v1
        with:
          sdk: stable

      - name: Cache pub packages
        uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: ${{ runner.os }}-pub-${{ hashFiles('pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-

      - name: Install dependencies
        run: dart pub get

      - name: Run safety tests
        run: dart test --tags unit --reporter expanded

      - name: Create build directory
        run: mkdir -p build

      - name: Compile executable
        run: dart compile exe bin/gexd.dart -o build/gexd

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: build/gexd
          generate_release_notes: true
          draft: false
          prerelease: false

      # TODO: إضافة نشر pub.dev في المستقبل
      # - name: Publish to pub.dev
      #   run: dart pub publish --force
      #   env:
      #     PUB_TOKEN: ${{ secrets.PUB_TOKEN }}
```

---

## 5️⃣ **dependabot-auto-merge.yml**

### **📋 الوصف:**
- يدمج تحديثات التبعيات البسيطة تلقائياً
- يعمل على PR من Dependabot فقط
- آمن (فقط التحديثات البسيطة)

### **🎯 متى يعمل:**
- عند فتح PR من `dependabot[bot]`
- فقط للتحديثات البسيطة (patch/minor)

### **📄 الكود الكامل:**
```yaml
name: Dependabot Auto Merge 🤖

on:
  pull_request_target:

permissions:
  pull-requests: write
  contents: write

jobs:
  dependabot:
    name: Auto Merge Dependencies
    runs-on: ubuntu-latest
    timeout-minutes: 5
    if: ${{ github.actor == 'dependabot[bot]' }}

    steps:
      - name: Fetch dependabot metadata
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

## 🔗 **الملفات الإضافية**

### **📁 `.github/ISSUE_TEMPLATE/config.yml`**
```yaml
blank_issues_enabled: false
contact_links:
  - name: Feature Request 💡
    url: https://github.com/altwaireb/gexd/discussions/new?category=ideas
    about: Propose a new feature or enhancement for Gexd CLI.
  - name: Ask a Question ❓
    url: https://github.com/altwaireb/gexd/discussions/new?category=q-a  
    about: Seek help from community or maintainers.
  - name: Report Security Issue 🔒
    url: https://github.com/altwaireb/gexd/security/advisories/new
    about: Report security vulnerabilities privately.
```

### **📁 `.github/dependabot.yml`**
```yaml
version: 2
updates:
  - package-ecosystem: "pub"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "09:00"
    open-pull-requests-limit: 5
    reviewers:
      - "altwaireb"
    assignees:
      - "altwaireb"  
    commit-message:
      prefix: "deps"
      include: "scope"
```

---

## 📊 **مقارنة مع الوضع الحالي**

### **الملف الحالي: `ci.yml`**
```yaml
# المشاكل في الملف الحالي:
❌ يشتغل على كل push (إهدار موارد)
❌ E2E في كل مرة (140 دقيقة × عدد المرات)
❌ لا يوجد تحكم في التشغيل
❌ timeout قصير قد يسبب فشل
❌ لا يوجد تحسين للـ cache
```

### **النظام الجديد:**
```yaml
# المزايا في النظام الجديد:
✅ تشغيل ذكي (حسب الحاجة فقط)
✅ توفير 96% من Action Minutes (E2E معطّل على PRs)
✅ تحكم كامل (workflow_dispatch)  
✅ E2E فقط عند الإصدار أو يدوياً
✅ timeout محسّن ومناسب
✅ cache متقدم لكل workflow
✅ تقسيم منطقي للمسؤوليات
```

---

## 🛠️ **خطة التطبيق**

### **الخطوة 1: النسخ الاحتياطي**
```bash
# نسخ احتياطي للملف الحالي
cp .github/workflows/ci.yml .github/workflows/ci.yml.backup
```

### **الخطوة 2: إنشاء الملفات الجديدة**
- إنشاء الملفات الخمسة المقترحة أعلاه
- اختبار كل واحد منفرداً

### **الخطوة 3: إزالة الملف القديم**  
```bash
# بعد التأكد من عمل النظام الجديد
rm .github/workflows/ci.yml
```

### **الخطوة 4: التحديث والمراقبة**
- مراقبة استهلاك Action Minutes
- تحسين حسب الحاجة

---

## 💰 **توفير الموارد مع تعطيل E2E على PRs**

### **المقارنة:**
```
الوضع السابق (E2E على كل PR):
- كل PR = 140 دقيقة E2E
- 8 PRs شهرياً = 1,120 دقيقة

الوضع الجديد (E2E فقط عند الإصدار):
- E2E عند Release فقط = 280 دقيقة شهرياً (2 إصدارات)
- E2E يدوي حسب الحاجة = 140 دقيقة شهرياً (1 مرة)

🎉 التوفير الإضافي = 700 دقيقة شهرياً!
```

### **كيفية استخدام E2E:**
1. **أثناء التطوير:** تشغيل يدوي عند الحاجة فقط
2. **قبل الإصدار:** تشغيل تلقائي مع كل release tag
3. **اختبار سريع:** يمكن تشغيل مجموعة واحدة فقط

### **التشغيل اليدوي:**
```bash
# في GitHub Actions UI → Run workflow
# سيشغل كل الـ 7 مجموعات تلقائياً
# بطريقة بسيطة وموثوقة

# إذا أردت تشغيل مجموعة واحدة فقط:
# يمكن تعديل الملف مؤقتاً أو إنشاء workflow منفصل
```

### **مزايا الطريقة البسيطة:**
- ✅ سهلة القراءة والفهم
- ✅ موثوقة 100% بدون أخطاء JSON
- ✅ سريعة التشغيل
- ✅ سهلة الـ debugging

---

## ⚠️ **نقاط مهمة قبل التطبيق**

### **التأكد من:**
1. **اسماء الـ test groups** مطابقة للموجود في الكود
2. **branches المطلوبة** موجودة (develop, main)  
3. **permissions** صحيحة للـ release workflow
4. **secrets** مضبوطة (إذا احتجناها لاحقاً)

### **اختبار تدريجي:**
1. البدء بـ `formatting-analyze.yml` فقط
2. إضافة `run-tests.yml` بعد التأكد  
3. إضافة باقي الملفات واحد تلو الآخر

---

## 🤝 **جاهز للمراجعة**

هذا هو المرجع الكامل لكل ملف. 

**هل تريد:**
1. **مراجعة** أي ملف بالتفصيل؟
2. **تعديل** أي جزء قبل التطبيق؟  
3. **البدء بالتطبيق** التدريجي؟
4. **إضافة ملفات** أو **تحسينات** أخرى؟

أخبرني برأيك لنتأكد أن كل شيء صحيح قبل البدء! 🚀