# ❓ FAQ

## Frequently Asked Questions - LeadX CRM

---

## 📱 General

### Apa itu LeadX CRM?
LeadX CRM adalah mobile-first Customer Relationship Management dengan 4DX (4 Disciplines of Execution) framework terintegrasi, dirancang khusus untuk tim sales lapangan di industri asuransi.

### Platform apa yang didukung?
- **Mobile**: iOS dan Android (Flutter)
- **Web Admin**: Browser modern (Chrome, Safari, Edge)

### Apakah bisa digunakan offline?
Ya! LeadX dirancang offline-first. Semua fitur utama berfungsi tanpa internet dan sync otomatis saat online.

---

## 🔐 Authentication & Security

### Bagaimana sistem login?
Login menggunakan email dan password. Session menggunakan JWT dengan refresh token untuk keamanan.

### Berapa lama session aktif?
- Access token: 1 jam
- Refresh token: 7 hari
- Auto-refresh saat access token expire

### Bagaimana jika lupa password?
Gunakan fitur "Forgot Password" untuk menerima reset link via email. Link valid 24 jam.

---

## 📊 Pipeline Management

### Apa saja stage pipeline?
```
NEW (10%) → P3 (25%) → P2 (50%) → P1 (75%) → ACCEPTED (100%)
                ↓          ↓          ↓
              DECLINED   DECLINED   DECLINED (0%)
```

### Bagaimana weighted value dihitung?
`Weighted Value = Potential Premium × Probability Stage`

Contoh: Pipeline Rp 100jt di P2 (50%) = Rp 50jt weighted value

### Apa itu Pipeline Referral?
Fitur untuk meneruskan prospek ke RM lain (biasanya di cabang berbeda). Referrer mendapat bonus saat pipeline WON.

---

## 📅 Activities

### Apa perbedaan Scheduled vs Immediate activity?
- **Scheduled**: Direncanakan sebelumnya, muncul di calendar
- **Immediate**: Log aktivitas yang baru selesai, langsung COMPLETED

### Apakah GPS wajib untuk visit?
Ya, GPS ter-capture otomatis (silent) saat check-in/execute. Jika jarak >500m dari lokasi customer, ada warning tapi tetap bisa override dengan alasan.

### Apa bonus untuk immediate activity?
Immediate activities mendapat +15% scoring bonus untuk mendorong real-time logging.

---

## 🎯 4DX Framework

### Apa itu WIG?
WIG (Wildly Important Goal) adalah goal utama yang HARUS dicapai. Format: "From X to Y by When".

### Berapa maksimal WIG per level?
Default 2 WIG per level (configurable oleh Admin). Ini untuk menjaga fokus tim.

### Apa perbedaan Lead vs Lag measures?
- **Lead Measures**: Aktivitas yang bisa dikontrol (visits, calls, pipelines created)
- **Lag Measures**: Hasil yang ingin dicapai (premium won, conversion rate)

### Bagaimana score dihitung?
```
Final Score = (Lead Score × 60%) + (Lag Score × 40%) + Bonuses - Penalties
```

---

## 📅 Cadence Meeting

### Apa itu Pre-Cadence Form (Q1-Q4)?
Form yang harus diisi sebelum meeting mingguan:
- Q1: Komitmen minggu lalu (auto-filled)
- Q2: Apa yang tercapai?
- Q3: Hambatan yang dihadapi?
- Q4: Komitmen minggu depan?

### Kapan deadline submit form?
Default 24 jam sebelum meeting. Late submission mendapat penalty point.

### Apa konsekuensi tidak hadir meeting?
No-show tanpa notifikasi mendapat -5 points. Excused dengan notifikasi 24 jam sebelumnya tidak ada penalty.

---

## 👥 Roles & Hierarchy

### Apa saja role yang tersedia?
| Role | Level | Scope |
|------|-------|-------|
| RM | Field | Own data |
| BH | Team Lead | Team data |
| BM | Branch | Branch data |
| ROH | Regional | Regional data |
| Admin | System | All data |

### Apakah BH wajib ada?
Tidak. Struktur fleksibel - cabang kecil bisa langsung BM → RM tanpa BH.

---

## 🏢 HVC & Broker

### Apa itu HVC?
HVC (High Value Customer) adalah pengelompokan strategis seperti Kawasan Industri, Banking Group, atau Holding Company.

### Apakah customer harus terhubung ke HVC?
Tidak. Customer bisa standalone atau linked ke HVC (many-to-many relationship).

### Bagaimana cara menambah broker?
Broker hanya bisa ditambah oleh Admin via menu Master Data.

---

## 📚 Related Documents

- [Glossary](glossary.md) - Daftar istilah
- [User Stories](../02-requirements/user-stories.md) - Kebutuhan per fitur
- [Functional Requirements](../02-requirements/functional-requirements.md) - Spesifikasi lengkap

---

*FAQ diupdate: January 2025*
