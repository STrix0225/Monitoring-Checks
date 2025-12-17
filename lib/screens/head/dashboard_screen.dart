import 'package:flutter/material.dart';

class HeadDashboardScreen extends StatefulWidget {
  const HeadDashboardScreen({super.key});

  @override
  State<HeadDashboardScreen> createState() => _HeadDashboardScreenState();
}

class _HeadDashboardScreenState extends State<HeadDashboardScreen> {
  int _selectedIndex = 0;
  
  final Map<String, Map<String, int>> _categoryStats = {
    'Body Parts': {'total': 150, 'ok': 140, 'ng': 10},
    'Interior Parts': {'total': 45, 'ok': 42, 'ng': 3},
    'Exhaust System Parts': {'total': 120, 'ok': 115, 'ng': 5},
    'Suspension Parts': {'total': 85, 'ok': 80, 'ng': 5},
    'Fuel System Parts': {'total': 60, 'ok': 58, 'ng': 2},
  };
  
  final List<Map<String, dynamic>> _pendingOrders = [
    {
      'ptName': 'PT Daihatsu',
      'orderDate': '2024-01-10',
      'deliveryDate': '2024-02-10',
      'status': 'Dalam Proses',
      'products': [
        {
          'name': 'Exhaust manifold', 
          'qty': 5000, 
          'progress': 65,
          'startDate': '2024-01-15',
          'endDate': '2024-01-30',
          'productionLine': 'Line 2'
        },
        {
          'name': 'Front pillar lower outer', 
          'qty': 5000, 
          'progress': 45,
          'startDate': '2024-01-20',
          'endDate': '2024-02-05',
          'productionLine': 'Line 1'
        },
      ]
    },
    {
      'ptName': 'PT Toyota',
      'orderDate': '2024-01-12',
      'deliveryDate': '2024-02-15',
      'status': 'Dalam Proses',
      'products': [
        {
          'name': 'Cowl assembly', 
          'qty': 3000, 
          'progress': 80,
          'startDate': '2024-01-18',
          'endDate': '2024-02-01',
          'productionLine': 'Line 3'
        },
        {
          'name': 'Rear floor side member subassembly', 
          'qty': 2000, 
          'progress': 90,
          'startDate': '2024-01-15',
          'endDate': '2024-01-31',
          'productionLine': 'Line 2'
        },
      ]
    },
    {
      'ptName': 'PT Honda',
      'orderDate': '2024-01-14',
      'deliveryDate': '2024-02-20',
      'status': 'Dalam Proses',
      'products': [
        {
          'name': 'Front suspension sub-frame', 
          'qty': 4000, 
          'progress': 30,
          'startDate': '2024-01-25',
          'endDate': '2024-02-10',
          'productionLine': 'Line 4'
        },
      ]
    },
  ];
  
