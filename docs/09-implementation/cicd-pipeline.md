# 🚀 CI/CD Pipeline Configuration

## Continuous Integration & Deployment untuk LeadX CRM

---

## 📋 Overview

LeadX menggunakan **GitHub Actions** untuk CI/CD dengan deployment ke **Coolify** untuk frontend dan **Supabase** untuk backend.

---

## 🔧 Pipeline Structure

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CI/CD PIPELINE                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  DEVELOP BRANCH              STAGING BRANCH              MAIN BRANCH        │
│        │                          │                          │              │
│        ▼                          ▼                          ▼              │
│   ┌─────────┐                ┌─────────┐                ┌─────────┐        │
│   │  LINT   │                │  LINT   │                │  LINT   │        │
│   │  TEST   │                │  TEST   │                │  TEST   │        │
│   └────┬────┘                └────┬────┘                └────┬────┘        │
│        │                          │                          │              │
│        ▼                          ▼                          ▼              │
│   ┌─────────┐                ┌─────────┐                ┌─────────┐        │
│   │  BUILD  │                │  BUILD  │                │  BUILD  │        │
│   │  WEB    │                │  WEB    │                │  WEB    │        │
│   └────┬────┘                └────┬────┘                └────┬────┘        │
│        │                          │                          │              │
│        ▼                          ▼                          ▼              │
│   Development               Staging/UAT                 Production         │
│   Environment               Environment                 Environment        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📝 GitHub Actions Workflows

### Main Workflow: `.github/workflows/ci.yml`

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [develop, staging, main]
  pull_request:
    branches: [develop, staging, main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter analyze
      - run: dart format --set-exit-if-changed .

  test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v4
        with:
          files: coverage/lcov.info

  build-web:
    runs-on: ubuntu-latest
    needs: test
    if: github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build web --release
      - uses: actions/upload-artifact@v4
        with:
          name: web-build
          path: build/web

  deploy:
    runs-on: ubuntu-latest
    needs: build-web
    steps:
      - name: Deploy to Coolify
        # Trigger Coolify webhook
        run: |
          curl -X POST ${{ secrets.COOLIFY_WEBHOOK_URL }}
```

---

## 🌍 Environment Configuration

### Branch → Environment Mapping

| Branch | Environment | Database | Domain |
|--------|-------------|----------|--------|
| develop | Development | Supabase Dev | dev.leadx.id |
| staging | UAT | Supabase Staging | staging.leadx.id |
| main | Production | Supabase Prod | app.leadx.id |

### Environment Variables

```bash
# .env.development
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=xxx
API_URL=https://dev.leadx.id/api

# .env.staging
SUPABASE_URL=https://yyy.supabase.co
SUPABASE_ANON_KEY=yyy
API_URL=https://staging.leadx.id/api

# .env.production
SUPABASE_URL=https://zzz.supabase.co
SUPABASE_ANON_KEY=zzz
API_URL=https://app.leadx.id/api
```

---

## 📱 Mobile Build Pipeline

### Build APK/IPA

```yaml
build-android:
  runs-on: ubuntu-latest
  needs: test
  if: github.ref == 'refs/heads/staging' || github.ref == 'refs/heads/main'
  steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
    - run: flutter build apk --release
    - uses: actions/upload-artifact@v4
      with:
        name: app-release.apk
        path: build/app/outputs/apk/release/

build-ios:
  runs-on: macos-latest
  needs: test
  if: github.ref == 'refs/heads/staging' || github.ref == 'refs/heads/main'
  steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
    - run: flutter build ipa --release
```

---

## 🔐 Secrets Required

| Secret | Description |
|--------|-------------|
| COOLIFY_WEBHOOK_URL | Coolify deployment trigger |
| SUPABASE_PROJECT_ID | Supabase project ID |
| SUPABASE_ACCESS_TOKEN | Supabase CLI token |
| CODECOV_TOKEN | Code coverage upload |

---

## 📚 Related Documents

- [Deployment Guide](deployment-guide.md)
- [Testing Strategy](testing-strategy.md)
- [Development Phases](development-phases.md)

---

*CI/CD Documentation - January 2025*
