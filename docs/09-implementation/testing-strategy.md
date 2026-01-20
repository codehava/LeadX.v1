# 🧪 Testing Strategy

## Strategi Testing LeadX CRM

---

## 📋 Overview

Dokumen ini mendefinisikan strategi testing untuk LeadX CRM, termasuk:
- Test levels dan types
- Testing tools
- Test coverage targets
- CI/CD integration

---

## 🎯 Testing Objectives

1. **Functional Correctness**: Memastikan fitur berjalan sesuai requirements
2. **Reliability**: Sistem stabil dan tidak crash
3. **Performance**: Response time dan resource usage optimal
4. **Security**: Data terlindungi, access control berfungsi
5. **Offline Support**: Fitur offline berjalan dengan baik
6. **Cross-Platform**: Konsisten di iOS dan Android

---

## 📊 Testing Pyramid

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         TESTING PYRAMID                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│                          △                                                   │
│                         /E2E\                                                │
│                        / 10% \           Manual + Automated                  │
│                       /───────\          Critical user flows                 │
│                      /         \                                             │
│                     / Integration\                                           │
│                    /     20%      \      API, Database, Services             │
│                   /─────────────────\                                        │
│                  /                   \                                       │
│                 /       Widget        \                                      │
│                /         30%           \    UI Components, Screens           │
│               /───────────────────────────\                                  │
│              /                             \                                 │
│             /            Unit               \                                │
│            /             40%                 \  Business logic, Utils        │
│           /─────────────────────────────────────\                            │
│                                                                              │
│  Distribution: More unit tests, fewer E2E tests                             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔬 Test Levels

### Level 1: Unit Tests (40%)

**Scope:** Individual functions, classes, providers

**Tools:**
- `flutter_test` (built-in)
- `mockito` for mocking
- `freezed` for test data

**What to Test:**
- Business logic (scoring calculation, data transformation)
- Utilities (validators, formatters)
- Riverpod providers
- Repository methods (mocked)

**Example:**

```dart
// test/unit/scoring/score_calculator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:leadx/features/scoring/score_calculator.dart';

void main() {
  group('ScoreCalculator', () {
    late ScoreCalculator calculator;
    
    setUp(() {
      calculator = ScoreCalculator();
    });
    
    test('calculates visit score correctly', () {
      // Given
      const target = 10;
      const actual = 8;
      
      // When
      final score = calculator.calculateMetricScore(
        actual: actual,
        target: target,
        weight: 40,
      );
      
      // Then
      expect(score, equals(32)); // (8/10) * 40 = 32
    });
    
    test('caps score at 100%', () {
      final score = calculator.calculateMetricScore(
        actual: 15, // Exceeds target
        target: 10,
        weight: 40,
      );
      
      expect(score, equals(40)); // Max = weight
    });
  });
}
```

**Coverage Target:** >80%

---

### Level 2: Widget Tests (30%)

**Scope:** UI components, screens, interactions

**Tools:**
- `flutter_test`
- `riverpod` for provider testing
- `golden_toolkit` for visual regression

**What to Test:**
- Widget renders correctly
- User interactions (tap, input)
- State changes reflect in UI
- Error states display
- Loading states

**Example:**

```dart
// test/widget/customer/customer_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leadx/features/customer/widgets/customer_card.dart';
import 'package:leadx/features/customer/models/customer.dart';

void main() {
  group('CustomerCard', () {
    late Customer testCustomer;
    
    setUp(() {
      testCustomer = Customer(
        id: '123',
        name: 'PT ABC Indonesia',
        address: 'Jakarta',
        phone: '021-1234567',
      );
    });
    
    testWidgets('displays customer name and address', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomerCard(customer: testCustomer),
          ),
        ),
      );
      
      expect(find.text('PT ABC Indonesia'), findsOneWidget);
      expect(find.text('Jakarta'), findsOneWidget);
    });
    
    testWidgets('triggers onTap callback', (tester) async {
      var tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomerCard(
              customer: testCustomer,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(CustomerCard));
      expect(tapped, isTrue);
    });
  });
}
```

