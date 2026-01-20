# 🌍 Environment Configuration

## Konfigurasi Environment LeadX CRM

---

## 📋 Overview

Dokumen ini berisi konfigurasi environment untuk Development, UAT (User Acceptance Testing), dan Production.

---

## 🔧 Environment Summary

| Environment | Branch | Purpose | URL |
|-------------|--------|---------|-----|
| **Development** | `Develop` | Local development & testing | `localhost` |
| **UAT** | `Staging` | User testing before production | `TBD` |
| **Production** | `main` | Live production | `TBD` |

---

## 📦 Development Environment

### Application Config

```yaml
# .env.development

# App Configuration
APP_NAME=LeadX CRM (Dev)
APP_ENV=development
APP_DEBUG=true
APP_URL=http://localhost:3000

# API & Backend
API_URL=http://localhost:8080
SUPABASE_URL=<TO_BE_FILLED>
SUPABASE_ANON_KEY=<TO_BE_FILLED>
SUPABASE_SERVICE_KEY=<TO_BE_FILLED>

# Database (Supabase PostgreSQL)
DATABASE_URL=<TO_BE_FILLED>
DATABASE_HOST=<TO_BE_FILLED>
DATABASE_PORT=5432
DATABASE_NAME=leadx_dev
DATABASE_USER=<TO_BE_FILLED>
DATABASE_PASSWORD=<TO_BE_FILLED>

# Authentication
JWT_SECRET=<TO_BE_FILLED>
JWT_ACCESS_EXPIRY=3600
JWT_REFRESH_EXPIRY=604800

# Storage (Supabase Storage)
STORAGE_BUCKET=leadx-dev
STORAGE_URL=<TO_BE_FILLED>

# External Services
SENTRY_DSN=<TO_BE_FILLED>
SENTRY_ENVIRONMENT=development

# Feature Flags
FEATURE_REFERRAL=true
FEATURE_BULK_UPLOAD=true
FEATURE_GPS_VERIFICATION=true
FEATURE_OFFLINE_MODE=true

# Logging
LOG_LEVEL=debug
LOG_TO_CONSOLE=true
LOG_TO_FILE=false
```

### Flutter Config

```dart
// lib/config/env_development.dart

class DevEnvironment {
  static const String appName = 'LeadX CRM (Dev)';
  static const String environment = 'development';
  
  // Supabase
  static const String supabaseUrl = '<TO_BE_FILLED>';
  static const String supabaseAnonKey = '<TO_BE_FILLED>';
  
  // API
  static const String apiBaseUrl = 'http://localhost:8080';
  
  // Feature Flags
  static const bool enableDebugMode = true;
  static const bool enableOfflineMode = true;
  static const bool enableGpsVerification = true;
  
  // GPS Config
  static const int gpsAccuracyThreshold = 100; // meters
  static const int gpsDistanceWarning = 500; // meters
}
```

---

## 🧪 UAT Environment

### Application Config

```yaml
# .env.uat

# App Configuration
APP_NAME=LeadX CRM (UAT)
APP_ENV=uat
APP_DEBUG=false
APP_URL=<TO_BE_FILLED>

# API & Backend
API_URL=<TO_BE_FILLED>
SUPABASE_URL=<TO_BE_FILLED>
SUPABASE_ANON_KEY=<TO_BE_FILLED>
SUPABASE_SERVICE_KEY=<TO_BE_FILLED>

# Database (Supabase PostgreSQL)
DATABASE_URL=<TO_BE_FILLED>
DATABASE_HOST=<TO_BE_FILLED>
DATABASE_PORT=5432
DATABASE_NAME=leadx_uat
DATABASE_USER=<TO_BE_FILLED>
DATABASE_PASSWORD=<TO_BE_FILLED>

# Authentication
JWT_SECRET=<TO_BE_FILLED>
JWT_ACCESS_EXPIRY=3600
JWT_REFRESH_EXPIRY=604800

# Storage (Supabase Storage)
STORAGE_BUCKET=leadx-uat
STORAGE_URL=<TO_BE_FILLED>

# External Services
SENTRY_DSN=<TO_BE_FILLED>
SENTRY_ENVIRONMENT=uat

# Feature Flags
FEATURE_REFERRAL=true
FEATURE_BULK_UPLOAD=true
FEATURE_GPS_VERIFICATION=true
FEATURE_OFFLINE_MODE=true

# Logging
LOG_LEVEL=info
LOG_TO_CONSOLE=false
LOG_TO_FILE=true
```

### Flutter Config