  final List<Map<String, dynamic>> _ngProducts = [
    {
      'productName': 'Front pillar upper outer',
      'category': 'Body Parts',
      'ngCount': 3,
      'picName': 'PIC-BODY-001',
      'date': '2024-01-15',
    },
    {
      'productName': 'Instrument panel reinforcement',
      'category': 'Interior Parts',
      'ngCount': 2,
      'picName': 'PIC-INT-001',
      'date': '2024-01-15',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Kepala Departemen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(),
          ),
        ],
      ),
      body: _selectedIndex == 0 
          ? _buildDashboard()
          : _selectedIndex == 1
              ? _buildPicManagement()
              : _buildCategoryStatus(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'PIC Line',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Status',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => _addNewPic(),
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.today, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'PRODUKSI HARI INI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('TOTAL', '460 pcs', Colors.blue),
                      _buildStatCard('OK', '435 pcs', Colors.green),
                      _buildStatCard('NG', '25 pcs', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STATUS KUALITAS PER KATEGORI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: _categoryStats.entries.map((entry) {
                      return _buildCategoryProgress(entry.key, entry.value);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PESANAN DARI PT LAIN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: _pendingOrders.map((order) {
                      return _buildOrderCard(order);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            elevation: 3,
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'BARANG NG MENUNGGU KONFIRMASI',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.red,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          '${_ngProducts.length} item',
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: Colors.red,
                        labelStyle: const TextStyle(color: Colors.white),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: _ngProducts.map((product) {
                      return _buildNgProductCard(product);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryProgress(String category, Map<String, int> stats) {
    double percentage = (stats['ok']! / stats['total']!) * 100;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Text(
                '${stats['ok']}/${stats['total']} (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  color: percentage > 90 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: stats['ok']! / stats['total']!,
            backgroundColor: Colors.grey[300],
            color: percentage > 90 ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 4),
          Text(
            'NG: ${stats['ng']} barang',
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return GestureDetector(
      onTap: () => _showOrderDetails(order),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.business, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order['ptName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order['status'],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                children: (order['products'] as List).map<Widget>((product) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${product['qty']} pcs',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 80,
                                child: LinearProgressIndicator(
                                  value: (product['progress'] ?? 0) / 100,
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.blue,
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${product['progress']}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNgProductCard(Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product['productName'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Kategori', product['category']),
                      _buildDetailRow('PIC', product['picName']),
                      _buildDetailRow('Tanggal', product['date']),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${product['ngCount']} barang NG',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () => _confirmNgProduct(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text(
                          'KONFIRMASI',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPicManagement() {
    final List<Map<String, dynamic>> picList = [
      {'id': 'PIC-BODY-001', 'name': 'Ahmad Susanto', 'category': 'Body Parts'},
      {'id': 'PIC-INT-001', 'name': 'Budi Santoso', 'category': 'Interior Parts'},
      {'id': 'PIC-EXH-001', 'name': 'Citra Dewi', 'category': 'Exhaust System Parts'},
      {'id': 'PIC-SUS-001', 'name': 'Dedi Setiawan', 'category': 'Suspension Parts'},
      {'id': 'PIC-FUEL-001', 'name': 'Eka Putri', 'category': 'Fuel System Parts'},
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: picList.length,
      itemBuilder: (context, index) {
        final pic = picList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(
              pic['name'],
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${pic['id']}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  'Kategori: ${pic['category']}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => _editPic(pic),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _deletePic(pic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryStatus() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'PILIH KATEGORI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: 'Body Parts',
                  items: _categoryStats.keys.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {},
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Kategori',
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DETAIL PRODUK - BODY PARTS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                _buildProductDetailRow('Front pillar upper outer', 50, 48, 2),
                _buildProductDetailRow('Front pillar lower outer', 45, 42, 3),
                _buildProductDetailRow('Cowl assembly', 30, 29, 1),
                _buildProductDetailRow('Wheel house inner/outer subassembly', 15, 14, 1),
                _buildProductDetailRow('Rear floor side member subassembly', 10, 7, 3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetailRow(String productName, int total, int ok, int ng) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text('Total: $total'),
                    backgroundColor: Colors.blue[100],
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                  Chip(
                    label: Text('OK: $ok'),
                    backgroundColor: Colors.green[100],
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                  Chip(
                    label: Text('NG: $ng'),
                    backgroundColor: Colors.red[100],
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              if (ng > 0) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _viewNgDetails(productName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 36),
                    ),
                    child: const Text(
                      'LIHAT DETAIL BARANG NG',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifikasi'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: const Text('Barang NG Body Parts'),
                subtitle: const Text('3 barang NG menunggu konfirmasi'),
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('Lihat'),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Target tercapai'),
                subtitle: const Text('PIC Exhaust System mencapai target'),
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('Lihat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _addNewPic() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah PIC Line Baru'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nama PIC',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'ID PIC',
                  border: OutlineInputBorder(),
                  hintText: 'PIC-BODY-002',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                items: _categoryStats.keys.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (value) {},
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PIC Line berhasil ditambahkan')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _editPic(Map<String, dynamic> pic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit PIC Line'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: pic['name']),
                decoration: const InputDecoration(
                  labelText: 'Nama PIC',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: pic['id']),
                decoration: const InputDecoration(
                  labelText: 'ID PIC',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data PIC berhasil diupdate')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _deletePic(Map<String, dynamic> pic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus PIC Line'),
        content: Text('Apakah Anda yakin ingin menghapus ${pic['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${pic['name']} berhasil dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _confirmNgProduct(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Barang NG'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produk: ${product['productName']}'),
            Text('Jumlah NG: ${product['ngCount']} barang'),
            const SizedBox(height: 16),
            const Text(
              'Barang NG akan dilebur/didaur ulang dan statusnya akan dihapus dari sistem.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Barang NG telah dikonfirmasi'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('KONFIRMASI'),
          ),
        ],
      ),
    );
  }

  void _viewNgDetails(String productName) {
    Navigator.pushNamed(context, '/ng-details', arguments: productName);
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.95,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.business, color: Colors.blue, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Detail Pesanan - ${order['ptName']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'INFORMASI PESANAN',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildOrderDetailRow('Tanggal Pemesanan', order['orderDate']),
                              _buildOrderDetailRow('Tanggal Pengiriman', order['deliveryDate']),
                              _buildOrderDetailRow('Status', order['status']),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),      
                      const Text(
                        'DETAIL PRODUK',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Column(
                        children: (order['products'] as List).map<Widget>((product) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  Table(
                                    columnWidths: const {
                                      0: FixedColumnWidth(120),
                                      1: FixedColumnWidth(120),
                                    },
                                    children: [
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              'Jumlah:',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              '${product['qty']} pcs',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              'Progress:',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              '${product['progress']}%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: product['progress'] >= 100 
                                                    ? Colors.green 
                                                    : Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              'Line Produksi:',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              product['productionLine'],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              'Mulai Produksi:',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              product['startDate'],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              'Target Selesai:',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              product['endDate'],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 8),           
                                  LinearProgressIndicator(
                                    value: product['progress'] / 100,
                                    backgroundColor: Colors.grey[300],
                                    color: product['progress'] >= 100 ? Colors.green : Colors.blue,
                                    minHeight: 6,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        color: Colors.green[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'RINGKASAN PESANAN',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Table(
                                columnWidths: const {
                                  0: FixedColumnWidth(140),
                                  1: IntrinsicColumnWidth(),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Text(
                                          'Total Produk:',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Text(
                                          '${order['products'].length} jenis produk',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Text(
                                          'Total Kuantitas:',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Text(
                                          '${order['products'].fold(0, (sum, product) => sum + product['qty'])} pcs',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Text(
                                          'Progress Rata-rata:',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Text(
                                          '${(order['products'].fold(0, (sum, product) => sum + product['progress']) / order['products'].length).toStringAsFixed(1)}%',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'TUTUP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}