**Coverage Target:** Key screens and reusable components (>60%)

---

### Level 3: Integration Tests (20%)

**Scope:** API calls, database operations, service interactions

**Tools:**
- `flutter_test`
- `supabase` test instance
- `drift` in-memory database

**What to Test:**
- API endpoints return correct data
- Database CRUD operations
- Offline sync mechanism
- Authentication flow

**Example:**

```dart
// test/integration/customer_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:leadx/core/database/app_database.dart';
import 'package:leadx/features/customer/repositories/customer_repository.dart';

void main() {
  group('CustomerRepository', () {
    late AppDatabase db;
    late CustomerRepository repository;
    
    setUp(() async {
      db = AppDatabase.inMemory(); // In-memory for testing
      repository = CustomerRepository(db);
    });
    
    tearDown(() async {
      await db.close();
    });
    
    test('creates and retrieves customer', () async {
      // Create
      final customer = CustomerCompanion(
        name: Value('PT Test'),
        address: Value('Jakarta'),
      );
      
      final id = await repository.create(customer);
      
      // Retrieve
      final retrieved = await repository.getById(id);
      
      expect(retrieved?.name, equals('PT Test'));
      expect(retrieved?.address, equals('Jakarta'));
    });
    
    test('searches customers by name', () async {
      await repository.create(CustomerCompanion(name: Value('PT ABC')));
      await repository.create(CustomerCompanion(name: Value('PT XYZ')));
      await repository.create(CustomerCompanion(name: Value('CV ABC')));
      
      final results = await repository.search('ABC');
      
      expect(results.length, equals(2));
    });
  });
}
```

---

### Level 4: End-to-End Tests (10%)

**Scope:** Complete user flows

**Tools:**
- `integration_test` package
- Physical devices or emulators
- Firebase Test Lab (optional)

**What to Test:**
- Login → Dashboard → Logout
- Create Customer → View → Edit
- Create Pipeline → Move Stage → Close
- Schedule Activity → Check-in → Complete

**Example:**

```dart
// integration_test/flows/customer_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:leadx/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Customer Flow', () {
    testWidgets('create and view customer', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Login
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();
      
      // Navigate to customers
      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle();
      
      // Tap FAB to add
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      // Fill form
      await tester.enterText(find.byKey(Key('name_field')), 'PT Integration Test');
      await tester.enterText(find.byKey(Key('address_field')), 'Jakarta');
      
      // Save
      await tester.tap(find.byKey(Key('save_button')));
      await tester.pumpAndSettle();
      
      // Verify customer appears in list
      expect(find.text('PT Integration Test'), findsOneWidget);
    });
  });
}
```

---

## 🔧 Testing Tools

### Flutter Testing Stack

| Tool | Purpose |
|------|---------|
| `flutter_test` | Built-in testing framework |
| `integration_test` | E2E testing |
| `mockito` | Mocking dependencies |
| `mocktail` | Alternative mocking (no codegen) |
| `fake_async` | Time manipulation |
| `golden_toolkit` | Visual regression |
| `patrol` | Advanced E2E testing |

### Coverage Tools

```bash
# Generate coverage report
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# View in browser
open coverage/html/index.html
```

### CI Integration (GitHub Actions)

```yaml
# .github/workflows/test.yml
name: Tests

on:
  push:
    branches: [Develop, Staging]
  pull_request:
    branches: [Staging, main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Check coverage
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info | grep lines | awk '{print $4}')
          if (( $(echo "$COVERAGE < 60" | bc -l) )); then
            echo "Coverage $COVERAGE is below 60%"
            exit 1
          fi
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
```

---

## 📋 Test Coverage Targets

| Area | Target | Priority |
|------|--------|----------|
| **Business Logic** | >90% | P0 |
| **Providers** | >80% | P0 |
| **Repositories** | >80% | P0 |
| **Validators** | 100% | P0 |
| **Widgets** | >60% | P1 |
| **Screens** | >50% | P1 |
| **E2E Flows** | Critical paths | P0 |

---

## 📱 Device Testing Matrix

### Android

