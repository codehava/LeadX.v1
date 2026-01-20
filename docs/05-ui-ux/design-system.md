# 🎨 Design System

## LeadX CRM Visual Design Language

---

## 📋 Overview

Design System ini mendefinisikan standar visual untuk LeadX CRM, memastikan konsistensi dan kualitas pengalaman pengguna di seluruh platform (Android, iOS, Web).

---

## 🎨 Color Palette

### Primary Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `--primary` | `#2E5BFF` | Primary buttons, links, active states |
| `--primary-light` | `#64B5F6` | Hover states, secondary emphasis |
| `--primary-dark` | `#1E3FAE` | Pressed states, dark variant |
| `--primary-surface` | `#E8EDFF` | Light backgrounds, chips |

### Semantic Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `--success` | `#4CAF50` | Completed, won, positive |
| `--success-light` | `#E8F5E9` | Success backgrounds |
| `--warning` | `#FF9800` | Pending, attention needed |
| `--warning-light` | `#FFF3E0` | Warning backgrounds |
| `--error` | `#F44336` | Errors, lost, critical |
| `--error-light` | `#FFEBEE` | Error backgrounds |
| `--info` | `#2196F3` | Informational |
| `--info-light` | `#E3F2FD` | Info backgrounds |

### Neutral Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `--background` | `#F4F6FB` | Page background |
| `--surface` | `#FFFFFF` | Cards, modals |
| `--surface-variant` | `#F5F5F5` | Disabled, dividers |
| `--on-surface` | `#1A1A1A` | Primary text |
| `--on-surface-variant` | `#666666` | Secondary text |
| `--on-surface-disabled` | `#9E9E9E` | Disabled text |
| `--outline` | `#E0E0E0` | Borders, dividers |

### Pipeline Stage Colors

| Stage | Hex | Description |
|-------|-----|-------------|
| `--stage-new` | `#9E9E9E` | NEW (10%) - Gray |
| `--stage-p3` | `#2196F3` | P3 (25%) - Blue |
| `--stage-p2` | `#FF9800` | P2 (50%) - Orange |
| `--stage-p1` | `#FF5722` | P1 (75%) - Deep Orange |
| `--stage-won` | `#4CAF50` | ACCEPTED (100%) - Green |
| `--stage-lost` | `#F44336` | DECLINED (0%) - Red |

### Score Colors

| Score Range | Hex | Label |
|-------------|-----|-------|
| 90-100 | `#4CAF50` | Excellent |
| 75-89 | `#8BC34A` | Good |
| 60-74 | `#FF9800` | Fair |
| 40-59 | `#FF5722` | Needs Improvement |
| 0-39 | `#F44336` | Critical |

---

## 📝 Typography

### Font Family

```css
--font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
```

