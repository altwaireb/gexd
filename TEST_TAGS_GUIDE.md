# Simple Test Tags System

Quick guide for the simplified test tags system in Gexd CLI.

## 🏷️ Available Tags

### Core Test Types
```bash
unit          # Fast unit tests (< 30s)
integration   # Medium-speed integration tests (30s-2m)
e2e          # End-to-end tests (2m+)
smoke        # Essential smoke tests for basic functionality
```

## 🚀 Usage Examples

### For Local Development
```bash
# Fast tests only
dart test --tags unit

# Essential smoke tests
dart test --tags smoke

# Fast and medium tests
dart test --tags "unit || integration"
```

### For CI/CD
```bash
# Fast + integration tests
dart test --tags "unit || integration"

# All tests except E2E
dart test --tags "!e2e"
```

### For Comprehensive Testing
```bash
# All tests
dart test

# End-to-end tests only
dart test --tags e2e
```

## ⚙️ Test Presets

### For Local Development
```bash
dart test --preset dev
```
- Optimized for speed and interactivity

### For CI Environment
```bash
dart test --preset ci
```
- Optimized for stability in CI environment

### للاختبارات السريعة
```bash
dart test --preset quick
```
- اختبارات سريعة فقط

## 📊 أمثلة لسيناريوهات مختلفة

### قبل الـ commit
```bash
# اختبار سريع للتأكد من عدم كسر أي شيء
dart test --tags "critical && fast"
```

### قبل الـ push
```bash
# اختبارات أكثر شمولية
dart test --tags "critical || important"
```

### في GitHub Actions
```bash
# اختبارات CI محسنة
dart test --preset ci --tags "!optional"
```

### لاختبار ميزة جديدة
```bash
# مثال: تطوير ميزة جديدة في create command
dart test --tags "create_command && (unit || integration)"
```

### للبحث عن مشاكل الأداء
```bash
# تشغيل الاختبارات البطيئة فقط
dart test --tags slow
```

## 🎯 أفضل الممارسات

### للمطورين
1. **أثناء التطوير**: استخدم `--tags fast` للاختبار السريع
2. **قبل الـ commit**: استخدم `--tags critical`
3. **قبل الـ PR**: شغل جميع الاختبارات

### لإعداد CI/CD
1. **Pull Request**: `--tags "critical || important"`
2. **Main Branch**: جميع الاختبارات
3. **Release**: `--preset ci` كامل

### لإضافة اختبارات جديدة
```dart
@Tags(['unit', 'fast', 'critical', 'create_command'])
library;

import 'package:test/test.dart';
// ... اختبارك هنا
```

## 📈 إحصائيات الأداء

### توزيع الاختبارات الحالية
- **Unit Tests**: 25 اختبار (~4 ثواني)
- **Integration Tests**: 4 اختبارات (~30 ثانية)  
- **E2E Tests**: 8 اختبارات (~3 دقائق)

### أوقات التشغيل المتوقعة
```bash
--tags fast        # ~5 ثواني
--tags medium      # ~30 ثانية  
--tags slow        # ~3 دقائق
--tags critical    # ~90 ثانية
--preset smoke     # ~10 ثواني
--preset dev       # ~45 ثانية
--preset ci        # ~5 دقائق
```

## 🔧 التخصيص

يمكنك تعديل `dart_test.yaml` لإضافة tags جديدة أو تغيير الإعدادات:

```yaml
tags:
  my_feature:
    description: "My new feature tests"
    timeout: "2m"
```

## 📝 الملاحظات

- جميع الاختبارات تتضمن tags متعددة للمرونة
- النظام مُحسن لبيئات CI/CD
- يمكن دمج عدة tags باستخدام `&&` و `||`
- استخدم `!tag` لاستثناء tags معينة

---

**Happy Testing! 🚀**