# 🌍 Gexd Locale Features & Usage Examples

This document demonstrates the powerful translation features available in Gexd-generated locale files.

## ✨ Key Features

### 1. 🔗 Variable Replacement with `trVars`
Replace named variables in translation strings dynamically.

### 2. 🔢 Smart Pluralization with `trCount`
Handle pluralization for different languages with universal support.

### 3. 🔑 Type-Safe Keys with `LocaleKeys`
Use generated constants for compile-time safety and better IDE support.

---

## 🔗 Variable Replacement Examples

### Basic Variable Replacement
**JSON Definition:**
```json
{
  "welcome": "Welcome {name}",
  "greeting": "Good {time}, {name}!"
}
```

**Flutter Usage:**
```dart
// Simple variable replacement
Text('welcome'.trVars({'name': 'John'}))
// Output: "Welcome John"

// Type-safe with LocaleKeys (recommended)
Text(LocaleKeys.welcome.trVars({'name': 'John'}))
// Output: "Welcome John" + compile-time safety

// Multiple variables
Text('greeting'.trVars({'name': 'John', 'time': 'morning'}))
Text(LocaleKeys.greeting.trVars({'name': 'John', 'time': 'morning'}))
// Output: "Good morning, John!"

// App version with variable
Text('app.version'.trVars({'version': '1.2.0'}))
Text(LocaleKeys.app_version.trVars({'version': '1.2.0'}))
// Output: "Version 1.2.0"
```

### Validation Messages with Variables
**JSON Definition:**
```json
{
  "validation": {
    "required": "{field} is required",
    "passwordMinLength": "Password must be at least {min} characters"
  }
}
```

**Flutter Usage:**
```dart
// Dynamic field validation
Text('validation.required'.trVars({'field': 'Email'}))
Text(LocaleKeys.validation_required.trVars({'field': 'Email'}))
// Output: "Email is required"

// Dynamic minimum length
Text('validation.passwordMinLength'.trVars({'min': '8'}))
Text(LocaleKeys.validation_passwordMinLength.trVars({'min': '8'}))
// Output: "Password must be at least 8 characters"
```

---

## 🔢 Smart Pluralization Examples

### Basic Pluralization (English)
**JSON Definition:**
```json
{
  "items": {
    "__count": {
      "zero": "No items",
      "one": "One item",
      "other": "{count} items"
    }
  }
}
```

**Flutter Usage:**
```dart
// Zero items
Text('items'.trCount({'count': '0'}))
Text(LocaleKeys.items.trCount({'count': '0'}))
// Output: "No items"

// Single item
Text('items'.trCount({'count': '1'}))
Text(LocaleKeys.items.trCount({'count': '1'}))
// Output: "One item"

// Multiple items
Text('items'.trCount({'count': '5'}))
Text(LocaleKeys.items.trCount({'count': '5'}))
// Output: "5 items"
```

### Advanced Pluralization with Variables
**JSON Definition:**
```json
{
  "messages": {
    "__count": {
      "zero": "No messages",
      "one": "1 message from {sender}",
      "other": "{count} messages from {sender}"
    }
  }
}
```

**Flutter Usage:**
```dart
// No messages
Text('messages'.trCount({'count': '0'}))
Text(LocaleKeys.messages.trCount({'count': '0'}))
// Output: "No messages"

// Single message with sender
Text('messages'.trCount({'count': '1', 'sender': 'Ali'}))
Text(LocaleKeys.messages.trCount({'count': '1', 'sender': 'Ali'}))
// Output: "1 message from Ali"

// Multiple messages with sender
Text('messages'.trCount({'count': '10', 'sender': 'Ali'}))
Text(LocaleKeys.messages.trCount({'count': '10', 'sender': 'Ali'}))
// Output: "10 messages from Ali"
```

### Rich Arabic Pluralization
**JSON Definition (Arabic):**
```json
{
  "notifications": {
    "__count": {
      "zero": "لا توجد إشعارات",
      "one": "لديك إشعار واحد",
      "two": "لديك إشعاران",
      "few": "لديك {count} إشعارات",
      "many": "لديك {count} إشعاراً",
      "other": "لديك {count} إشعار"
    }
  }
}
```

**Flutter Usage:**
```dart
// Arabic pluralization examples
Text('notifications'.trCount({'count': '0'}))
Text(LocaleKeys.notifications.trCount({'count': '0'}))
// Output: "لا توجد إشعارات" (zero)

Text('notifications'.trCount({'count': '1'}))
Text(LocaleKeys.notifications.trCount({'count': '1'}))
// Output: "لديك إشعار واحد" (one)

Text('notifications'.trCount({'count': '2'}))
Text(LocaleKeys.notifications.trCount({'count': '2'}))
// Output: "لديك إشعاران" (two)

Text('notifications'.trCount({'count': '5'}))
Text(LocaleKeys.notifications.trCount({'count': '5'}))
// Output: "لديك 5 إشعارات" (few)

Text('notifications'.trCount({'count': '15'}))
Text(LocaleKeys.notifications.trCount({'count': '15'}))
// Output: "لديك 15 إشعاراً" (many)
```

