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

## 🎯 App Bar / Header Specification

### Header Dimensions

| Breakpoint | Header Height | Logo Size | Action Icon Size |
|------------|---------------|-----------|------------------|
| Mobile | 56dp | 32x32dp | 24dp (touch: 48dp) |
| Tablet | 64dp | 40x40dp | 24dp (touch: 48dp) |
| Desktop | 64dp | 48x48dp | 24dp |

### Header Content Per Breakpoint

#### Mobile (< 600px)
```
┌─────────────────────────────────────────────────────────────┐
│ [≡]  Logo + "LeadX"     [🔔] [⚡Sync] [👤]                  │
└─────────────────────────────────────────────────────────────┘
```
| Position | Element | Behavior |
|----------|---------|----------|
| Left | Hamburger menu (optional) | Opens drawer untuk akses settings |
| Center-Left | Logo + App name | Tap → kembali ke Dashboard |
| Right | Notification icon | Badge count jika ada notif baru |
| Right | Sync button | Rotating saat sync in progress |
| Right | Profile avatar | Tap → Profile menu dropdown |

#### Tablet (600-1023px)
```
┌─────────────────────────────────────────────────────────────┐
│ Logo + "LeadX CRM"  |  [Search...]  | [🔔] [⚡] [👤 Name ▼] │
└─────────────────────────────────────────────────────────────┘
```
| Position | Element | Behavior |
|----------|---------|----------|
| Left | Logo + Full app name | Tap → kembali ke Dashboard |
| Center | Search bar (expandable) | 200-300px width |
| Right | Notification icon | Dengan badge count |
| Right | Sync status indicator | Icon + optional text "Syncing..." |
| Right | Profile (avatar + nama) | Dropdown menu on tap |

#### Desktop (≥ 1024px)
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    [🔍 Search customers, pipelines...]   [🔔 3] [⚡] [👤 Nama User ▼] │
└─────────────────────────────────────────────────────────────────────────────┘
```
| Position | Element | Behavior |
|----------|---------|----------|
| Left | (Kosong - logo di sidebar) | - |
| Center | Search bar (expanded) | Min 400px width, global search |
| Right | Notification icon + count | Dropdown panel on hover/click |
| Right | Sync indicator | Last sync time + manual sync button |
| Right | Profile menu | Avatar + full name + role badge |

> **Catatan Desktop:** Logo dan branding pindah ke bagian atas sidebar, bukan di header content area.

---

## 🧭 Navigation Component Specification

### Navigation Type Per Breakpoint

| Breakpoint | Navigasi | Posisi | Lebar/Tinggi | Behavior saat Detail |
|------------|----------|--------|--------------|----------------------|
| Mobile (< 600px) | Bottom Navigation | Bottom | 56dp | **Tetap terlihat** (dalam shell) |
| Tablet (600-1023px) | Navigation Rail | Left | 80dp | **Tetap terlihat** |
| Desktop (≥ 1024px) | Sidebar | Left | 256-280px | **Tetap terlihat** |

### Mobile: Bottom Navigation (< 600px)

Bottom Navigation berada **dalam shell**, sehingga tetap terlihat saat navigasi ke detail screen.

```
┌─────────────────────────────────────────────────┐
│                 Content Area                    │
│  (Dashboard / CustomerList / CustomerDetail)    │
├─────────────────────────────────────────────────┤
│   🏠   │   👥   │   ➕   │   📅   │   👤       │
│  Home  │Customer│  Add   │Activity│ Profile    │
└─────────────────────────────────────────────────┘
```

| Spesifikasi | Nilai |
|-------------|-------|
| Tinggi | 56dp |
| Icon size | 24dp |
| Label size | 12sp |
| Touch target | 48dp minimum |
| Active indicator | Pill shape dengan primary color |
| Elevation | 8dp |

---

### Tablet: Navigation Rail (600-1023px)

Navigation Rail tetap terlihat di kiri saat navigasi ke detail screen.

```
┌────────┬────────────────────────────────────────┐
│  🏠    │                                        │
│ Home   │          Content Area                  │
│        │  (List atau Detail, tergantung route)  │
│  👥    │                                        │
│Customer│                                        │
│        │                                        │
│  ➕    │                                        │
│  Add   │                                        │
│        │                                        │
│  📅    │                                        │
│Activity│                                        │
│        │                                        │
│  👤    │                                        │
│Profile │                                        │
├────────┤                                        │
│  ⋮     │                                        │
│ More   │                                        │
└────────┴────────────────────────────────────────┘
```

| Spesifikasi | Nilai |
|-------------|-------|
| Lebar | 80dp |
| Icon size | 24dp |
| Label size | 12sp (di bawah icon) |
| Item height | 56dp |
| Active indicator | Pill background |

### Drawer Menu Items (via hamburger di Dashboard AppBar)
- HVC (High Value Customer)
- Broker
- Scoreboard
- Cadence
- Settings
- Logout
- Admin Panel (jika role = ADMIN)

### Desktop Sidebar

```
┌─────────────────────────┐
│ [Logo] LeadX CRM        │ ← Branded header
│ "AI-Powered CRM"        │
│ PT ABC Company          │
├─────────────────────────┤
│ 🏠 Dashboard            │
│ 👥 Customers            │  ← Pipeline sebagai tab di Customer Detail
│ 📅 Activities           │
│ 👤 Profile              │
├─────────────────────────┤
│ ⭐ HVC                  │
│ 🤝 Broker               │
│ 🏆 Scoreboard           │
│ � Cadence              │
├─────────────────────────┤
│ ⚙️ Settings             │
│ 🔐 Admin Panel *        │ ← *Hanya jika role=ADMIN
├─────────────────────────┤
│ 🚪 Logout               │
│ © 2025 LeadX            │ ← Footer
└─────────────────────────┘
```

| Spesifikasi | Nilai |
|-------------|-------|
| Lebar | 256px (Desktop), 280px (Desktop L) |
| Header height | 80dp (logo + company info) |
| Item height | 48dp |
| Icon size | 24dp |
| Active indicator | Left border 4dp + background highlight |
| Collapsed mode | Tidak ada (selalu expanded di desktop) |

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
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    // Desktop: Sidebar + Content
    if (width >= 1024) {
      return Row(
        children: [
          SizedBox(
            width: width >= 1440 ? 280 : 256,
            child: const DesktopSidebar(),
          ),
          Expanded(child: child),
        ],
      );
    }
    
    // Mobile & Tablet: Content + Bottom Navigation
    return Scaffold(
      body: child,
      bottomNavigationBar: SizedBox(
        height: width >= 600 ? 64 : 56,
        child: const AppBottomNavigation(),
      ),
    );
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
