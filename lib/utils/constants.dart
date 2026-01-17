// lib/utils/constants.dart
class AppConstants {
  static const String appName = 'Monitoring QC';
  static const String companyName = 'PT Futaba Indonesia';
  
  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String dailyTargetsCollection = 'dailyTarget';
  static const String qcRecordsCollection = 'qcRecord';
  static const String ngItemsCollection = 'ngItems';
  static const String globalCheckpointsCollection = 'globalCheckpoint';
  static const String categoriesCollection = 'categories';
  
  // Storage Paths
  static const String profilePhotosPath = 'profile_photos';
  static const String qcPhotosPath = 'qc_photos';
  static const String ngItemsPhotosPath = 'ng_items';
  
  // User Roles
  static const String headDept = 'head_dept';
  static const String pic = 'pic';

  // Default Head accounts for first-time auto profile creation.
  // Ganti dengan email kepala departemen yang sah.
  static const List<String> defaultHeadEmails = [
    'head@example.com',
  ];
  
  // Target Status
  static const String targetActive = 'active';
  static const String targetCompleted = 'completed';
  static const String targetCancelled = 'cancelled';
  
  // QC Status
  static const String qcOk = 'OK';
  static const String qcNg = 'NG';
  
  // NG Item Status
  static const String ngPending = 'pending';
  static const String ngConfirmedForMelt = 'confirmed_for_melt';
  
  // Categories
  static const List<String> categories = [
    'Body parts',
    'Interior parts',
    'Exhaust system parts',
    'Suspension parts',
    'Fuel system parts',
  ];
  
  // Category Codes
  static const Map<String, String> categoryCodes = {
    'Body parts': 'PIC-BODY',
    'Interior parts': 'PIC-INT',
    'Exhaust system parts': 'PIC-EXT',
    'Suspension parts': 'PIC-SPS',
    'Fuel system parts': 'PIC-FSP',
  };
  
  // Products by Category
  static const Map<String, List<String>> productsByCategory = {
    'Body parts': [
      'Front pillar upper outer',
      'Front pillar lower outer',
      'Cowl assembly',
      'Wheel house inner/outer subassembly',
      'Rear floor side member subassembly',
    ],
    'Interior parts': [
      'Instrument panel reinforcement',
    ],
    'Exhaust system parts': [
      'Exhaust system',
      'Exhaust manifold',
      'Diesel exhaust gas post-treatment device',
    ],
    'Suspension parts': [
      'Front suspension sub-frame',
      'Trailing arm',
      'Rear axle beam',
      'Engine undercover',
    ],
    'Fuel system parts': [
      'Canister',
      'Fuel inlet pipe',
    ],
  };
  
  // Default Checkpoints
  static const List<Map<String, dynamic>> defaultCheckpoints = [
    {
      'checkpointId': 'no_dent',
      'name': 'Tidak Ada Penyok',
      'type': 'boolean',
      'isRequired': true,
      'applicableCategories': ['Body parts', 'Interior parts', 'Suspension parts'],
    },
    {
      'checkpointId': 'no_scratch',
      'name': 'Tidak Ada Goresan',
      'type': 'boolean',
      'isRequired': true,
      'applicableCategories': ['Body parts', 'Interior parts', 'Suspension parts', 'Exhaust system parts'],
    },
    {
      'checkpointId': 'no_rust',
      'name': 'Tidak Ada Karat',
      'type': 'boolean',
      'isRequired': true,
      'applicableCategories': ['Body parts', 'Interior parts', 'Suspension parts', 'Exhaust system parts', 'Fuel system parts'],
    },
    {
      'checkpointId': 'color_match',
      'name': 'Warna Sesuai',
      'type': 'boolean',
      'isRequired': true,
      'applicableCategories': ['Body parts', 'Interior parts'],
    },
    {
      'checkpointId': 'dimensions',
      'name': 'Dimensi Sesuai',
      'type': 'boolean',
      'isRequired': true,
      'applicableCategories': ['Body parts', 'Interior parts', 'Suspension parts', 'Exhaust system parts'],
    },
    {
      'checkpointId': 'bolt_thread_diameter',
      'name': 'Diameter Ulir Baut',
      'type': 'number',
      'unit': 'mm',
      'minValue': 10.0,
      'maxValue': 11.0,
      'isRequired': false,
      'applicableCategories': ['Body parts', 'Suspension parts'],
    },
    {
      'checkpointId': 'weight',
      'name': 'Berat',
      'type': 'number',
      'unit': 'kg',
      'isRequired': false,
      'applicableCategories': ['Body parts', 'Suspension parts', 'Exhaust system parts'],
    },
    {
      'checkpointId': 'material_type',
      'name': 'Jenis Material',
      'type': 'text',
      'isRequired': true,
      'applicableCategories': ['Body parts', 'Interior parts', 'Suspension parts', 'Exhaust system parts', 'Fuel system parts'],
    },
    {
      'checkpointId': 'surface_smoothness',
      'name': 'Kehalusan Permukaan',
      'type': 'boolean',
      'isRequired': true,
      'applicableCategories': ['Body parts', 'Interior parts'],
    },
    {
      'checkpointId': 'leak_test',
      'name': 'Uji Kebocoran',
      'type': 'boolean',
      'isRequired': false,
      'applicableCategories': ['Exhaust system parts', 'Fuel system parts'],
    },
    {
      'checkpointId': 'pressure_test',
      'name': 'Uji Tekanan',
      'type': 'boolean',
      'isRequired': false,
      'applicableCategories': ['Exhaust system parts', 'Fuel system parts'],
    },
    {
      'checkpointId': 'welding_quality',
      'name': 'Kualitas Las',
      'type': 'boolean',
      'isRequired': false,
      'applicableCategories': ['Body parts', 'Exhaust system parts', 'Suspension parts'],
    },
  ];
}