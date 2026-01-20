# 🧭 Navigation Architecture

## Arsitektur Navigasi LeadX CRM

---

## 📋 Overview

LeadX CRM menggunakan **go_router** untuk navigasi dengan pattern bottom navigation + nested routes untuk mobile app, dan side navigation untuk web admin.

---

## 🏛️ Navigation Structure

### Mobile App (RM/BH/BM)

```
┌─────────────────────────────────────────────────────┐
│                    MOBILE APP                        │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Bottom Navigation:                                  │
│  ┌─────────┬─────────┬─────────┬─────────┬────────┐│
│  │Dashboard│Customer │Activity │Scoreboard│ More   ││
│  └────┬────┴────┬────┴────┬────┴────┬─────┴───┬────┘│
│       │         │         │         │         │      │
│       ▼         ▼         ▼         ▼         ▼      │
│   /dashboard /customers /activities /scoreboard /more│
│                                                      │
└─────────────────────────────────────────────────────┘
```

### Web Admin

```
┌─────────────────────────────────────────────────────┐
│  SIDEBAR          │         CONTENT                 │
├───────────────────┼─────────────────────────────────┤
│  📊 Dashboard     │                                 │
│  👥 Users         │      [Route Content]            │
│  🏢 Branches      │                                 │
│  🎯 4DX Config    │                                 │
│  📈 Reports       │                                 │
│  ⚙️ Settings      │                                 │
└───────────────────┴─────────────────────────────────┘
```

---

## 🗺️ Route Definitions

### Mobile Routes

| Path | Screen | Auth Required |
|------|--------|---------------|
| `/` | Splash/Redirect | No |
| `/login` | Login | No |
| `/dashboard` | Dashboard | Yes |
| `/customers` | Customer List | Yes |
| `/customers/:id` | Customer Detail | Yes |
| `/customers/:id/pipelines` | Customer Pipelines | Yes |
| `/activities` | Activity List | Yes |
| `/activities/new` | Create Activity | Yes |
| `/scoreboard` | Personal Scoreboard | Yes |
| `/scoreboard/team` | Team Leaderboard | Yes (BH+) |
| `/cadence` | Cadence Schedule | Yes |
| `/cadence/:id/form` | Pre-meeting Form | Yes |
| `/hvc` | HVC List | Yes |
| `/brokers` | Broker List | Yes |
| `/settings` | Settings | Yes |

### Web Admin Routes

| Path | Screen | Role Required |
|------|--------|---------------|
| `/admin` | Admin Dashboard | ADMIN |
| `/admin/users` | User Management | ADMIN |
| `/admin/branches` | Branch Management | ADMIN |
| `/admin/4dx` | 4DX Configuration | ADMIN |
| `/admin/reports` | Reports | ADMIN |

---

## 📱 go_router Configuration

```dart
final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = ref.read(authProvider).isLoggedIn;
    final isLoginRoute = state.matchedLocation == '/login';
    
    if (!isLoggedIn && !isLoginRoute) return '/login';
    if (isLoggedIn && isLoginRoute) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/customers',
          builder: (context, state) => const CustomerListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => CustomerDetailScreen(
                id: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        // ... more routes
      ],
    ),
  ],
);
```

---

## 🔀 Navigation Patterns

### 1. Bottom Tab Navigation

```dart
class MainShell extends StatelessWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateIndex(context),
        onTap: (index) => _navigateTo(context, index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Activities'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Score'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
```

### 2. Push Navigation

```dart
// Navigate to detail
context.push('/customers/$customerId');

// Navigate with parameters
context.pushNamed('customerDetail', pathParameters: {'id': customerId});
```

### 3. Replace Navigation

```dart
// After login, replace stack
context.go('/dashboard');
```

---

## 🔐 Route Guards

### Role-Based Access

```dart
GoRoute(
  path: '/admin',
  redirect: (context, state) {
    final user = ref.read(authProvider).user;
    if (user?.role != 'ADMIN') {
      return '/dashboard'; // Redirect non-admin
    }
    return null;
  },
  builder: (context, state) => const AdminDashboard(),
),
```

### Feature Flags

```dart
GoRoute(
  path: '/scoreboard/team',
  redirect: (context, state) {
    final user = ref.read(authProvider).user;
    if (!['BH', 'BM', 'ROH', 'ADMIN'].contains(user?.role)) {
      return '/scoreboard'; // RM can't see team
    }
    return null;
  },
),
```

---

## 📱 Deep Linking

### Supported Deep Links

| Link | Target |
|------|--------|
| `leadx://customer/123` | Customer Detail |
| `leadx://activity/456` | Activity Detail |
| `leadx://cadence/789/form` | Pre-meeting Form |

---

## 📚 Related Documents

- [Screen Flows](screen-flows.md)
- [Design System](design-system.md)
- [Tech Stack](../03-architecture/tech-stack.md)

---

*Dokumen ini adalah bagian dari LeadX CRM UI/UX Documentation.*
