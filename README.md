# Monitoring QC System

Aplikasi monitoring dan quality control untuk PT Futaba Industrial Indonesia. Aplikasi ini dirancang untuk membantu proses pencatatan, monitoring target, checklist inspeksi, dan pelaporan hasil QC secara real-time.

## Fitur Utama

### Untuk Kepala Departemen (Head)
- Dashboard monitoring produksi harian
- Monitoring status kualitas per kategori produk
- Konfirmasi barang NG (Not Good)
- Manajemen PIC Line

### Untuk PIC Line
- Dashboard progress harian per kategori
- Quality check dengan checklist item
- Input hasil inspeksi (OK/NG)
- History pemeriksaan
- Quick check untuk pemeriksaan cepat

## Kategori Produk

1. **Body Parts** - Komponen bodi kendaraan
2. **Interior Parts** - Komponen interior
3. **Exhaust System Parts** - Komponen sistem pembuangan
4. **Suspension Parts** - Komponen suspensi
5. **Fuel System Parts** - Komponen sistem bahan bakar

## Teknologi yang Digunakan

- **Framework**: Flutter
- **Database**: Firebase Firestore
- **Authentication**: Firebase Authentication
- **State Management**: StatefulWidget
- **UI Components**: Material Design 3

## Instalasi

### Prerequisites

- Flutter SDK (versi 3.0 atau lebih baru)
- Dart SDK
- Android Studio / VS Code
- Firebase Account

### Langkah Instalasi

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd monitoringng1
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Firebase**

   a. Buat project baru di [Firebase Console](https://console.firebase.google.com/)
   
   b. Tambahkan aplikasi Android/iOS ke project Firebase
   
   c. Download file konfigurasi:
      - Untuk Android: `google-services.json` → letakkan di `android/app/`
      - Untuk iOS: `GoogleService-Info.plist` → letakkan di `ios/Runner/`
   
   d. Aktifkan Firebase Authentication:
      - Buka Firebase Console → Authentication
      - Enable **Email/Password** authentication
   
   e. Buat Firestore Database:
      - Buka Firebase Console → Firestore Database
      - Klik "Create database"
      - Pilih mode: **Start in test mode** (untuk development)
      - Pilih lokasi server terdekat

4. **Setup Firebase di Flutter**
   
   Tambahkan dependencies di `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     firebase_core: ^2.24.2
     firebase_auth: ^4.15.3
     cloud_firestore: ^4.13.6
     device_preview: ^1.1.0
   ```

5. **Inisialisasi Firebase**
   
   Update `lib/main.dart`:
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     runApp(
       DevicePreview(
         enabled: true,
         builder: (context) => MyApp(),
       ),
     );
   }
   ```

6. **Run aplikasi**
   ```bash
   flutter run
   ```

## Konfigurasi Akun Login

### Setup User di Firebase Authentication

1. Buka **Firebase Console** → **Authentication** → **Users**
2. Klik **Add user** untuk menambahkan user berikut:

#### Kepala Departemen (Head)
- **Email**: `dudunk@gmail.com`
- **Password**: `123456`
- **Role**: Head Department
- **Custom Claims** (opsional):
  ```json
  {
    "role": "head",
    "department": "Quality Control"
  }
  ```

#### PIC Line
- **Email**: `adi@gmail.com`
- **Password**: `123456`
- **Role**: PIC Line
- **Custom Claims** (opsional):
  ```json
  {
    "role": "pic",
    "picId": "PIC-BODY-001",
    "category": "Body Parts"
  }
  ```

### Struktur Data Firestore

Buat collections berikut di Firestore:

#### 1. Collection: `users`
```
users/
  └── {userId}/
      ├── email: string
      ├── role: string ("head" | "pic")
      ├── name: string
      ├── picId: string (untuk PIC)
      ├── category: string (untuk PIC)
      └── createdAt: timestamp
```

#### 2. Collection: `products`
```
products/
  └── {productId}/
      ├── id: string
      ├── name: string
      ├── category: string
      ├── target: number
      ├── completed: number
      ├── qualityItems: array
      └── ptOrders: array