---

## 🎯 Supported Plural Keys

Gexd supports universal pluralization keys for all languages:

| Key | Usage | Description |
|-----|-------|-------------|
| `zero` | Exactly 0 items | "No items", "لا توجد عناصر" |
| `one` | Exactly 1 item | "One item", "عنصر واحد" |
| `two` | Exactly 2 items | "Two items", "عنصران" |
| `few` | Small quantity (3-10) | "Few items", "عناصر قليلة" |
| `many` | Large quantity (11+) | "Many items", "عناصر كثيرة" |
| `other` | Fallback for any other cases | Default plural form |

**Note:** Not all languages use all keys. Use only the keys your language requires.

---

## 🔑 Type-Safe LocaleKeys

Gexd automatically generates `LocaleKeys` class with constants for all your translation keys, providing compile-time safety and better IDE support.

### Generated LocaleKeys Class
```dart
class LocaleKeys {
  static const String welcome = 'welcome';
  static const String greeting = 'greeting';
  static const String app_name = 'app.name';
  static const String app_version = 'app.version';
  static const String buttons_login = 'buttons.login';
  static const String buttons_logout = 'buttons.logout';
  static const String validation_required = 'validation.required';
  static const String validation_passwordMinLength = 'validation.passwordMinLength';
  static const String items = 'items';
  static const String notifications = 'notifications';
  static const String messages = 'messages';
}
```

### 🚀 Benefits of Using LocaleKeys

#### 1. **Compile-Time Safety**
```dart
// ❌ Runtime error if key doesn't exist
Text('welcom'.tr) // Typo! Will show key instead of translation

// ✅ Compile-time error - IDE will catch the mistake
Text(LocaleKeys.welcom.tr) // IDE shows error immediately
```

#### 2. **IDE Autocomplete**
```dart
// ✅ IDE shows all available keys as you type
Text(LocaleKeys. // IDE shows: welcome, greeting, app_name, etc.
```

#### 3. **Refactoring Support** 
```dart
// ✅ Rename LocaleKeys.welcome and all usages update automatically
// ✅ Find all references to a specific translation key
// ✅ Safe deletion - IDE warns if key is still used
```

#### 4. **Better Code Readability**
```dart
// ❌ Magic strings - hard to understand
Text('validation.passwordMinLength'.trVars({'min': '8'}))

// ✅ Self-documenting code
Text(LocaleKeys.validation_passwordMinLength.trVars({'min': '8'}))
```

### 🎯 LocaleKeys Usage Examples

#### Basic Usage
```dart
// Simple translations
Text(LocaleKeys.welcome.tr)
Text(LocaleKeys.buttons_login.tr)

// With variables
Text(LocaleKeys.welcome.trVars({'name': userName}))
Text(LocaleKeys.greeting.trVars({'name': userName, 'time': 'morning'}))

// With pluralization
Text(LocaleKeys.items.trCount({'count': itemCount.toString()}))
Text(LocaleKeys.notifications.trCount({'count': notificationCount.toString()}))
```

#### Advanced Usage
```dart
// Form validation
String? validateEmail(String? value) {
  if (value?.isEmpty ?? true) {
    return LocaleKeys.validation_required.trVars({'field': 'Email'});
  }
  return null;
}

// Dynamic content
Widget buildStatusMessage(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return Text(LocaleKeys.order_status_pending.tr);
    case OrderStatus.shipped:
      return Text(LocaleKeys.order_status_shipped.tr);
    case OrderStatus.delivered:
      return Text(LocaleKeys.order_status_delivered.tr);
  }
}

// Pluralization with additional context
Widget buildCartSummary(int itemCount, double total) {
  return Column(
    children: [
      Text(LocaleKeys.items.trCount({'count': itemCount.toString()})),
      Text(LocaleKeys.cart_total.trVars({'amount': total.toString()})),
    ],
  );
}
```

---

## 🚀 Real-World Usage Examples