```dart
// lib/config/env_uat.dart

class UatEnvironment {
  static const String appName = 'LeadX CRM (UAT)';
  static const String environment = 'uat';
  
  // Supabase
  static const String supabaseUrl = '<TO_BE_FILLED>';
  static const String supabaseAnonKey = '<TO_BE_FILLED>';
  
  // API
  static const String apiBaseUrl = '<TO_BE_FILLED>';
  
  // Feature Flags
  static const bool enableDebugMode = false;
  static const bool enableOfflineMode = true;
  static const bool enableGpsVerification = true;
  
  // GPS Config
  static const int gpsAccuracyThreshold = 100; // meters
  static const int gpsDistanceWarning = 500; // meters
}
```

### UAT Deployment Info

| Field | Value |
|-------|-------|
| **Server** | `<TO_BE_FILLED>` |
| **Domain** | `<TO_BE_FILLED>` |
| **SSL Certificate** | `<TO_BE_FILLED>` |
| **CI/CD** | GitHub Actions → Coolify |
| **Branch** | `Staging` |

---

## 🚀 Production Environment

### Application Config

```yaml
# .env.production

# App Configuration
APP_NAME=LeadX CRM
APP_ENV=production
APP_DEBUG=false
APP_URL=<TO_BE_FILLED>

# API & Backend
API_URL=<TO_BE_FILLED>
SUPABASE_URL=<TO_BE_FILLED>
SUPABASE_ANON_KEY=<TO_BE_FILLED>
SUPABASE_SERVICE_KEY=<TO_BE_FILLED>

# Database (Supabase PostgreSQL)
DATABASE_URL=<TO_BE_FILLED>
DATABASE_HOST=<TO_BE_FILLED>
DATABASE_PORT=5432
DATABASE_NAME=leadx_prod
DATABASE_USER=<TO_BE_FILLED>
DATABASE_PASSWORD=<TO_BE_FILLED>

# Authentication
JWT_SECRET=<TO_BE_FILLED>
JWT_ACCESS_EXPIRY=3600
JWT_REFRESH_EXPIRY=604800

# Storage (Supabase Storage)
STORAGE_BUCKET=leadx-prod
STORAGE_URL=<TO_BE_FILLED>

# External Services
SENTRY_DSN=<TO_BE_FILLED>
SENTRY_ENVIRONMENT=production

# Feature Flags
FEATURE_REFERRAL=true
FEATURE_BULK_UPLOAD=true
FEATURE_GPS_VERIFICATION=true
FEATURE_OFFLINE_MODE=true

# Logging
LOG_LEVEL=warning
LOG_TO_CONSOLE=false
LOG_TO_FILE=true

# Performance
CACHE_DRIVER=redis
REDIS_URL=<TO_BE_FILLED>

# Rate Limiting
RATE_LIMIT_ENABLED=true
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_WINDOW=60
```

### Flutter Config

```dart
// lib/config/env_production.dart

class ProductionEnvironment {
  static const String appName = 'LeadX CRM';
  static const String environment = 'production';
  
  // Supabase
  static const String supabaseUrl = '<TO_BE_FILLED>';
  static const String supabaseAnonKey = '<TO_BE_FILLED>';
  
  // API
  static const String apiBaseUrl = '<TO_BE_FILLED>';
  
  // Feature Flags
  static const bool enableDebugMode = false;
  static const bool enableOfflineMode = true;
  static const bool enableGpsVerification = true;
  
  // GPS Config
  static const int gpsAccuracyThreshold = 100; // meters
  static const int gpsDistanceWarning = 500; // meters
}
```

### Production Deployment Info

| Field | Value |
|-------|-------|
| **Server** | `<TO_BE_FILLED>` |
| **Domain** | `<TO_BE_FILLED>` |
| **SSL Certificate** | `<TO_BE_FILLED>` |
| **CI/CD** | GitHub Actions → Coolify |
| **Branch** | `main` |
| **CDN** | Cloudflare |
| **Backup** | Daily, 30-day retention |

---

## 🔐 Secrets Management

### Required Secrets per Environment

| Secret Key | Dev | UAT | Prod | Notes |
|------------|-----|-----|------|-------|
| `SUPABASE_URL` | ⬜ | ⬜ | ⬜ | Supabase project URL |
| `SUPABASE_ANON_KEY` | ⬜ | ⬜ | ⬜ | Public anon key |
| `SUPABASE_SERVICE_KEY` | ⬜ | ⬜ | ⬜ | Server-side only |
| `DATABASE_URL` | ⬜ | ⬜ | ⬜ | Full connection string |
| `JWT_SECRET` | ⬜ | ⬜ | ⬜ | Min 256 bits |
| `SENTRY_DSN` | ⬜ | ⬜ | ⬜ | Error tracking |

