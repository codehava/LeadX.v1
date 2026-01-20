# 📖 Glossary

## Glosarium Istilah LeadX CRM

---

## A

### Activity
Aktivitas yang dilakukan oleh RM dalam proses sales, seperti Visit, Call, Meeting, dll. Activity dapat dijadwalkan (Scheduled) atau dicatat langsung (Immediate).

### Admin
Role pengguna dengan akses penuh untuk mengelola master data, user, dan konfigurasi sistem.

### API (Application Programming Interface)
Antarmuka pemrograman yang memungkinkan aplikasi berkomunikasi dengan server.

### Assigned RM
Relationship Manager yang bertanggung jawab atas customer atau pipeline tertentu.

---

## B

### BH (Business Head)
Kepala unit bisnis yang membawahi beberapa RM. BH bertanggung jawab atas target tim dan menjalankan Team Cadence.

### BM (Branch Manager)
Kepala cabang yang membawahi beberapa BH. BM bertanggung jawab atas target cabang dan menjalankan Branch Cadence.

### Broker
Pihak ketiga (perusahaan/individu) yang mereferensikan bisnis ke perusahaan. Juga disebut Agent.

### Branch
Kantor Cabang PT Askrindo yang membawahi beberapa tim sales.

---

## C

### Cadence
Siklus meeting rutin untuk akuntabilitas dalam framework 4DX. Ada beberapa level: Team Cadence (mingguan), Branch Cadence (mingguan), Regional Cadence (bulanan).

### Cadence Meeting
Pertemuan rutin di mana tim melaporkan pencapaian, membahas hambatan, dan membuat komitmen untuk periode berikutnya.

### Check-in
Proses pencatatan GPS location saat melakukan aktivitas di lokasi customer.

### Class of Business (COB)
Kategori utama produk asuransi, misalnya Surety Bond, General Insurance, Credit Insurance.

### Conflict Resolution
Proses penyelesaian ketika data di local dan server berbeda setelah sync.

### CRM (Customer Relationship Management)
Sistem untuk mengelola hubungan dan interaksi dengan customer.

### CRUD
Create, Read, Update, Delete - operasi dasar pada data.

---

## D

### Dashboard
Halaman utama aplikasi yang menampilkan ringkasan informasi penting seperti scoreboard, aktivitas hari ini, dan pipeline highlights.

### Decline
Status pipeline yang ditolak/tidak berhasil. Memerlukan alasan decline.

### Drift
Library Flutter untuk local database (SQLite) dengan type-safe queries.

---

## E

### Edge Functions
Serverless functions yang berjalan di edge (dekat user). Digunakan untuk logika custom di Supabase.

### Expected Close Date
Perkiraan tanggal closing pipeline.

---

## F

### Final Premium
Nilai premium yang dikonfirmasi setelah pipeline di-close sebagai WON.

### 4DX (Four Disciplines of Execution)
Framework eksekusi strategi dari FranklinCovey yang terdiri dari: Focus on WIG, Act on Lead Measures, Keep a Compelling Scoreboard, Create a Cadence of Accountability.

### Flutter
Framework UI dari Google untuk membangun aplikasi cross-platform (iOS, Android, Web) dari single codebase.

### Full Sync
Proses sinkronisasi lengkap semua data dari server, biasanya dilakukan saat pertama kali login.

---

## G

### GPS (Global Positioning System)
Sistem navigasi satelit untuk menentukan lokasi. Digunakan untuk verify aktivitas field.

### GoTrue
Komponen autentikasi Supabase yang menangani login, session, dan token management.

---

## H

### Hierarchy
Struktur organisasi yang menentukan hubungan atasan-bawahan antar user. Digunakan untuk akses data dan reporting.

### HVC (High Value Customer)
Customer dengan nilai bisnis tinggi yang perlu perhatian khusus. Contoh: Kawasan Industri, Bank, BUMN Group.

---

## I

### Immediate Activity
Aktivitas yang dicatat langsung (Mark as Done) tanpa dijadwalkan terlebih dahulu. Mendapat bonus scoring.

### Incremental Sync
Proses sinkronisasi hanya data yang berubah sejak sync terakhir, bukan seluruh data.

---

## J

### JWT (JSON Web Token)
Token digital untuk autentikasi yang berisi informasi user. Digunakan untuk mengamankan API requests.

---

## K

### Key Person
Kontak penting di dalam organisasi customer, broker, atau HVC. Contoh: Direktur, Manager Pengadaan.

### KPI (Key Performance Indicator)
Indikator kunci untuk mengukur performa. Dalam 4DX, KPI terbagi menjadi Lead dan Lag Measures.

---

## L

### Lag Measure
Ukuran hasil akhir yang ingin dicapai. Contoh: Jumlah pipeline won, total premium. Lag measures bersifat historis dan tidak dapat dipengaruhi secara langsung.

### Lead Measure
Ukuran aktivitas yang dapat dikendalikan dan diprediksi akan menghasilkan lag measure. Contoh: Jumlah visit, jumlah call. Lead measures bersifat predictive dan influenceable.

### Lead Source
Sumber asal lead/prospek. Contoh: Direct, Broker, Referral, Event.

### Leaderboard
Papan peringkat yang menampilkan ranking user berdasarkan score.