| Device | OS Version | Priority |
|--------|------------|----------|
| Samsung Galaxy A series | Android 12-14 | P0 |
| Xiaomi Redmi | Android 11-13 | P0 |
| Oppo A series | Android 11-13 | P1 |
| Vivo Y series | Android 11-13 | P1 |
| Low-end (2GB RAM) | Android 10+ | P1 |

### iOS

| Device | OS Version | Priority |
|--------|------------|----------|
| iPhone 12/13/14 | iOS 15-17 | P0 |
| iPhone SE | iOS 15+ | P1 |
| iPad (optional) | iPadOS 15+ | P2 |

---

## 🔄 Testing in CI/CD Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CI/CD TEST PIPELINE                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Developer Push                                                              │
│       │                                                                      │
│       ▼                                                                      │
│  ┌─────────────┐                                                            │
│  │ Lint Check  │ ─── Fail ──▶ Block PR                                      │
│  └──────┬──────┘                                                            │
│         │ Pass                                                               │
│         ▼                                                                    │
│  ┌─────────────┐                                                            │
│  │ Unit Tests  │ ─── Fail ──▶ Block PR                                      │
│  └──────┬──────┘                                                            │
│         │ Pass                                                               │
│         ▼                                                                    │
│  ┌─────────────┐                                                            │
│  │Widget Tests │ ─── Fail ──▶ Block PR                                      │
│  └──────┬──────┘                                                            │
│         │ Pass                                                               │
│         ▼                                                                    │
│  ┌─────────────┐                                                            │
│  │ Coverage    │ ─── <60% ──▶ Warning (not blocking)                        │
│  │   Check     │                                                            │
│  └──────┬──────┘                                                            │
│         │ Pass                                                               │
│         ▼                                                                    │
│  ┌─────────────┐                                                            │
│  │   Build     │ ─── Fail ──▶ Block PR                                      │
│  │   APK/IPA   │                                                            │
│  └──────┬──────┘                                                            │
│         │ Pass                                                               │
│         ▼                                                                    │
│  ┌─────────────┐     (On merge to Staging only)                             │
│  │ E2E Tests   │ ─── Fail ──▶ Alert, investigate                            │
│  └──────┬──────┘                                                            │
│         │ Pass                                                               │
│         ▼                                                                    │
│  ┌─────────────┐                                                            │
│  │   Deploy    │                                                            │
│  └─────────────┘                                                            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📝 Test Case Naming Convention

```dart
// Pattern: should_expectedBehavior_when_condition

test('should return error when email is invalid', () {...});
test('should navigate to dashboard when login succeeds', () {...});
test('should show loading when fetching customers', () {...});
```

---

## 🔍 Manual Testing Checklist

### Pre-Release Checklist

#### Functional
- [ ] Login/Logout works
- [ ] All CRUD operations work
- [ ] Search and filter work
- [ ] GPS capture works
- [ ] Photo capture works
- [ ] File upload works
- [ ] Notifications received

#### Offline
- [ ] App works without internet
- [ ] Data saved locally
- [ ] Sync works when reconnected
- [ ] Conflict resolution works

#### Performance
- [ ] App loads in <3s
- [ ] Scroll is smooth
- [ ] No memory leaks
- [ ] Battery usage reasonable

#### UI/UX
- [ ] All screens render correctly
- [ ] Forms validate properly
- [ ] Error messages clear
- [ ] Loading states shown

#### Cross-Platform
- [ ] Works on Android target devices
- [ ] Works on iOS target devices
- [ ] Consistent behavior across platforms

---

## 📊 Test Reporting

### Daily
- Automated test results in GitHub Actions

### Per Sprint
- Test coverage report
- New test cases added
- Bug regression count

### Per Release
- Full regression test report
- Manual testing signoff
- Performance benchmark

---

## 📚 Related Documents

- [Non-Functional Requirements](../02-requirements/non-functional-requirements.md) - Quality requirements
- [Tech Stack](../03-architecture/tech-stack.md) - Testing tools
- [Deployment Guide](deployment-guide.md) - CI/CD setup

---

*Testing strategy version 1.0 - January 2025*