### Secrets Storage

| Environment | Storage Method |
|-------------|---------------|
| Development | `.env.development` (gitignored) |
| UAT | Coolify Environment Variables |
| Production | Coolify Environment Variables |

---

## 🌐 Infrastructure Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LEADX INFRASTRUCTURE                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                     │
│  │ DEVELOPMENT │    │     UAT     │    │ PRODUCTION  │                     │
│  │─────────────│    │─────────────│    │─────────────│                     │
│  │ localhost   │    │ uat.leadx   │    │ app.leadx   │                     │
│  │ Branch:     │    │ Branch:     │    │ Branch:     │                     │
│  │ Develop     │    │ Staging     │    │ main        │                     │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘                     │
│         │                  │                  │                             │
│         └───────────┬──────┴──────────────────┘                             │
│                     │                                                        │
│              ┌──────▼──────┐                                                │
│              │   GITHUB    │                                                │
│              │ codehava/   │                                                │
│              │ LeadX.v1    │                                                │
│              └──────┬──────┘                                                │
│                     │ Webhook                                               │
│              ┌──────▼──────┐                                                │
│              │   COOLIFY   │                                                │
│              │ CI/CD       │                                                │
│              └──────┬──────┘                                                │
│                     │                                                        │
│         ┌───────────┼───────────┐                                           │
│         │           │           │                                           │
│  ┌──────▼─────┐ ┌───▼────┐ ┌────▼────┐                                     │
│  │ VPS UAT    │ │ VPS    │ │ SUPABASE│                                     │
│  │ <TBD>      │ │ PROD   │ │ Backend │                                     │
│  └────────────┘ └────────┘ └─────────┘                                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📱 Mobile App Build Flavors

### Android

```groovy
// android/app/build.gradle

flavorDimensions "environment"

productFlavors {
    development {
        dimension "environment"
        applicationIdSuffix ".dev"
        versionNameSuffix "-dev"
        resValue "string", "app_name", "LeadX Dev"
    }
    uat {
        dimension "environment"
        applicationIdSuffix ".uat"
        versionNameSuffix "-uat"
        resValue "string", "app_name", "LeadX UAT"
    }
    production {
        dimension "environment"
        resValue "string", "app_name", "LeadX CRM"
    }
}
```

### iOS

```swift
// ios/Runner/Info.plist configurations per scheme

// Development scheme
CFBundleDisplayName = "LeadX Dev"
CFBundleIdentifier = "com.askrindo.leadx.dev"

// UAT scheme
CFBundleDisplayName = "LeadX UAT"
CFBundleIdentifier = "com.askrindo.leadx.uat"

// Production scheme
CFBundleDisplayName = "LeadX CRM"
CFBundleIdentifier = "com.askrindo.leadx"
```

---

## 🔄 Environment Switching

### Flutter Command

```bash
# Development
flutter run --flavor development -t lib/main_development.dart

# UAT
flutter run --flavor uat -t lib/main_uat.dart

# Production
flutter run --flavor production -t lib/main_production.dart
```

### Build Commands

```bash
# Development APK
flutter build apk --flavor development -t lib/main_development.dart

# UAT APK
flutter build apk --flavor uat -t lib/main_uat.dart

# Production APK (Release)
flutter build apk --flavor production -t lib/main_production.dart --release

# Production AAB (Play Store)
flutter build appbundle --flavor production -t lib/main_production.dart --release
```

---

## ✅ Environment Checklist

### Development Setup
- [ ] Clone repository
- [ ] Copy `.env.example` to `.env.development`
- [ ] Fill in Supabase credentials
- [ ] Run `flutter pub get`
- [ ] Run app with development flavor

### UAT Deployment
- [ ] Configure Coolify for Staging branch
- [ ] Set environment variables in Coolify
- [ ] Configure SSL certificate
- [ ] Test deployment pipeline
- [ ] Verify all features

### Production Deployment
- [ ] Configure Coolify for main branch
- [ ] Set production environment variables
- [ ] Configure SSL certificate
- [ ] Set up monitoring (Sentry)
- [ ] Configure backup schedule
- [ ] Load testing completed
- [ ] Security audit completed

---

## 📚 Related Documents

- [Deployment Guide](deployment-guide.md)
- [Security Architecture](../03-architecture/security-architecture.md)
- [Tech Stack](../03-architecture/tech-stack.md)

---

*Environment configuration version 1.0 - January 2025*
