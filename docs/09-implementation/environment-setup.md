# 🛠️ Environment Setup Guide

## Panduan Setup Environment Development LeadX CRM

---

## 📋 Prerequisites

| Tool | Version | Required |
|------|---------|----------|
| Flutter SDK | 3.24.0+ | ✅ |
| Dart | 3.5.0+ | ✅ |
| Node.js | 18+ | ✅ |
| VS Code / Android Studio | Latest | ✅ |
| Xcode (for iOS) | 15+ | macOS only |
| Android Studio | Latest | ✅ |

---

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/[org]/leadx-crm.git
cd leadx-crm
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Setup Environment File

```bash
cp .env.example .env.development
# Edit .env.development with correct values
```

### 4. Run Code Generation (Drift, Riverpod)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Run Application

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios
```

---

## 🔧 Supabase Setup

### Local Development

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to project
supabase link --project-ref <project-id>

# Pull database schema
supabase db pull
```

### Environment Variables

```env
# .env.development
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR...
```

---

## 📱 Platform-Specific Setup

### Android

1. Install Android Studio
2. Install Android SDK via SDK Manager
3. Accept licenses: `flutter doctor --android-licenses`
4. Setup emulator or connect device

### iOS (macOS only)

1. Install Xcode from App Store
2. Install CocoaPods: `sudo gem install cocoapods`
3. Run: `cd ios && pod install`
4. Setup simulator or connect device

### Web

- Chrome or Edge browser required
- No additional setup needed

---

## 🔍 Verification

Run Flutter doctor to verify setup:

```bash
flutter doctor -v
```

Expected output:
```
[✓] Flutter (Channel stable, 3.24.0)
[✓] Android toolchain
[✓] Xcode (if on macOS)
[✓] Chrome
[✓] Android Studio
[✓] VS Code
[✓] Connected device
```

---

## 📚 Related Documents

- [Tech Stack](../03-architecture/tech-stack.md)
- [CI/CD Pipeline](cicd-pipeline.md)
- [Development Phases](development-phases.md)

---

*Environment Setup Guide - January 2025*
