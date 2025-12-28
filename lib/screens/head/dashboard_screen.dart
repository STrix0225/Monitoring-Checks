import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../restapi.dart';
import '../../config.dart';
import '../../models/pic_model.dart';
import '../../models/product_item_model.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../auth/login_screen.dart';


    class DashboardNgPage extends StatefulWidget {
      const DashboardNgPage({super.key});

      @override
      State<DashboardNgPage> createState() => _DashboardNgPageState();
    }

    class _DashboardNgPageState extends State<DashboardNgPage> {
      String _selectedPeriod = 'Hari Ini';
      List<PicLineModel> _picList = [];
      List<PicLineModel> searchData = [];
      bool isLoading = true;

      DataService ds = DataService();
      
    @override
    void initState() {
      super.initState();
      _loadPicAccounts();
    }

      Future<void> _loadPicAccounts() async {
    try {
      print('Memulai pengambilan data dari 247Go...');
      
      String response = await ds.selectAll(token, project, 'pic_line', appid);
      print('Response dari API: $response');
      
      var responseApi = jsonDecode(response);
      print('Response decoded: $responseApi');

      final List<dynamic> datalist = responseApi['data'] ?? [];
      print('Jumlah data ditemukan: ${datalist.length}');

      setState(() {
        _picList.clear();
        _picList.addAll(datalist.map((e) => PicLineModel.fromJson(e)).toList());
        searchData = List.from(_picList); // Copy untuk pencarian
        isLoading = false;
      });

      print('Data berhasil dimuat: ${_picList.length} pic_line');
      
    } catch (e) {
      print('Error dalam selectAllPicLine: $e');
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mengambil data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

      // Data Dummy Barang OK
      final List<ProductItem> _okProducts = [
        ProductItem(
          id: 'OK-001',
          name: 'Exhaust Manifold',
          customer: 'PT Daihatsu',
          checkDate: DateTime(2024, 1, 15, 8, 30),
          isOk: true,
        ),
        ProductItem(
          id: 'OK-002',
          name: 'Cowl Assembly',
          customer: 'PT Toyota',
          checkDate: DateTime(2024, 1, 15, 9, 15),
          isOk: true,
        ),
        ProductItem(
          id: 'OK-003',
          name: 'Front Pillar',
          customer: 'PT Daihatsu',
          checkDate: DateTime(2024, 1, 15, 10, 45),
          isOk: true,
        ),
        ProductItem(
          id: 'OK-004',
          name: 'Suspension Arm',
          customer: 'PT Toyota',
          checkDate: DateTime(2024, 1, 15, 11, 20),
          isOk: true,
        ),
        ProductItem(
          id: 'OK-005',
          name: 'Fuel Tank Bracket',
          customer: 'PT Daihatsu',
          checkDate: DateTime(2024, 1, 15, 13, 10),
          isOk: true,
        ),
      ];

      // Data Dummy Barang NG
      final List<ProductItem> _ngProducts = [
        ProductItem(
          id: 'NG-001',
          name: 'Exhaust Manifold',
          customer: 'PT Daihatsu',
          checkDate: DateTime(2024, 1, 15, 8, 45),
          isOk: false,
          issue: 'Ketebalan tidak sesuai (2.8 mm / 3.0 mm)',
        ),
        ProductItem(
          id: 'NG-002',
          name: 'Cowl Assembly',
          customer: 'PT Toyota',
          checkDate: DateTime(2024, 1, 15, 9, 30),
          isOk: false,
          issue: 'Penyok pada sisi kanan',
        ),
        ProductItem(
          id: 'NG-003',
          name: 'Front Pillar',
          customer: 'PT Daihatsu',
          checkDate: DateTime(2024, 1, 15, 10, 15),
          isOk: false,
          issue: 'Diameter lubang melebihi toleransi (12.7 mm / 12.5 mm)',
        ),
        ProductItem(
          id: 'NG-004',
          name: 'Suspension Arm',
          customer: 'PT Toyota',
          checkDate: DateTime(2024, 1, 15, 11, 50),
          isOk: false,
          issue: 'Sudut potong tidak sesuai (43° / 45°)',
        ),
      ];

      // Fungsi untuk Logout
      void _showLogoutDialog() {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah Anda yakin ingin logout dari akun kepala departemen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('BATAL'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  // Navigasi ke login screen dan hapus semua route sebelumnya
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('LOGOUT'),
              ),
            ],
          ),
        );
      }

      // Fungsi untuk menampilkan form tambah PIC
      void _showAddPicDialog() {
        String? _selectedLine;
        final _nameController = TextEditingController();
        final _idController = TextEditingController();
        final _passwordController = TextEditingController();
        String? _imagePath;
        String? _uploadedFileName;

        Future<void> _pickAndUploadImage(void Function(void Function()) dialogSetState) async {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            withData: true,
          );
          if (result != null && result.files.isNotEmpty) {
            dialogSetState(() {});

            try {
              final ds = DataService();
              dynamic uploadResponse = await ds.upload(
                token,
                project,
                result.files.single.bytes!,
                result.files.single.extension ?? 'jpg',
              );

              print('🔍 Upload Response Type: ${uploadResponse.runtimeType}');
              print('🔍 Upload Response: $uploadResponse');

              String fileName = '';

              if (uploadResponse is Map) {
                fileName = uploadResponse['file_name'] ?? uploadResponse['filename'] ?? uploadResponse['name'] ?? '';
                print('🔍 Parsed from Map: fileName=$fileName, keys=${uploadResponse.keys}');
              } else if (uploadResponse is List) {
                print('🔍 Upload response is List with ${uploadResponse.length} items');
                if (uploadResponse.isNotEmpty) {
                  if (uploadResponse[0] is Map) {
                    fileName = uploadResponse[0]['file_name'] ?? uploadResponse[0]['filename'] ?? uploadResponse[0]['name'] ?? '';
                    print('🔍 Parsed from List[0] Map: fileName=$fileName');
                  } else if (uploadResponse[0] is String) {
                    fileName = uploadResponse[0].toString();
                    print('🔍 Parsed from List[0] String: fileName=$fileName');
                  }
                }
              } else if (uploadResponse is String) {
                print('🔍 Upload response is String, attempting JSON decode...');
                try {
                  dynamic parsed = jsonDecode(uploadResponse);
                  print('🔍 JSON decoded successfully: type=${parsed.runtimeType}');
                  if (parsed is Map) {
                    fileName = parsed['file_name'] ?? parsed['filename'] ?? parsed['name'] ?? '';
                    print('🔍 Parsed from String (Map): fileName=$fileName, keys=${parsed.keys}');
                  } else if (parsed is List && parsed.isNotEmpty) {
                    print('🔍 Parsed is List with ${parsed.length} items');
                    if (parsed[0] is Map) {
                      fileName = parsed[0]['file_name'] ?? parsed[0]['filename'] ?? parsed[0]['name'] ?? '';
                      print('🔍 Parsed from String (List[0]): fileName=$fileName');
                    } else if (parsed[0] is String) {
                      fileName = parsed[0].toString();
                      print('🔍 Parsed from String (List[0] String): fileName=$fileName');
                    }
                  }
                } catch (e) {
                  print('⚠️ JSON parse error: $e, treating as plain filename');
                  fileName = uploadResponse;
                }
              }

              if (fileName.isEmpty) {
                print('⚠️ Nama file tidak ditemukan dalam response. Raw: $uploadResponse');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gagal mengupload foto. Silakan coba lagi.'),
                    backgroundColor: Colors.red,
                  ),
                );
                dialogSetState(() {});
                return;
              }

              print('✅ Final fileName extracted: $fileName');
              if (fileName.isEmpty) {
                print('❌ ERROR: fileName is empty after parsing!');
              } else {
                print('✅ Will store photo as: $fileName');
              }
              _uploadedFileName = fileName;
              _imagePath = '$fileUrl${CollectionName.picCollection}/file_name/$fileName';
              print('📸 Local preview path: $_imagePath');

              dialogSetState(() {});

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Foto berhasil diupload'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              print('❌ Upload error: $e');
              dialogSetState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }

        final List<String> _lineOptions = [
          'Body Parts',
          'Exhaust System',
          'Suspension',
          'Fuel System',
          'Assembly Line',
          'Painting Line'
        ];

        showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, dialogSetState) {
              bool isLoading = false;
              return AlertDialog(
                title: const Text('Tambah Akun PIC Line'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Foto Profil
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Pilih Gambar',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  ListTile(
                                    leading: const Icon(Icons.image, color: Colors.blue),
                                    title: const Text('Pilih Gambar'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      // invoke picker and upload, updating the dialog state
                                      _pickAndUploadImage(dialogSetState);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.check, color: Colors.green),
                                    title: const Text('Gunakan Default'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      // Default profile picture logic can be added here
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.close, color: Colors.red),
                                    title: const Text('Batal'),
                                    onTap: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue[50],
                            backgroundImage: _imagePath != null
                              ? (_imagePath!.startsWith('assets/')
                                ? AssetImage(_imagePath!) as ImageProvider
                                : (_imagePath!.startsWith('http')
                                  ? NetworkImage(_imagePath!) as ImageProvider
                                  : FileImage(File(_imagePath!)) as ImageProvider))
                              : null,
                            child: _imagePath == null
                              ? const Icon(Icons.camera_alt, size: 30, color: Colors.blue)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap untuk pilih foto',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Nama PIC
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama PIC',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Line/Kategori
                      DropdownButtonFormField<String>(
                        value: _selectedLine,
                        decoration: const InputDecoration(
                          labelText: 'Line/Kategori',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _lineOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          dialogSetState(() {
                            _selectedLine = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih line/kategori';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // ID PIC
                      TextField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          labelText: 'ID PIC (Contoh: PIC-BODY-001)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Password
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('BATAL'),
                  ),
                  StatefulBuilder(builder: (context, _) {
                    return ElevatedButton(
                      onPressed: () async {
                        if (_nameController.text.isEmpty ||
                            _selectedLine == null ||
                            _idController.text.isEmpty ||
                            _passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Harap isi semua field'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        dialogSetState(() { isLoading = true; });

                        final photo = _uploadedFileName ?? '';
                        print('💾 About to insert PIC with photo field: "$photo"');
                        try {
                          final ds = DataService();
                          final result = await ds.insertPicLine(
                            token,
                            project,
                            appid,
                            _idController.text,
                            _nameController.text,
                            _selectedLine!,
                            _passwordController.text,
                            photo,
                          );
                          print('💾 Insert result: $result');

                          dialogSetState(() { isLoading = false; });

                          if (result != null) {
                            setState(() {
                              _picList.add(PicLineModel(
                                id: '',
                                id_pic: _idController.text,
                                nama: _nameController.text,
                                line: _selectedLine!,
                                password: _passwordController.text,
                                photo: _uploadedFileName ?? '',
                              ));
                            });

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('PIC ${_nameController.text} berhasil ditambahkan'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gagal menambahkan PIC — server mengembalikan error'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          dialogSetState(() { isLoading = false; });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: isLoading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('SIMPAN'),
                    );
                  }),
                ],
              );
            },
          ),
        );
      }

      // Fungsi untuk menampilkan detail barang OK
      void _showOkProductsDetail() {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Daftar Barang OK'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Barang OK',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_okProducts.length} item',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _okProducts.length,
                      itemBuilder: (context, index) {
                        final product = _okProducts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.green),
                            ),
                            title: Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Customer: ${product.customer}'),
                                Text(
                                  'Waktu: ${product.checkDate.hour.toString().padLeft(2, '0')}:${product.checkDate.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Text(
                              product.id,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      }

      // Fungsi untuk menampilkan detail barang NG
      void _showNgProductsDetail() {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Daftar Barang NG'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Barang NG',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_ngProducts.length} item',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _ngProducts.length,
                      itemBuilder: (context, index) {
                        final product = _ngProducts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.error, color: Colors.red),
                            ),
                            title: Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Customer: ${product.customer}'),
                                Text(
                                  'Issue: ${product.issue}',
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                ),
                                Text(
                                  'Waktu: ${product.checkDate.hour.toString().padLeft(2, '0')}:${product.checkDate.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Text(
                              product.id,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Dashboard - Dept. Head',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                tooltip: "Tambah PIC Baru",
                onPressed: _showAddPicDialog,
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                tooltip: "Logout",
                onPressed: _showLogoutDialog,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BAGIAN 1: HEADER & FILTER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Performa Produksi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: _selectedPeriod,
                      underline: Container(),
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                      items: ['Hari Ini', 'Minggu Ini', 'Bulan Ini']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedPeriod = v!),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),

                // --- BAGIAN 2: CHART (GRAFIK) ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Pie Chart Area dengan gesture detector
                      GestureDetector(
                        onTap: () {
                          // Menampilkan dialog dengan pilihan
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Lihat Detail Barang'),
                              content: const Text('Pilih jenis barang yang ingin dilihat:'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showOkProductsDetail();
                                  },
                                  child: const Text('Barang OK'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showNgProductsDetail();
                                  },
                                  child: const Text('Barang NG'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 140,
                          width: 140,
                          child: Stack(
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 35,
                                  sections: [
                                    PieChartSectionData(
                                      color: const Color(0xFF4CAF50),
                                      value: 98,
                                      title: '98%',
                                      radius: 45,
                                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    PieChartSectionData(
                                      color: const Color(0xFFF44336),
                                      value: 2,
                                      title: '2%',
                                      radius: 45,
                                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              // Indikator bahwa chart bisa diklik
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.touch_app,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Legend Area dengan gesture detector per item
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _showOkProductsDetail,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: _buildLegend(const Color(0xFF4CAF50), "OK: 2450 pcs"),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _showNgProductsDetail,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: _buildLegend(const Color(0xFFF44336), "NG: 50 pcs"),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            const Text("Total: 2500", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- BAGIAN 3: MONITORING TARGET ---
                const Text(
                  'Monitoring Target Harian',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildTargetCard(
                  customer: "PT Daihatsu",
                  partName: "Exhaust Manifold",
                  target: 200,
                  actual: 150,
                  status: "On Track",
                  statusColor: const Color(0xFF4CAF50),
                ),
                
                _buildTargetCard(
                  customer: "PT Toyota",
                  partName: "Cowl Assembly",
                  target: 300,
                  actual: 280,
                  status: "On Track",
                  statusColor: const Color(0xFF4CAF50),
                ),

                const SizedBox(height: 24),

                // --- BAGIAN 4: DAFTAR AKUN PIC ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Akun PIC',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Lihat Semua"),
                    )
                  ],
                ),
                const SizedBox(height: 8),

                // List PIC dalam bentuk Card Vertical
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _picList.length,
                  itemBuilder: (context, index) {
                    final pic = _picList[index];
                    return _buildPicCard(pic);
                  },
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }

      // --- WIDGET HELPER: LEGEND CHART ---
      Widget _buildLegend(Color color, String text) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ],
          ),
        );
      }

      // --- WIDGET HELPER: KARTU TARGET PRODUKSI ---
      Widget _buildTargetCard({
        required String customer,
        required String partName,
        required int target,
        required int actual,
        required String status,
        required Color statusColor,
      }) {
        double progress = actual / target;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(partName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress > 1 ? 1 : progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              const SizedBox(height: 8),
              Text("$actual / $target pcs", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }

      // --- WIDGET HELPER: KARTU PIC ---
      Widget _buildPicCard(PicLineModel pic) {
        String imageUrl = '';
        if (pic.photo.isNotEmpty) {
          final pv = pic.photo;
          if (pv != '[]') {
            try {
              final parsed = jsonDecode(pv);
              if (parsed is List && parsed.isNotEmpty) {
                final first = parsed[0];
                if (first is Map) {
                  final fname = first['file_name'] ?? first['filename'];
                  if (fname != null) imageUrl = '$fileUrl${CollectionName.picCollection}/file_name/$fname';
                } else if (parsed[0] is String) {
                  imageUrl = '$fileUrl${CollectionName.picCollection}/file_name/${parsed[0]}';
                }
              } else if (parsed is String && parsed.isNotEmpty) {
                imageUrl = '$fileUrl${CollectionName.picCollection}/file_name/$parsed';
              }
            } catch (_) {
              imageUrl = '$fileUrl${CollectionName.picCollection}/file_name/$pv';
            }
          }
        }

        final displayId = pic.id_pic.isNotEmpty ? pic.id_pic : pic.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              // Foto Profil (Avatar)
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue[50],
                child: imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          imageUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        pic.nama.isNotEmpty ? pic.nama[0] : '-',
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
              ),
              const SizedBox(width: 16),
              
              // Info PIC
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pic.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text("$displayId • ${pic.line}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text("Password: ${pic.password}", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
              
              // Status Aktif
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 0.5),
                ),
                child: const Text(
                  "Aktif",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }