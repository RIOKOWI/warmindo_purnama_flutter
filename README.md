# Warmindo Purnama - Aplikasi Mobile POS Terintegrasi

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue)
![Dart](https://img.shields.io/badge/Dart-3.0-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## Daftar Isi

1. [Deskripsi Proyek](#deskripsi-proyek)
2. [Fitur Utama](#fitur-utama)
3. [Arsitektur Sistem](#arsitektur-sistem)
4. [Teknologi yang Digunakan](#teknologi-yang-digunakan)
5. [Instalasi dan Setup](#instalasi-dan-setup)
6. [Struktur Proyek](#struktur-proyek)
7. [Dokumentasi API](#dokumentasi-api)
8. [Panduan Penggunaan](#panduan-penggunaan)
9. [Panduan Pengembangan](#panduan-pengembangan)
10. [Testing](#testing)
11. [Deployment](#deployment)
12. [Kontributor](#kontributor)

---

## Deskripsi Proyek

### 1.1 Identitas Aplikasi

| Item | Detail |
|------|--------|
| **Nama Aplikasi** | Warmindo Purnama |
| **Jenis** | Aplikasi Mobile (Android & iOS) dengan Backend API |
| **Platform** | Flutter (Frontend) + Laravel (Backend) |
| **Versi** | 1.0.0+1 |

### 1.2 Latar Belakang

Warmindo Purnama adalah aplikasi Point of Sale (POS) dan sistem manajemen restoran berbasis mobile untuk **Warmindo Purnama**, sebuah restoran mie instan yang berlokasi di Indonesia. Aplikasi ini dikembangkan untuk mengatasi beberapa permasalahan operasional restoran, yaitu:

1. **Manajemen pesanan manual** yang rawan kesalahan dan memakan waktu lama
2. **Pembayaran terbatas** hanya dengan uang tunai
3. **Monitoring penjualan sulit** dilakukan secara real-time
4. **Manajemen meja** yang tidak efisien
5. **Laporan manual** yang memakan waktu dan rentan error

### 1.3 Tujuan Pengembangan

| Tujuan | Deskripsi |
|--------|-----------|
| **Otomatisasi Pesanan** | Mengurangi antrean dan kesalahan pencatatan manual |
| **Pembayaran Digital** | Integrasi QRIS dan Virtual Account dari berbagai bank |
| **Efisiensi Operasional** | Dashboard analytics untuk pengambilan keputusan bisnis |
| **Pengalaman Pelanggan** | Self-order melalui smartphone dengan UI modern |

### 1.4 Target Pengguna

| Role | Deskripsi | Akses Utama |
|------|----------|------------|
| **Customer** | Pelanggan restoran | Register, Login, Pesan makanan, Checkout, Pembayaran, Riwayat order |
| **Kasir** | Staff kasir | Semua akses Customer + Manajemen pembayaran, Status meja |
| **Admin** | Pemilik/Manajer | Full access + CRUD produk, kategori, user, meja, analytics |

---

## Fitur Utama

### 2.1 Fitur Berdasarkan Role

#### Customer (Pelanggan)

| No | Fitur | Deskripsi |
|----|-------|-----------|
| 1 | Register & Login | Registrasi dan login dengan email/password |
| 2 | Katalog Produk | Browse menu dengan filter kategori |
| 3 | Keranjang | Tambah, edit, hapus item keranjang |
| 4 | Checkout | Pilih tipe pesanan (Dine-in/Take-away) dan meja |
| 5 | Pembayaran | QRIS dan Virtual Account 10 bank |
| 6 | Riwayat Pesanan | Lihat detail dan status pesanan |
| 7 | Profil | Kelola data profil dan password |

#### Kasir

| No | Fitur | Deskripsi |
|----|-------|-----------|
| 1 | Daftar Pesanan | Monitor semua pesanan masuk |
| 2 | Status Meja | Update status meja (available/occupied) |
| 3 | Daftar Pembayaran | Monitoring pembayaran masuk |

#### Admin

| No | Fitur | Deskripsi |
|----|-------|-----------|
| 1 | CRUD Produk | Tambah, edit, hapus produk dengan upload gambar |
| 2 | CRUD Kategori | Kelola kategori produk |
| 3 | CRUD Meja | Kelola meja restoran |
| 4 | CRUD User | Kelola akun staff (kasir & admin) |
| 5 | Restore User | Pulihkan akun yang dihapus |
| 6 | Dashboard Analytics | Laporan penjualan dan grafik |

### 2.2 Fitur Teknis

| No | Fitur | Deskripsi |
|----|-------|-----------|
| 1 | Push Notification | Notifikasi push via Firebase Cloud Messaging |
| 2 | Secure Storage | Token tersimpan dengan enkripsi RSA+AES |
| 3 | Image Upload | Upload gambar produk dengan crop |
| 4 | Bluetooth Printing | Cetak struk via printer Bluetooth |
| 5 | PDF Generation | Generate laporan dalam format PDF |
| 6 | Skeleton Loading | Loading UI yang menarik |
| 7 | Animasi Lottie | Animasi sukses dan loading |

### 2.3 Metode Pembayaran

| Metode | Kode | Keterangan |
|--------|------|------------|
| QRIS | `qris` | Semua bank mendukung |
| BNI VA | `bni_va` | Min Rp 10.000 |
| BRI VA | `bri_va` | Min Rp 10.000 |
| CIMB VA | `cimb_niaga_va` | Min Rp 10.000 |
| Permata VA | `permata_va` | Min Rp 10.000 |
| Maybank VA | `maybank_va` | Min Rp 10.000 |
| Sampoerna VA | `sampoerna_va` | Min Rp 10.000 |
| BNC VA | `bnc_va` | Min Rp 10.000 |
| ATM Bersama VA | `atm_bersama_va` | Min Rp 10.000 |
| Artha Graha VA | `artha_graha_va` | Min Rp 10.000 |

---

## Arsitektur Sistem

### 3.1 Arsitektur Aplikasi Mobile (Flutter)

Aplikasi menggunakan **Clean Architecture** dengan 3 layer utama:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Pages     │  │  Providers  │  │      Widgets        │ │
│  │  (Screens)  │  │  (State)    │  │   (Reusable UI)     │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
│         │              │                    │               │
│         └──────────────┼────────────────────┘               │
│                        │                                    │
├────────────────────────┼────────────────────────────────────┤
│                      DOMAIN LAYER                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Repositories (Abstract)                  │  │
│  │  - Define interfaces                                 │  │
│  │  - Business logic contracts                         │  │
│  └──────────────────────────────────────────────────────┘  │
│                        │                                    │
├────────────────────────┼────────────────────────────────────┤
│                      DATA LAYER                            │
│  ┌─────────────────────┐  ┌────────────────────────────┐  │
│  │    Datasources      │  │         Models             │  │
│  │  (API calls, DTO)   │  │  (fromJson, toJson)        │  │
│  └─────────────────────┘  └────────────────────────────┘  │
│                        │                                    │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           Repository Implementations                   │  │
│  │  - Concrete logic                                    │  │
│  │  - Error handling                                    │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Arsitektur Backend (Laravel)

Backend menggunakan **Layered Architecture** dengan Repository Pattern:

```
┌────────────────────────────────────────────────────────────┐
│                    CONTROLLER (Thin)                       │
│  - Handle HTTP request/response                            │
│  - Validation via FormRequest                              │
│  - Delegate to Service                                     │
└──────────────────────────┬─────────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────────┐
│                       SERVICE                              │
│  - Business logic                                         │
│  - Orchestrate repositories                               │
│  - Transaction management                                 │
└──────────────────────────┬─────────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────────┐
│                      REPOSITORY                            │
│  - Data access abstraction                                │
│  - Eloquent queries                                       │
│  - Data transformation                                   │
└──────────────────────────┬─────────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────────┐
│                        MODEL                               │
│  - Eloquent ORM                                          │
│  - Relationships                                         │
│  - Scopes, Accessors, Mutators                           │
└────────────────────────────────────────────────────────────┘
```

### 3.3 Entity Relationship Diagram (ERD)

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│    USERS    │       │  PRODUCTS   │       │  CATEGORIES │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ id (PK)     │       │ id (PK)    │       │ id (PK)    │
│ name        │       │ name       │       │ name       │
│ email       │       │ description │       └──────┬──────┘
│ phone       │       │ price      │              │
│ role        │       │ stock      │              │
│ password    │       │ image_url  │              │
│ fcm_token   │       │ category_id│◄─────────────┘
│ deleted_at  │       │ deleted_at │
└──────┬──────┘       └─────┬──────┘
       │                     │
       │ 1:N                 │ 1:N
       ▼                     ▼
┌─────────────┐       ┌─────────────┐
│  CART_ITEMS │       │ ORDER_ITEMS │
├─────────────┤       ├─────────────┤
│ id (PK)     │       │ id (PK)    │
│ user_id(FK) │◄──────│ order_id(FK)│
│ product_id  │◄──────│ product_id │
│ quantity    │       │ product_   │
└─────────────┘       │   name     │
                      │ quantity   │
                      │ subtotal   │
                      └──────┬──────┘
                             │
                             ▼ 1:1
┌─────────────┐       ┌─────────────┐
│   PAYMENTS  │◄──────│    ORDERS   │
├─────────────┤       ├─────────────┤
│ id (PK)     │       │ id (PK)    │
│ order_id(FK)│       │ invoice_no │
│ payment_    │       │ user_id    │
│   method    │       │ table_id   │
│ amount      │       │ order_     │
│ fee         │       │   type_id  │
│ total       │       │ subtotal   │
│ status      │       │ total      │
│ expired_at  │       │ status     │
│ completed_at│       │ deleted_at │
└─────────────┘       └──────┬──────┘
                             │
                             ▼ N:1
                      ┌─────────────┐
                      │  RESTAURANT │
                      │   _TABLES  │
                      ├─────────────┤
                      │ id (PK)    │
                      │ table_no   │
                      │ status     │
                      └─────────────┘
```

---

## Teknologi yang Digunakan

### 4.1 Frontend (Flutter)

| Kategori | Teknologi | Versi | Fungsi |
|----------|-----------|-------|--------|
| **Framework** | Flutter | SDK ^3.9.2 | Cross-platform mobile development |
| **Language** | Dart | - | Programming language |
| **State Management** | Provider | ^6.1.5+1 | State management dengan ChangeNotifier |
| **HTTP Client** | Dio | ^5.9.2 | HTTP client dengan interceptors |
| **Secure Storage** | flutter_secure_storage | ^10.0.0 | Penyimpanan token terenkripsi (RSA+AES) |
| **Firebase** | firebase_core | ^3.0.0 | Firebase initialization |
| **Push Notification** | firebase_messaging | ^15.0.0 | FCM untuk push notification |
| **Local Notification** | flutter_local_notifications | ^17.0.0 | Local notification display |
| **QR Code** | qr_flutter | ^4.1.0 | Generate QR code untuk QRIS |
| **PDF** | pdf | ^3.12.0 | Generate PDF untuk laporan |
| **Printing** | printing | ^5.14.0 | Print service untuk struk |
| **Bluetooth Printer** | flutter_bluetooth_printer | ^2.24.0 | Integrasi printer Bluetooth |
| **Charts** | fl_chart | ^1.2.0 | Chart untuk analytics |
| **Animation** | lottie | ^3.1.0 | Lottie animation playback |
| **Image** | image_picker, image_cropper, gal | - | Image handling |
| **Typography** | google_fonts | ^8.1.0 | Font Space Grotesk |
| **Logging** | logger | ^2.7.0 | Structured logging |
| **Skeleton** | skeletonizer | ^2.1.3 | Loading skeleton UI |

### 4.2 Backend (Laravel)

| Kategori | Teknologi | Versi | Fungsi |
|----------|-----------|-------|--------|
| **Framework** | Laravel | ^10.10 | PHP Framework |
| **Language** | PHP | ^8.1 | Programming language |
| **Database** | MySQL | - | Relational database |
| **Authentication** | Laravel Sanctum | ^3.3 | Token-based API auth |
| **Firebase** | kreait/laravel-firebase | ^5.10 | Firebase integration (FCM) |
| **API Docs** | dedoc/scramble | ^0.13.20 | OpenAPI/Swagger generator |
| **HTTP Client** | guzzlehttp/guzzle | ^7.2 | HTTP client |

### 4.3 Third Party Services

| Service | Integrasi | Fungsi |
|---------|-----------|--------|
| **Firebase Cloud Messaging** | Frontend + Backend | Push notification |
| **Pakasir Payment Gateway** | Backend (Webhook) | Processing QRIS dan VA payments |
| **Google Fonts** | Frontend | Typography (Space Grotesk) |

---

## Instalasi dan Setup

### 5.1 Persyaratan Sistem

| Komponen | Minimum | Rekomendasi |
|----------|---------|-------------|
| **OS** | Windows 10 / macOS 10.14 / Ubuntu 18.04 | Windows 11 / macOS 12+ |
| **Flutter SDK** | 3.9.2 | Latest stable |
| **Dart SDK** | 3.0 | Latest stable |
| **Android Studio** | 2022.3 | Latest version |
| **Xcode** | 14.0 | Latest (untuk iOS) |
| **PHP** | 8.1 | 8.2 |
| **Composer** | 2.0 | Latest |
| **MySQL** | 8.0 | 8.0+ |

### 5.2 Instalasi Flutter

#### Windows

1. **Download Flutter SDK**
   ```bash
   # Download dari https://docs.flutter.dev/get-started/install/windows
   # Extract ke folder yang diinginkan, contoh: C:\flutter
   ```

2. **Setup Path Environment**
   ```bash
   # Tambahkan ke PATH:
   # C:\flutter\bin
   ```

3. **Verifikasi Instalasi**
   ```bash
   flutter doctor
   flutter --version
   ```

#### macOS / Linux

```bash
# Download dan extract Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verifikasi
flutter doctor
```

### 5.3 Clone Repository

```bash
# Clone repository Flutter
git clone https://github.com/username/warmindo-purnama-flutter.git
cd warmindo-purnama-flutter

# Clone repository Backend
git clone https://github.com/username/warmindo-purnama-backend.git
cd warmindo-purnama-backend
```

### 5.4 Setup Flutter Project

```bash
# Install dependencies
flutter pub get

# Setup environment variables
cp .env.example .env

# Edit .env file
# BASE_URL=https://
# API_TIMEOUT=30000
```

### 5.5 Setup Backend (Laravel)

```bash
# Install dependencies
composer install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Setup database di .env
# DB_DATABASE=warmindo_purnama
# DB_USERNAME=root
# DB_PASSWORD=

# Run migrations
php artisan migrate

# Seed database (opsional)
php artisan db:seed

# Generate API documentation
php artisan scramble:generate

# Start development server
php artisan serve
```

### 5.6 Setup Firebase

1. **Buat project Firebase** di [Firebase Console](https://console.firebase.google.com)

2. **Download google-services.json** untuk Android dan GoogleService-Info.plist untuk iOS

3. **Tempatkan file** di folder android/app/ dan ios/Runner/

4. **Enable Cloud Messaging** di Firebase Console

### 5.7 Jalankan Aplikasi

```bash
# Development mode
flutter run

# Specific device
flutter run -d android
flutter run -d iphone

# Release mode (Android)
flutter build apk --release

# Release mode (iOS)
flutter build ios --release
```

---

## Struktur Proyek

### 6.1 Struktur Flutter

```
warmindo_purnama_flutter/
├── lib/
│   ├── main.dart                          # Entry point
│   ├── core/                              # Shared utilities (GLOBAL)
│   │   ├── constants/
│   │   │   ├── api_constants.dart        # API endpoints
│   │   │   └── payment_constants.dart    # Payment methods
│   │   ├── errors/
│   │   │   ├── app_exception.dart        # Custom exception
│   │   │   └── error_handler.dart        # Error handling
│   │   ├── guards/
│   │   │   └── auth_guard.dart           # Route guards
│   │   ├── injection/
│   │   │   └── dependency_injection.dart # Provider setup
│   │   ├── routes/
│   │   │   └── app_router.dart           # GoRouter config
│   │   ├── services/
│   │   │   ├── app.dart                  # Main App widget
│   │   │   ├── dio_client.dart           # HTTP client
│   │   │   ├── image_service.dart        # Image handling
│   │   │   ├── notification_service.dart # FCM notifications
│   │   │   └── secure_storage.dart       # Token storage
│   │   ├── theme/                        # Design System
│   │   │   ├── app_colors.dart           # Color palette
│   │   │   ├── app_radius.dart          # Border radius
│   │   │   ├── app_shadows.dart         # Shadows
│   │   │   ├── app_spacing.dart         # Spacing
│   │   │   ├── app_text_styles.dart      # Typography
│   │   │   └── app_theme.dart            # Theme config
│   │   └── widgets/                      # Global widgets
│   │       ├── admin_shell.dart          # Admin nav
│   │       ├── customer_shell.dart       # Customer nav
│   │       └── neo/                      # Neo Brutalism library
│   │
│   └── features/                          # Feature modules
│       ├── auth/                        # Authentication
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   └── models/
│       │   ├── domain/
│       │   │   └── repositories/
│       │   └── presentation/
│       │       ├── pages/
│       │       └── providers/
│       ├── product/                      # Product catalog
│       ├── cart/                         # Shopping cart
│       ├── checkout/                     # Checkout
│       ├── payment/                      # Payment
│       ├── order/                        # Order management
│       ├── profile/                      # User profile
│       ├── kasir/                        # Kasir features
│       ├── admin/                        # Admin features
│       └── splash/                       # Splash screen
│
├── assets/
│   ├── icons/
│   ├── images/
│   └── lottie/                          # Animations
│
├── docs/                                # Documentation
│   ├── Api/
│   ├── Dependency/
│   ├── Features/
│   └── Report/
│
├── test/                                # Tests
│   └── features/
│
├── .env                                 # Environment
├── pubspec.yaml                         # Dependencies
└── CLAUDE.md                           # Project instructions
```

### 6.2 Struktur Backend

```
warmindo-purnama-backend/
├── app/
│   ├── Actions/                         # Action classes
│   ├── Console/                         # Artisan commands
│   ├── Enums/                           # Enums (Role.php)
│   ├── Events/                          # Event classes
│   ├── Exceptions/                       # Exceptions
│   ├── Helpers/                          # Helpers
│   ├── Http/
│   │   ├── Controllers/Api/V1/          # API Controllers
│   │   ├── Middleware/                   # Middleware
│   │   ├── Requests/Api/V1/             # Form Requests
│   │   └── Resources/Api/V1/            # API Resources
│   ├── Interfaces/                       # Interfaces
│   ├── Listeners/                        # Listeners
│   ├── Models/                           # Eloquent Models
│   ├── Policies/                         # Policies
│   ├── Providers/                        # Providers
│   ├── Repositories/                     # Repositories
│   ├── Services/                         # Services
│   └── Traits/                           # Traits
├── bootstrap/                           # Bootstrap
├── config/                              # Config files
├── database/
│   ├── factories/                       # Factories
│   ├── migrations/                      # Migrations
│   └── seeders/                         # Seeders
├── docs/                               # Documentation
├── routes/
│   ├── api.php                         # API routes
│   └── web.php                         # Web routes
├── storage/                            # Storage
├── tests/                              # Tests
└── .env                               # Environment
```

---

## Panduan Penggunaan

### 8.1 Customer (Pelanggan)

#### Login / Register

1. Buka aplikasi
2. Jika belum punya akun, tap "Daftar"
3. Isi form registrasi (nama, email, phone, password)
4. Login dengan email dan password

#### Memesan Makanan

1. **Lihat Menu**: Browse produk di halaman utama
2. **Filter Kategori**: Pilih kategori (Makanan/Minuman)
3. **Tambah ke Keranjang**: Tap tombol "+" pada produk
4. **Keranjang**: Lihat item di keranjang, edit quantity atau hapus
5. **Checkout**: Tap "Checkout" untuk lanjut ke pembayaran

#### Pembayaran

1. **Pilih Tipe Order**: Dine-in atau Take-away
2. **Pilih Meja**: (jika Dine-in) Pilih meja dari daftar
3. **Bayar**: Pilih metode pembayaran:
   - **QRIS**: Scan QR code dengan aplikasi bank
   - **Virtual Account**: Salin nomor VA dan bayar via ATM/mobile banking
4. **Konfirmasi**: Tunggu notifikasi pembayaran berhasil

#### Lihat Riwayat

1. Tap menu "Pesanan" di navigasi
2. Lihat daftar pesanan
3. Tap pesanan untuk melihat detail

### 8.2 Kasir

#### Monitoring Pesanan

1. Login dengan akun kasir
2. Lihat daftar pesanan masuk di dashboard
3. Filter berdasarkan status (Pending/Paid)
4. Tap pesanan untuk melihat detail

#### Kelola Meja

1. Tap menu "Meja"
2. Lihat grid meja dengan status
3. Tap meja untuk mengubah status:
   - Available → Occupied
   - Occupied → Available

#### Cek Pembayaran

1. Tap menu "Pembayaran"
2. Lihat daftar pembayaran
3. Filter berdasarkan status (Pending/Completed)
4. Tap untuk melihat detail transaksi

### 8.3 Admin

#### Kelola Produk

1. Login dengan akun admin
2. Buka drawer menu → "Kelola Produk"
3. **Tambah Produk**:
   - Tap tombol "+"
   - Isi nama, deskripsi, harga, stok
   - Upload gambar produk
   - Pilih kategori
   - Tap "Simpan"
4. **Edit Produk**: Tap produk → Edit → Simpan
5. **Hapus Produk**: Tap produk → Hapus

#### Kelola Kategori

1. Buka drawer menu → "Kelola Kategori"
2. Tambah, edit, atau hapus kategori

#### Kelola Meja

1. Buka drawer menu → "Kelola Meja"
2. Tambah, edit, atau hapus meja

#### Kelola User

1. Buka drawer menu → "Kelola User"
2. **Tambah User**:
   - Role: Kasir atau Admin
   - Isi data user
   - Password default harus diubah
3. **Edit User**: Ubah data atau role
4. **Hapus User**: Soft delete (bisa direstore)
5. **Restore**: Tap user yang dihapus → Restore

#### Analytics Dashboard

1. Buka drawer menu → "Analytics"
2. Lihat metrik:
   - Total pesanan
   - Total pendapatan
   - Pesanan hari ini
   - Pendapatan hari ini
3. Lihat grafik:
   - Grafik pesanan 7 hari
   - Pie chart status pesanan
   - Trend pendapatan

---

## Panduan Pengembangan

### 9.1 Konvensi Penamaan

| Tipe | Konvensi | Contoh |
|------|----------|--------|
| File | `snake_case` | `payment_repository.dart` |
| Class | `PascalCase` | `PaymentRepository` |
| Variable/Method | `camelCase` | `createTransaction()` |
| Constant | `camelCase` | `baseUrl` |
| Provider key | `camelCase` | `paymentProvider` |

### 9.2 Model Pattern

```dart
class ProductModel extends Equatable {
  final int id;
  final String name;
  final double price;
  final String? imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'],
    name: json['name'],
    price: json['price'].toDouble(),
    imageUrl: json['image_url'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    if (imageUrl != null) 'image_url': imageUrl,
  };

  @override
  List<Object?> get props => [id, name, price, imageUrl];
}
```

### 9.3 Provider Pattern

```dart
abstract class ProductState {}

class ProductInitial extends ProductState {}
class ProductLoading extends ProductState {}
class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  ProductLoaded(this.products);
}
class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}

class ProductProvider extends ChangeNotifier {
  ProductState _state = ProductInitial();
  ProductState get state => _state;

  Future<void> fetchProducts() async {
    _state = ProductLoading();
    notifyListeners();

    try {
      final products = await _repository.getProducts();
      _state = ProductLoaded(products);
    } catch (e) {
      _state = ProductError(e.toString());
    }
    notifyListeners();
  }
}
```

### 9.4 Error Handling

```dart
// Repository
Future<...> getProducts() async {
  try {
    final response = await _client.get(ApiConstants.products);
    return ProductModel.fromJson(response.data);
  } on DioException catch (e, st) {
    _log.e('[ProductDatasource] Error', error: e, stackTrace: st);
    throw ErrorHandler.handle(e);
  }
}

// Widget
Consumer<ProductProvider>(
  builder: (context, provider, _) {
    final state = provider.state;
    if (state is ProductLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ProductError) {
      return Center(child: Text(state.message));
    }
    if (state is ProductLoaded) {
      return ProductListView(products: state.products);
    }
    return const SizedBox();
  },
)
```

### 9.5 Logging

```dart
import 'package:logger/logger.dart';

final _log = Logger();

// Info: alur normal
_log.i('[PaymentRepository] Membuat transaksi: $orderId');

// Warning: kondisi tidak ideal
_log.w('[PaymentProvider] Transaksi sudah expired: $orderId');

// Error: sertakan error dan stacktrace
_log.e('[PaymentDatasource] Gagal create transaksi', error: e, stackTrace: st);

// Debug: development only, hapus sebelum production
_log.d('[PaymentModel] Parsing response: $json');
```

### 9.6 Aturan Routing

1. Semua page baru **wajib** didaftarkan di `app_router.dart`
2. Route yang butuh auth harus menggunakan `AuthGuard`
3. Route admin harus menggunakan `AdminGuard`

```dart
GoRoute(
  path: '/payment/:orderId',
  builder: (_, state) => PaymentPage(
    orderId: int.parse(state.pathParameters['orderId']!),
  ),
)
```

---

## Testing

### 10.1 Unit Test

#### Model Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/product_model.dart';

void main() {
  group('ProductModel', () {
    final tJson = {
      'id': 1,
      'name': 'Indomie Goreng',
      'price': 15000.0,
      'image_url': 'https://example.com/image.jpg',
    };

    test('fromJson harus menghasilkan model yang benar', () {
      final result = ProductModel.fromJson(tJson);
      expect(result.id, 1);
      expect(result.name, 'Indomie Goreng');
      expect(result.price, 15000.0);
    });

    test('toJson harus mengembalikan map yang benar', () {
      final model = ProductModel.fromJson(tJson);
      expect(model.toJson()['name'], 'Indomie Goreng');
    });
  });
}
```

#### Repository Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:warmindo_purnama_flutter/features/product/data/datasources/product_remote_datasource.dart';
import 'package:warmindo_purnama_flutter/features/product/domain/repositories/product_repository.dart';
import 'package:warmindo_purnama_flutter/features/product/domain/repositories/product_repository_impl.dart';

@GenerateMocks([ProductRemoteDatasource])
import 'product_repository_impl_test.mocks.dart';

void main() {
  late ProductRepository repository;
  late MockProductRemoteDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockProductRemoteDatasource();
    repository = ProductRepositoryImpl(mockDatasource);
  });

  test('getProducts harus mengembalikan list produk', () async {
    when(mockDatasource.getProducts()).thenAnswer((_) async => []);

    final result = await repository.getProducts();

    expect(result, isA<List<ProductModel>>());
    verify(mockDatasource.getProducts());
  });
}
```

### 10.2 Jalankan Test

```bash
# Semua test
flutter test

# Test spesifik feature
flutter test test/features/product/

# Dengan coverage
flutter test --coverage

# Watch mode
flutter test --watch
```

### 10.3 Coverage Report

```bash
# Generate coverage HTML
genhtml coverage/lcov.info -o coverage/html

# View coverage
# Buka coverage/html/index.html di browser
```

---

## Deployment

### 11.1 Android

#### Debug APK

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

#### Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Release AAB (Play Store)

```bash
flutter build appbundle
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### Konfigurasi Signing

1. Buat keystore:
```bash
keytool -genkey -v -keystore warmindo.jks -keyalg RSA -keysize 2048 -validity 10000 -alias warmindo
```

2. Buat file `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=warmindo
storeFile=warmindo.jks
```

3. Configure `android/app/build.gradle`:
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## Kontributor

### Developer

| Nama | Role | Email |
|------|------|-------|
| Rio Achyar | Lead Developer | 1123150093@global.ac.id |
| Muhammad Abday Abdul Hafidz | System analyst | 1123150093@global.ac.id |

### Institusi

| Item | Detail |
|------|--------|
| **Universitas** | Global Institue |
| **Program Studi** | Global Institute |
| **Dosen Pembimbing** | M. Ramadan Julianti M.T |
| **Tahun** | 2026 |

---

## Lisensi

Proyek ini dilisensikan di bawah **MIT License**.

---

## Referensi

### Dokumentasi Resmi

- [Flutter Documentation](https://docs.flutter.dev/)
- [Laravel Documentation](https://laravel.com/docs/10.x)
- [Provider Package](https://pub.dev/packages/provider)
- [Dio HTTP Client](https://pub.dev/packages/dio)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)

### Package yang Digunakan

| Package | Dokumentasi |
|---------|------------|
| flutter_secure_storage | https://pub.dev/packages/flutter_secure_storage |
| qr_flutter | https://pub.dev/packages/qr_flutter |
| fl_chart | https://pub.dev/packages/fl_chart |
| lottie | https://pub.dev/packages/lottie |
| skeletonizer | https://pub.dev/packages/skeletonizer |
| image_picker | https://pub.dev/packages/image_picker |
| image_cropper | https://pub.dev/packages/image_cropper |
| logger | https://pub.dev/packages/logger |
| go_router | https://pub.dev/packages/go_router |

---

*Document Version: 1.0*  
*Last Updated: 2026-07-09*  
*Dokumen ini merupakan panduan implementasi aplikasi Warmindo Purnama untuk keperluan akademik.*
