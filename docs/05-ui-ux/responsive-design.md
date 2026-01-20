# 📱 Responsive Design

## Panduan Responsive Design LeadX CRM

---

## 📋 Overview

LeadX CRM didesain untuk bekerja optimal di berbagai ukuran layar: mobile phones, tablets, dan web browsers.

---

## 📐 Breakpoints

| Breakpoint | Width | Target Device |
|------------|-------|---------------|
| Mobile S | < 360px | Small phones |
| Mobile | 360-599px | Standard phones |
| Tablet | 600-1023px | Tablets, large phones |
| Desktop | 1024-1439px | Laptops, small monitors |
| Desktop L | ≥ 1440px | Large monitors |

### Flutter Implementation

```dart
class Breakpoints {
  static const double mobileS = 0;
  static const double mobile = 360;
  static const double tablet = 600;
  static const double desktop = 1024;
  static const double desktopL = 1440;
  
  static bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < tablet;
    
  static bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width >= tablet &&
    MediaQuery.of(context).size.width < desktop;
    
  static bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= desktop;
}
```

---

## 📱 Layout Patterns

### Mobile Layout (< 600px)

```
┌─────────────────────────┐
│        App Bar          │
├─────────────────────────┤
│                         │
│     Single Column       │
│       Content           │
│                         │
│                         │
├─────────────────────────┤
│    Bottom Navigation    │
└─────────────────────────┘
```

**Characteristics:**
- Single column layout
- Bottom navigation
- Full-width cards
- Collapsible sections
- Swipe gestures

### Tablet Layout (600-1023px)

```
┌─────────────────────────────────────────┐
│                App Bar                   │
├─────────────────────────────────────────┤
│                                          │
│    ┌───────────┐  ┌───────────┐         │
│    │  Card 1   │  │  Card 2   │         │
│    └───────────┘  └───────────┘         │
│                                          │
│    ┌───────────────────────────┐        │
│    │      Full Width Card      │        │
│    └───────────────────────────┘        │
│                                          │
├─────────────────────────────────────────┤
│            Bottom Navigation             │
└─────────────────────────────────────────┘
```

**Characteristics:**
- 2-column grid for cards
- Larger touch targets
- Expanded tables
- Side-by-side comparisons

### Desktop Layout (≥ 1024px)

```
┌─────────────────────────────────────────────────────────┐
│                        Top Bar                           │
├─────────────┬───────────────────────────────────────────┤
│             │                                            │
│   Sidebar   │              Content Area                  │
│   Navigation│                                            │
│             │   ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│  Dashboard  │   │  Card 1  │ │  Card 2  │ │  Card 3  │  │
│  Customers  │   └──────────┘ └──────────┘ └──────────┘  │
│  Activities │                                            │
│  Scoreboard │                                            │
│  Reports    │                                            │
│             │                                            │
└─────────────┴───────────────────────────────────────────┘
```

**Characteristics:**
- Side navigation
- Multi-column layouts
- Data tables with pagination
- Dashboard grids

---

## 🎨 Responsive Components

### Responsive Grid

```dart
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    int crossAxisCount;
    if (width < 600) {
      crossAxisCount = 1; // Mobile
    } else if (width < 1024) {
      crossAxisCount = 2; // Tablet
    } else {
      crossAxisCount = 3; // Desktop
    }
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      children: children,
    );
  }
}
```

### Responsive Navigation

```dart
class ResponsiveNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Breakpoints.isMobile(context)) {
      return BottomNavigationBar(...);
    } else {
      return NavigationRail(...);
    }
  }
}
```

---

## 📏 Spacing System

| Token | Mobile | Tablet | Desktop |
|-------|--------|--------|---------|
| xs | 4px | 4px | 4px |
| sm | 8px | 8px | 8px |
| md | 16px | 16px | 20px |
| lg | 24px | 28px | 32px |
| xl | 32px | 40px | 48px |

---

## 🔤 Typography Scaling

| Style | Mobile | Tablet | Desktop |
|-------|--------|--------|---------|
| H1 | 24px | 28px | 32px |
| H2 | 20px | 22px | 24px |
| Body | 14px | 14px | 16px |
| Caption | 12px | 12px | 14px |

---

## ✅ Responsive Checklist

- [ ] Test on 360px width (small mobile)
- [ ] Test on 600px width (tablet breakpoint)
- [ ] Test on 1024px width (desktop breakpoint)
- [ ] Test landscape orientation
- [ ] Verify touch targets ≥ 48px on mobile
- [ ] Check text readability at all sizes

---

## 📚 Related Documents

- [Design System](design-system.md)
- [Navigation Architecture](navigation-architecture.md)
- [Screen Flows](screen-flows.md)

---

*Dokumen ini adalah bagian dari LeadX CRM UI/UX Documentation.*
