import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// --- MODEL DATA (Disimpan di file yang sama sesuai permintaan) ---
class PicAccount {
  final String name;
  final String id;
  final String line;
  final bool isActive;
  final String imageUrl;
  final String password;

  PicAccount({
    required this.name,
    required this.id,
    required this.line,
    required this.isActive,
    this.imageUrl = '',
    required this.password,
  });
}

class ProductItem {
  final String id;
  final String name;
  final String customer;
  final DateTime checkDate;
  final bool isOk;
  final String? issue; // Untuk barang NG

  ProductItem({
    required this.id,
    required this.name,
    required this.customer,
    required this.checkDate,
    required this.isOk,
    this.issue,
  });
}

class DashboardNgPage extends StatefulWidget {
  const DashboardNgPage({super.key});

  @override
  State<DashboardNgPage> createState() => _DashboardNgPageState();
}

class _DashboardNgPageState extends State<DashboardNgPage> {
  String _selectedPeriod = 'Hari Ini';
  
  // Data Dummy PIC
  final List<PicAccount> _picList = [
    PicAccount(name: 'Ahmad Susanto', id: 'PIC-001', line: 'Body Parts', isActive: true, password: 'pic123'),
    PicAccount(name: 'Budi Santoso', id: 'PIC-002', line: 'Exhaust System', isActive: true, password: 'pic123'),
    PicAccount(name: 'Citra Lestari', id: 'PIC-003', line: 'Suspension', isActive: false, password: 'pic123'),
    PicAccount(name: 'Dedi Kurniawan', id: 'PIC-004', line: 'Fuel System', isActive: true, password: 'pic123'),
  ];

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

  // Fungsi untuk menampilkan form tambah PIC
  void _showAddPicDialog() {
    String? _selectedLine;
    final _nameController = TextEditingController();
    final _idController = TextEditingController();
    final _passwordController = TextEditingController();
    String? _imagePath;

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
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Tambah Akun PIC Line'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Foto Profil
                  GestureDetector(
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Pilih Foto'),
                          content: const Text('Fitur pemilihan foto akan diimplementasi dengan image_picker'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _imagePath = 'assets/default_profile.png';
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Gunakan Default'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue[50],
                      backgroundImage: _imagePath != null 
                          ? NetworkImage(_imagePath!) 
                          : const AssetImage('assets/default_profile.png') as ImageProvider,
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
                      setState(() {
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
              ElevatedButton(
                onPressed: () {
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
                  
                  setState(() {
                    _picList.add(PicAccount(
                      name: _nameController.text,
                      id: _idController.text,
                      line: _selectedLine!,
                      isActive: true,
                      password: _passwordController.text,
                    ));
                  });
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PIC ${_nameController.text} berhasil ditambahkan'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text('SIMPAN'),
              ),
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
  Widget _buildPicCard(PicAccount pic) {
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
            child: pic.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      pic.imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    pic.name[0],
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
          ),
          const SizedBox(width: 16),
          
          // Info PIC
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pic.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text("${pic.id} • ${pic.line}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 2),
                Text("Password: ${pic.password}", style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          
          // Status Aktif/Non-aktif
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: pic.isActive ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: pic.isActive ? Colors.green : Colors.red, width: 0.5),
            ),
            child: Text(
              pic.isActive ? "Aktif" : "Off",
              style: TextStyle(
                color: pic.isActive ? Colors.green : Colors.red,
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