```

#### 3. Collection: `quality_checks`
```
quality_checks/
  └── {checkId}/
      ├── productId: string
      ├── productName: string
      ├── picId: string
      ├── picName: string
      ├── batchNumber: string
      ├── serialNumber: string
      ├── checkDate: timestamp
      ├── status: string ("OK" | "NG")
      ├── checkResults: map
      ├── notes: string
      └── confirmed: boolean
```

#### 4. Collection: `ng_items`
```
ng_items/
  └── {ngItemId}/
      ├── productName: string
      ├── category: string
      ├── ngCount: number
      ├── picId: string
      ├── picName: string
      ├── date: timestamp
      ├── confirmed: boolean
      ├── confirmedBy: string
      ├── confirmedDate: timestamp
      └── action: string
```

#### 5. Collection: `orders`
```
orders/
  └── {orderId}/
      ├── ptName: string
      ├── orderDate: timestamp
      ├── deliveryDate: timestamp
      ├── status: string
      └── products: array
```

## Cara Penggunaan

### Login sebagai Kepala Departemen
1. Buka aplikasi
2. Pilih tab **"Kepala Departemen"**
3. Masukkan kredensial:
   - Email: `dudunk@gmail.com`
   - Password: `123456`
4. Klik **LOGIN**

### Login sebagai PIC Line
1. Buka aplikasi
2. Pilih tab **"PIC Line"**
3. Masukkan kredensial:
   - Email: `adi@gmail.com`
   - Password: `123456`
4. Klik **LOGIN**

### Melakukan Quality Check (PIC)
1. Login sebagai PIC
2. Pilih produk yang akan diperiksa
3. Klik tombol **"CHECK"**
4. Isi semua item pemeriksaan
5. Sistem akan otomatis menentukan status OK/NG
6. Klik **"SIMPAN QUALITY CHECK"**

### Konfirmasi Barang NG (Head)
1. Login sebagai Kepala Departemen
2. Lihat daftar barang NG di dashboard
3. Klik **"KONFIRMASI"** pada item yang ingin diproses
4. Barang NG akan ditandai untuk dilebur/didaur ulang

## Screenshots

```
lib/
├── screens/
│   ├── auth/
│   │   └── login_screen.dart          # Halaman login
│   ├── head/
│   │   ├── dashboard_screen.dart      # Dashboard kepala departemen
│   │   └── ng_details_screen.dart     # Detail barang NG
│   └── pic/
│       ├── dashboard2_screen.dart     # Dashboard PIC
│       └── quality_check_screen.dart  # Form quality check
└── main.dart                          # Entry point aplikasi
```

## Firestore Security Rules

Tambahkan rules berikut di Firebase Console → Firestore → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId || 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'head';
    }
    
    // Products collection
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'head';
    }
    
    // Quality checks collection
    match /quality_checks/{checkId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'pic';
      allow update, delete: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'head';
    }
    
    // NG items collection
    match /ng_items/{ngItemId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'pic';
      allow update: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'head';
    }
    
    // Orders collection
    match /orders/{orderId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'head';
    }
  }
}
```

## Troubleshooting

### Masalah umum dan solusinya:

1. **Firebase initialization error**
   - Pastikan file `google-services.json` (Android) atau `GoogleService-Info.plist` (iOS) sudah ditambahkan
   - Jalankan `flutter clean` dan `flutter pub get`

2. **Login gagal**
   - Cek koneksi internet
   - Pastikan email dan password sudah terdaftar di Firebase Authentication
   - Verifikasi bahwa Email/Password authentication sudah diaktifkan

3. **Data tidak muncul**
   - Cek Firestore rules
   - Pastikan struktur collection sudah sesuai
   - Cek console untuk error messages

## Development Notes

### Mode Development
- Device Preview diaktifkan untuk testing di berbagai ukuran layar
- Debug banner dapat dinonaktifkan di `MaterialApp`

### Testing Credentials
- **Head**: dudunk@gmail.com / 123456
- **PIC**: adi@gmail.com / 123456

## Contributing

1. Fork repository
2. Buat branch fitur (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

## License

Project ini dibuat untuk keperluan internal PT Futaba Indonesia.


---

**Version**: 1.0.0  
**Last Updated**: January 2026
**Developed by**: Kelompok 6 untuk PT Futaba Indonesia