### Line of Business (LOB)
Sub-kategori produk di dalam Class of Business. Contoh: Bid Bond, Performance Bond (di bawah Surety Bond).

### Local Database
Database SQLite yang tersimpan di device untuk mendukung offline mode.

---

## M

### MVP (Minimum Viable Product)
Versi produk dengan fitur minimum yang cukup untuk digunakan dan mendapat feedback.

### Master Data
Data referensi yang relatif statis seperti provinces, cities, COB, LOB, dll.

---

## N

### NIP
Nomor Induk Pegawai - ID karyawan di perusahaan.

### NPWP
Nomor Pokok Wajib Pajak - Tax ID customer.

### Notification
Pemberitahuan dalam aplikasi untuk reminder, update, atau informasi penting.

---

## O

### Offline Mode
Mode operasi aplikasi tanpa koneksi internet. Semua fitur tetap tersedia dengan data lokal.

### Offline-First
Arsitektur aplikasi yang memprioritaskan operasi lokal, dengan sync ke server sebagai secondary.

---

## P

### P1, P2, P3 (Pipeline Stages)
Tahapan pipeline berdasarkan probabilitas closing:
- P3: Cold (25% probability)
- P2: Warm (50% probability)  
- P1: Hot (75% probability)

### PIC (Person In Charge)
Orang yang bertanggung jawab atau menjadi kontak utama.

### Pipeline
Representasi prospek bisnis dari tahap awal hingga closing. Mengikuti funnel stages: NEW → P3 → P2 → P1 → ACCEPTED/DECLINED.

### PostGIS
Ekstensi PostgreSQL untuk geospatial data dan queries.

### PostgreSQL
Database relasional open-source yang digunakan oleh Supabase.

### PostgREST
Auto-generated REST API dari PostgreSQL schema.

### Potential Premium
Estimasi nilai premium dari pipeline sebelum closing.

### PRD (Product Requirements Document)
Dokumen yang mendeskripsikan requirements produk.

---

## Q

### Q1, Q2, Q3, Q4 (Cadence Questions)
Empat pertanyaan dalam pre-meeting form Cadence:
- Q1: Komitmen minggu lalu
- Q2: Apa yang tercapai
- Q3: Hambatan yang dihadapi
- Q4: Komitmen minggu depan

---

## R

### RBAC (Role-Based Access Control)
Model kontrol akses berdasarkan role pengguna.

### Regional Office
Kantor Wilayah yang membawahi beberapa Branch.

### Realtime
Fitur Supabase untuk push notifications via WebSocket.

### RM (Relationship Manager)
Sales person yang bertanggung jawab mengelola customer dan pipeline. Role operasional utama pengguna aplikasi.

### RLS (Row Level Security)
Fitur PostgreSQL untuk mengontrol akses data di level baris berdasarkan user.

### ROH (Regional Office Head)
Kepala Kantor Wilayah yang membawahi beberapa BM.

### Riverpod
Library state management untuk Flutter yang type-safe dan testable.

---

## S

### Scheduled Activity
Aktivitas yang dijadwalkan untuk dilakukan di masa depan. Status awal: PLANNED.

### Scoreboard
Papan skor yang menampilkan lead measures, lag measures, dan total score dalam format visual yang compelling.

### Score
Nilai performa user berdasarkan pencapaian lead dan lag measures dalam satu periode.

### Scoring Period
Periode penilaian (mingguan, bulanan, quarterly) untuk menghitung score.

### Silent GPS Capture
Pengambilan lokasi GPS secara background tanpa prompt ke user.

### Soft Delete
Penghapusan data dengan mengubah flag is_active menjadi false, bukan menghapus record.

### Sprint
Periode pengembangan (biasanya 2 minggu) dalam metodologi Agile.

### Supabase
Platform Backend-as-a-Service open-source yang menyediakan PostgreSQL, Authentication, Storage, dan Realtime.

### Sync
Proses sinkronisasi data antara local database dan server.

### Sync Queue
Antrian operasi yang menunggu untuk di-sync ke server.

---

## T

### Target
Nilai yang harus dicapai untuk setiap measure dalam satu periode.

### TSI (Total Sum Insured)
Nilai pertanggungan total dalam polis asuransi.

---

## U

### UAT (User Acceptance Testing)
Fase testing oleh end user sebelum go-live.

### UUID (Universally Unique Identifier)
ID unik 128-bit yang digunakan sebagai primary key.

---

## V

### Visit
Jenis aktivitas kunjungan fisik ke lokasi customer.

---

## W

### Weighted Value
Nilai pipeline yang dihitung sebagai Potential Premium × Probability. Digunakan untuk forecasting.

### WIG (Wildly Important Goal)
Tujuan paling penting yang harus difokuskan dalam framework 4DX.

### WON
Status pipeline yang berhasil closing (ACCEPTED).

---

## X, Y, Z

*Tidak ada istilah yang dimulai dengan X, Y, atau Z*

---

## 📚 Related Documents

- [4DX Overview](../07-4dx-framework/4dx-overview.md) - Detail framework 4DX
- [Functional Requirements](../02-requirements/functional-requirements.md) - Requirements detail
- [Database Schema](../04-database/schema-overview.md) - Entity definitions

---

*Glosarium ini akan diperbarui seiring perkembangan proyek.*
