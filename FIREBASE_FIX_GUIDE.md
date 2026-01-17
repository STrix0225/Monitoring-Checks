# FIX untuk Firebase Web Dependency Conflict

## Langkah-langkah untuk memperbaiki error:

### 1. Bersihkan Flutter Cache dan Dependencies
```bash
flutter clean
rm pubspec.lock
```

### 2. Update Pubspec.yaml dengan Versioning yang Compatible

Pastikan versi Firebase packages kompatibel. Gunakan versi stabil terbaru:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.1
  cloud_firestore: ^4.15.3
  firebase_storage: ^11.4.2
  
  # Jika menggunakan Flutter Web:
  # flutter_web_plugins:
  #   sdk: flutter
```

### 3. Get Dependencies Baru
```bash
flutter pub get
```

### 4. Jika Masih Error, Downgrade Firebase Auth Web

Jika error masih terjadi, coba downgrade firebase_auth ke versi yang lebih stabil:

Edit pubspec.yaml:
```yaml
firebase_auth: ^4.12.0  # Downgrade ke versi yang lebih stabil
```

Kemudian:
```bash
flutter pub get
flutter pub upgrade
```

### 5. Clean Build
```bash
flutter clean
flutter pub get
```

### 6. Run dengan Clean
```bash
flutter run --no-fast-start
```

## Alternatif: Gunakan FlutterFire CLI

Jika masih error, gunakan FlutterFire CLI untuk konfigurasi otomatis:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=zoofeed-a4e73
```

Ini akan generate firebase_options.dart otomatis sesuai platform Anda.

## Note:
- Jika error `PromiseJsImpl` muncul lagi = issue dengan firebase_auth_web
- Coba exclude web platform jika tidak digunakan: `flutter run -d android` atau `flutter run -d ios`