**Note:** Inter tersedia gratis dari [Google Fonts](https://fonts.google.com/specimen/Inter)

### Type Scale

| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| `display-large` | 57px | 400 | 64px | Hero sections |
| `display-medium` | 45px | 400 | 52px | Page titles |
| `display-small` | 36px | 400 | 44px | Section headers |
| `headline-large` | 32px | 600 | 40px | Card titles |
| `headline-medium` | 28px | 600 | 36px | Modal titles |
| `headline-small` | 24px | 600 | 32px | Section titles |
| `title-large` | 22px | 500 | 28px | List titles |
| `title-medium` | 16px | 500 | 24px | Card subtitles |
| `title-small` | 14px | 500 | 20px | Small titles |
| `body-large` | 16px | 400 | 24px | Body text |
| `body-medium` | 14px | 400 | 20px | Default text |
| `body-small` | 12px | 400 | 16px | Captions |
| `label-large` | 14px | 500 | 20px | Buttons |
| `label-medium` | 12px | 500 | 16px | Chips, badges |
| `label-small` | 11px | 500 | 16px | Tiny labels |

---

## 📐 Spacing System

### Base Unit

```css
--spacing-unit: 4px;
```

### Scale

| Token | Value | Usage |
|-------|-------|-------|
| `--spacing-xs` | 4px | Tight spacing |
| `--spacing-sm` | 8px | Compact elements |
| `--spacing-md` | 16px | Default padding |
| `--spacing-lg` | 24px | Section spacing |
| `--spacing-xl` | 32px | Large gaps |
| `--spacing-2xl` | 48px | Page margins |

### Component Spacing

| Component | Padding | Margin |
|-----------|---------|--------|
| Card | 16px | 8px bottom |
| List item | 16px horizontal, 12px vertical | - |
| Button | 16px horizontal, 12px vertical | - |
| Input | 16px horizontal, 14px vertical | 8px bottom |
| Section | 16px | 24px bottom |

---

## 🔲 Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `--radius-xs` | 4px | Small chips |
| `--radius-sm` | 8px | Buttons, inputs |
| `--radius-md` | 12px | Cards |
| `--radius-lg` | 16px | Modals |
| `--radius-xl` | 24px | Bottom sheets |
| `--radius-full` | 9999px | Pills, avatars |

---

## 🌑 Elevation (Shadows)

| Level | Shadow | Usage |
|-------|--------|-------|
| `--elevation-0` | none | Flat elements |
| `--elevation-1` | `0 1px 2px rgba(0,0,0,0.05)` | Cards |
| `--elevation-2` | `0 2px 4px rgba(0,0,0,0.08)` | Raised cards |
| `--elevation-3` | `0 4px 8px rgba(0,0,0,0.10)` | Dropdowns |
| `--elevation-4` | `0 8px 16px rgba(0,0,0,0.12)` | Modals |
| `--elevation-5` | `0 12px 24px rgba(0,0,0,0.16)` | Dialogs |

---

## 🧩 Component Specifications

### Buttons

#### Primary Button
```
┌────────────────────────────┐
│         SIMPAN             │
└────────────────────────────┘
Background: --primary
Text: #FFFFFF
Padding: 16px 24px
Border Radius: 8px
Font: label-large (14px, 500)
Min Width: 120px
Height: 48px
```

#### Button States
| State | Background | Text |
|-------|------------|------|
| Default | `--primary` | white |
| Hover | `--primary-light` | white |
| Pressed | `--primary-dark` | white |
| Disabled | `--surface-variant` | `--on-surface-disabled` |
| Loading | `--primary` + spinner | white |

#### Button Variants
| Variant | Style |
|---------|-------|
| Primary | Filled, --primary |
| Secondary | Outlined, --primary border |
| Text | No background, --primary text |
| Destructive | Filled, --error |

### Cards

```
┌─────────────────────────────────────────────────────────────┐
│ CARD HEADER                                                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Card content area                                         │
│   • List item                                               │
│   • List item                                               │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│ [Action 1]                        [Action 2]                │
└─────────────────────────────────────────────────────────────┘

Background: --surface
Border Radius: 12px
Elevation: 1
Padding: 16px
```

### Input Fields

```
┌─────────────────────────────────────────────────────────────┐
│ Label *                                                     │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ Placeholder text...                                     ││
│ └─────────────────────────────────────────────────────────┘│
│ Helper text or error message                                │
└─────────────────────────────────────────────────────────────┘

Border: 1px solid --outline
Border Radius: 8px
Padding: 14px 16px
Focus Border: 2px solid --primary
Error Border: 1px solid --error
```

### List Items

```
┌─────────────────────────────────────────────────────────────┐
│ ┌────┐                                                   ▶ │
│ │ AV │  Title Text                                         │
│ └────┘  Subtitle • Caption                                 │
└─────────────────────────────────────────────────────────────┘

Padding: 16px horizontal, 12px vertical
Avatar Size: 40px
Divider: 1px --outline (optional)
Tap Target: 48px minimum height
```

### Chips/Pills

```
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  🔵 NEW      │  │  🟠 P2       │  │  ✓ DONE      │
└──────────────┘  └──────────────┘  └──────────────┘

Padding: 4px 12px
Border Radius: 16px (full)
Font: label-medium
Height: 28px
```

### Bottom Navigation

```
┌─────────────────────────────────────────────────────────────┐
│  🏠        👥        📅        📈        ⋯                │
│ Dashboard  Customer  Activity  Pipeline  More              │
└─────────────────────────────────────────────────────────────┘

Height: 56px
Icon Size: 24px
Active: --primary
Inactive: --on-surface-variant
```

### FAB (Floating Action Button)

```
      ┌─────┐
      │  +  │
      └─────┘

Size: 56px
Border Radius: 16px
Elevation: 3
Icon Size: 24px
Position: Bottom right, 16px margin
```

---

## 📱 Responsive Breakpoints

| Breakpoint | Width | Layout |
|------------|-------|--------|
| Mobile | < 600px | Bottom navigation |
| Tablet | 600px - 1200px | Navigation rail (80px) |
| Desktop | > 1200px | Side navigation (260px) |

### Layout Grids

| Screen | Columns | Gutter | Margin |
|--------|---------|--------|--------|
| Mobile | 4 | 16px | 16px |
| Tablet | 8 | 24px | 24px |
| Desktop | 12 | 24px | 32px |

---

## 🌙 Dark Mode (Future)

| Light Token | Dark Value |
|-------------|------------|
| `--background` | `#121212` |
| `--surface` | `#1E1E1E` |
| `--on-surface` | `#E1E1E1` |
| `--on-surface-variant` | `#A0A0A0` |
| `--primary` | `#5C8AFF` |
| `--outline` | `#333333` |

---

## ♿ Accessibility Guidelines

### Color Contrast
- Text: Minimum 4.5:1 ratio (WCAG AA)
- Large text: Minimum 3:1 ratio
- Interactive elements: Minimum 3:1 ratio

### Touch Targets
- Minimum size: 44px × 44px
- Spacing between targets: 8px minimum

### Focus States
- Visible focus ring: 2px --primary outline
- Offset: 2px from element

### Motion
- Respect `prefers-reduced-motion`
- Default animation duration: 200-300ms
- Easing: `cubic-bezier(0.4, 0, 0.2, 1)`

---

## 🖼️ Iconography

### Icon Set
Primary: **Material Symbols** (Outlined, weight 400)

### Icon Sizes
| Size | Dimension | Usage |
|------|-----------|-------|
| small | 18px | Inline, dense |
| medium | 24px | Default, navigation |
| large | 32px | Emphasis, empty states |
| xlarge | 48px | Illustrations |

### Common Icons

| Icon | Name | Usage |
|------|------|-------|
| 🏠 | `home` | Dashboard |
| 👥 | `groups` | Customers |
| 📅 | `calendar_today` | Activities |
| 📈 | `trending_up` | Pipeline |
| ⋯ | `more_horiz` | More menu |
| ➕ | `add` | Create new |
| ✏️ | `edit` | Edit |
| 🗑️ | `delete` | Delete |
| 📍 | `location_on` | Location |
| 📷 | `photo_camera` | Camera |
| 🔔 | `notifications` | Notifications |

---

## 🧪 Design Tokens (Flutter/Dart)

```dart
// colors.dart
class AppColors {
  static const primary = Color(0xFF2E5BFF);
  static const primaryLight = Color(0xFF64B5F6);
  static const primaryDark = Color(0xFF1E3FAE);
  
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
  
  static const background = Color(0xFFF4F6FB);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1A1A1A);
  static const onSurfaceVariant = Color(0xFF666666);
}

// typography.dart
class AppTypography {
  static const fontFamily = 'Inter';
  
  static final headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );
  
  static final bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );
  
  // ... more styles
}

// spacing.dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

// radius.dart
class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const full = 9999.0;
}
```

---

## 📚 Related Documents

- [Navigation Architecture](navigation-architecture.md) - Navigation patterns
- [Screen Flows](screen-flows/) - Screen-by-screen specs
- [Responsive Design](responsive-design.md) - Responsive guidelines
- [Component Library](../assets/components/) - Component assets

---

*Design System ini mengikuti Material Design 3 guidelines dengan kustomisasi untuk branding LeadX.*
