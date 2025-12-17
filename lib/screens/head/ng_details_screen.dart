import 'package:flutter/material.dart';

class NgDetailsScreen extends StatefulWidget {
  final String productName;

  const NgDetailsScreen({
    super.key,
    required this.productName,
  });

  @override
  State<NgDetailsScreen> createState() => _NgDetailsScreenState();
}

class _NgDetailsScreenState extends State<NgDetailsScreen> {
  final List<Map<String, dynamic>> _ngItems = [
    {
      'id': 'NG-001',
      'batchNumber': 'BATCH-001-2024',
      'serialNumber': 'SN-001-2024-01',
      'checkDate': '2024-01-15 08:30',
      'picName': 'Ahmad Susanto (PIC-BODY-001)',
      'failedItems': [
        {'name': 'Ketebalan', 'actual': '2.8 mm', 'standard': '3.0 mm'},
        {'name': 'Penyok', 'actual': 'Ada', 'standard': 'Tidak ada'},
      ],
      'notes': 'Ketebalan tidak mencapai standar minimum, ditemukan penyok pada sisi kanan',
      'images': ['ng_image_1.jpg', 'ng_image_2.jpg'],
      'confirmed': false,
    },
    {
      'id': 'NG-002',
      'batchNumber': 'BATCH-001-2024',
      'serialNumber': 'SN-001-2024-02',
      'checkDate': '2024-01-15 09:15',
      'picName': 'Ahmad Susanto (PIC-BODY-001)',
      'failedItems': [
        {'name': 'Diameter lubang', 'actual': '12.7 mm', 'standard': '12.5 mm'},
      ],
      'notes': 'Diameter lubang melebihi toleransi yang diizinkan',
      'images': ['ng_image_3.jpg'],
      'confirmed': false,
    },
    {
      'id': 'NG-003',
      'batchNumber': 'BATCH-002-2024',
      'serialNumber': 'SN-002-2024-01',
      'checkDate': '2024-01-14 14:20',
      'picName': 'Budi Santoso (PIC-BODY-002)',
      'failedItems': [
        {'name': 'Sudut potong', 'actual': '43°', 'standard': '45°'},
        {'name': 'Ketebalan', 'actual': '2.9 mm', 'standard': '3.0 mm'},
      ],
      'notes': 'Sudut potong tidak sesuai dan ketebalan di bawah standar',
      'images': [],
      'confirmed': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unconfirmedItems = _ngItems.where((item) => !item['confirmed']).toList();
    final confirmedItems = _ngItems.where((item) => item['confirmed']).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detail Barang NG'),
            Text(
              widget.productName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize),
            onPressed: () => _showSummary(),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Menunggu'),
                        const SizedBox(width: 4),
                        Badge.count(
                          count: unconfirmedItems.length,
                          backgroundColor: Colors.red,
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Terkonfirmasi'),
                        const SizedBox(width: 4),
                        Badge.count(
                          count: confirmedItems.length,
                          backgroundColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildUnconfirmedTab(unconfirmedItems),
                  _buildConfirmedTab(confirmedItems),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: unconfirmedItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _confirmAll(),
              backgroundColor: Colors.red,
              icon: const Icon(Icons.check_circle),
              label: const Text('KONFIRMASI SEMUA'),
            )
          : null,
    );
  }

  Widget _buildUnconfirmedTab(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Tidak ada barang NG yang menunggu konfirmasi',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildNgItemCard(item, false);
      },
    );
  }

  Widget _buildConfirmedTab(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Belum ada barang NG yang dikonfirmasi',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildNgItemCard(item, true);
      },
    );
  }

  Widget _buildNgItemCard(Map<String, dynamic> item, bool isConfirmed) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        initiallyExpanded: !isConfirmed,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isConfirmed ? Colors.green[50] : Colors.red[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isConfirmed ? Icons.check_circle : Icons.error,
            color: isConfirmed ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          'ID: ${item['id']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Batch: ${item['batchNumber']}'),
            Text('Tanggal: ${item['checkDate']}'),
          ],
        ),
        trailing: isConfirmed
            ? const Chip(
                label: Text('TERKONFIRMASI'),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              )
            : ElevatedButton(
                onPressed: () => _confirmSingleItem(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'KONFIRMASI',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Nomor Seri', item['serialNumber']),
                _buildInfoRow('PIC', item['picName']),
                
                const SizedBox(height: 16),
                const Text(
                  'ITEM YANG TIDAK LULUS:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: (item['failedItems'] as List).map<Widget>((failedItem) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.close, size: 16, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    failedItem['name'],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Aktual: ${failedItem['actual']}',
                                          style: const TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Standard: ${failedItem['standard']}',
                                          style: const TextStyle(color: Colors.green),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                if (item['notes'] != null && (item['notes'] as String).isNotEmpty) ...[
                  const Text(
                    'CATATAN PIC:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(item['notes'] as String),
                  ),
                  const SizedBox(height: 16),
                ],
                
                if (item['images'] != null && (item['images'] as List).isNotEmpty) ...[
                  const Text(
                    'FOTO BARANG NG:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: (item['images'] as List).length,
                      itemBuilder: (context, index) {
                        final image = (item['images'] as List)[index];
                        return Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.image, color: Colors.grey),
                              const SizedBox(height: 4),
                              Text(
                                'Gambar ${index + 1}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmSingleItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Barang NG'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${item['id']}'),
            Text('Batch: ${item['batchNumber']}'),
            const SizedBox(height: 16),
            const Text('Barang ini akan dikonfirmasi untuk dilebur.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () {
              _processConfirmation(item, 'LEBUR');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('KONFIRMASI'),
          ),
        ],
      ),
    );
  }

  void _processConfirmation(Map<String, dynamic> item, String action) {
    setState(() {
      final index = _ngItems.indexWhere((i) => i['id'] == item['id']);
      if (index != -1) {
        _ngItems[index]['confirmed'] = true;
        _ngItems[index]['action'] = action;
        _ngItems[index]['confirmedDate'] = DateTime.now().toString();
        _ngItems[index]['confirmedBy'] = 'Kepala Departemen';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Barang ${item['id']} dikonfirmasi untuk $action'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _confirmAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Semua Barang NG'),
        content: const Text(
          'Semua barang NG akan dikonfirmasi untuk dilebur. '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                for (var item in _ngItems.where((i) => !i['confirmed'])) {
                  item['confirmed'] = true;
                  item['action'] = 'LEBUR';
                  item['confirmedDate'] = DateTime.now().toString();
                  item['confirmedBy'] = 'Kepala Departemen';
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua barang NG telah dikonfirmasi untuk dilebur'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('KONFIRMASI SEMUA'),
          ),
        ],
      ),
    );
  }

  void _showSummary() {
    final totalNg = _ngItems.length;
    final confirmedCount = _ngItems.where((i) => i['confirmed']).length;
    final pendingCount = totalNg - confirmedCount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ringkasan Barang NG'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryCard('Total Barang NG', '$totalNg item', Colors.blue),
            _buildSummaryCard('Menunggu Konfirmasi', '$pendingCount item', Colors.red),
            _buildSummaryCard('Terkonfirmasi', '$confirmedCount item', Colors.green),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Per Kategori:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildCategoryStat('Body Parts', 8),
            _buildCategoryStat('Exhaust System Parts', 3),
            _buildCategoryStat('Suspension Parts', 2),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () => _exportReport(),
            child: const Text('EXPORT LAPORAN'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStat(String category, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category),
          Text('$count item'),
        ],
      ),
    );
  }

  void _exportReport() {
    // Implementasi export report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Laporan berhasil diexport ke Excel'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
}