### Shopping Cart
```dart
class CartWidget extends StatelessWidget {
  final int itemCount;
  final String userName;

  Widget build(BuildContext context) {
    return Column(
      children: [
        // Welcome message with user name (Type-safe)
        Text(LocaleKeys.welcome.trVars({'name': userName})),
        
        // Cart items count with pluralization (Type-safe)
        Text(LocaleKeys.items.trCount({'count': itemCount.toString()})),
        
        // Dynamic greeting based on time (Type-safe)
        Text(LocaleKeys.greeting.trVars({
          'name': userName,
          'time': _getTimeOfDay(),
        })),
        
        // Additional cart actions
        ElevatedButton(
          onPressed: _checkout,
          child: Text(LocaleKeys.buttons_checkout.tr),
        ),
      ],
    );
  }
  
  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}
```

### Notification System
```dart
class NotificationBadge extends StatelessWidget {
  final int count;
  final String senderName;

  Widget build(BuildContext context) {
    return Badge(
      label: Text(
        LocaleKeys.notifications.trCount({'count': count.toString()})
      ),
      child: IconButton(
        icon: Icon(Icons.notifications),
        onPressed: () => _showNotifications(),
      ),
    );
  }
  
  void _showNotifications() {
    // Show notification list with type-safe messages
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.notifications_title.tr),
        content: Text(LocaleKeys.messages.trCount({
          'count': count.toString(),
          'sender': senderName,
        })),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocaleKeys.buttons_close.tr),
          ),
        ],
      ),
    );
  }
}
```

### Form Validation
```dart
class CustomValidator {
  /// Type-safe field validation with LocaleKeys
  static String? validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.validation_required.trVars({'field': fieldName});
    }
    return null;
  }
  
  /// Type-safe password validation with LocaleKeys
  static String? validatePassword(String? value, int minLength) {
    if (value == null || value.length < minLength) {
      return LocaleKeys.validation_passwordMinLength.trVars({
        'min': minLength.toString()
      });
    }
    return null;
  }
  
  /// Email validation with type-safe error messages
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.validation_required.trVars({'field': 'Email'});
    }
    if (!value.contains('@')) {
      return LocaleKeys.validation_emailInvalid.tr;
    }
    return null;
  }
  
  /// Advanced validation with multiple error types
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.validation_required.trVars({'field': 'Username'});
    }
    if (value.length < 3) {
      return LocaleKeys.validation_minLength.trVars({
        'field': 'Username', 
        'min': '3'
      });
    }
    if (value.contains(' ')) {
      return LocaleKeys.validation_noSpaces.tr;
    }
    return null;
  }
}
```

---

## 💡 Best Practices

### 🔑 LocaleKeys Best Practices

1. **Always Use LocaleKeys**: Prefer `LocaleKeys.welcome.tr` over `'welcome'.tr`
   ```dart
   // ✅ Recommended - Type-safe and IDE-friendly
   Text(LocaleKeys.welcome.trVars({'name': userName}))
   
   // ❌ Avoid - Runtime errors possible
   Text('welcome'.trVars({'name': userName}))
   ```

2. **Import LocaleKeys Globally**: Add to your common imports
   ```dart
   // In your app's common imports file
   export 'package:your_app/generated/translations.g.dart' show LocaleKeys;
   ```

3. **Use Descriptive Key Names**: Make keys self-documenting
   ```dart
   // ✅ Clear and descriptive
   LocaleKeys.validation_emailRequired
   LocaleKeys.auth_loginSuccess
   LocaleKeys.cart_itemsCount
   
   // ❌ Vague or unclear  
   LocaleKeys.error1
   LocaleKeys.msg_a
   LocaleKeys.txt
   ```

### 🌐 Translation Best Practices

4. **Use Clear Variable Names**: `{name}`, `{count}`, `{field}` instead of `{a}`, `{b}`, `{c}`

5. **Consistent Plural Keys**: Use the same keys across all languages for consistency

6. **Fallback Values**: Always provide `other` key as fallback in pluralization

7. **Variable Documentation**: Document expected variables in your code comments
   ```dart
   /// Expects: {name} - User's display name
   /// Expects: {time} - Time period (morning, afternoon, evening)
   Text(LocaleKeys.greeting.trVars({'name': userName, 'time': timeOfDay}))
   ```

8. **Language-Specific Rules**: Customize plural ranges based on language requirements

9. **Testing**: Test pluralization with edge cases (0, 1, 2, large numbers)

10. **Organize Keys Logically**: Group related translations
    ```json
    {
      "auth": {
        "login": "Login",
        "logout": "Logout" 
      },
      "validation": {
        "required": "{field} is required",
        "emailInvalid": "Invalid email"
      }
    }
    ```

---

## 🔧 Generation Command

Generate these advanced translations with:

```bash
gexd locale generate assets/translations --key-style dot --sort-keys
```

This creates the translation file with all the extensions needed for `trVars` and `trCount` functionality! 🎉