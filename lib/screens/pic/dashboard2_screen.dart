import 'package:flutter/material.dart';

class PicDashboardScreen extends StatefulWidget {
  final String picId;
  final String category;

  const PicDashboardScreen({
    super.key,
    required this.picId,
    required this.category,
  });

  @override
  State<PicDashboardScreen> createState() => _PicDashboardScreenState();
}

class _PicDashboardScreenState extends State<PicDashboardScreen> {
  final Map<String, List<Map<String, dynamic>>> _categoryProducts = {
    'Body Parts': [
      {
        'id': 'BP001',
        'name': 'Front pillar upper outer',
        'target': 50,
        'completed': 48,
        'ptOrders': [
          {'ptName': 'PT Daihatsu', 'qty': 30, 'progress': 28},
          {'ptName': 'PT Toyota', 'qty': 20, 'progress': 20},
        ],
        'qualityItems': [
          {'name': 'Ketebalan', 'standard': '3.0 mm'},
          {'name': 'Penyok', 'standard': 'Tidak ada'},
          {'name': 'Diameter lubang', 'standard': '12.5 mm'},
        ],
      },
      {
        'id': 'BP002',
        'name': 'Front pillar lower outer',
        'target': 45,
        'completed': 42,
        'ptOrders': [
          {'ptName': 'PT Daihatsu', 'qty': 25, 'progress': 22},
          {'ptName': 'PT Honda', 'qty': 20, 'progress': 20},
        ],
        'qualityItems': [
          {'name': 'Ketebalan', 'standard': '2.8 mm'},
          {'name': 'Panjang', 'standard': '450 mm'},
          {'name': 'Sudut potong', 'standard': '45°'},
        ],
      },
    ],
    'Exhaust System Parts': [
      {
        'id': 'ES001',
        'name': 'Exhaust manifold',
        'target': 100,
        'completed': 95,
        'ptOrders': [
          {'ptName': 'PT Daihatsu', 'qty': 60, 'progress': 55},
          {'ptName': 'PT Suzuki', 'qty': 40, 'progress': 40},
        ],
        'qualityItems': [
          {'name': 'Ketebalan pipa', 'standard': '2.5 mm'},
          {'name': 'Kebocoran', 'standard': 'Tidak ada'},
          {'name': 'Diameter flange', 'standard': '85 mm'},
        ],
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final products = _categoryProducts[widget.category] ?? [];
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard PIC Line'),
            Text(
              widget.category,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.picId,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.category,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
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
                    const Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'PROGRESS HARIAN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...products.map((product) {
                      double progress = (product['completed'] / product['target']) * 100;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(product['name']),
                                ),
                                Text(
                                  '${product['completed']}/${product['target']}',
                                  style: TextStyle(
                                    color: progress >= 100 ? Colors.green : Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: product['completed'] / product['target'],
                              backgroundColor: Colors.grey[300],
                              color: progress >= 100 ? Colors.green : Colors.blue,
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: (product['ptOrders'] as List).map<Widget>((order) {
                                return Chip(
                                  label: Text('${order['ptName']}: ${order['progress']}/${order['qty']}'),
                                  backgroundColor: Colors.blue[50],
                                  labelStyle: const TextStyle(fontSize: 10),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }),
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
                    const Row(
                      children: [
                        Icon(Icons.list, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'DAFTAR PRODUK',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...products.map((product) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                product['id'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            product['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Target: ${product['target']} pcs/hari'),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: (product['ptOrders'] as List).map<Widget>((order) {
                                  return Chip(
                                    label: Text(
                                      order['ptName'],
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    backgroundColor: Colors.grey[100],
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () => _startQualityCheck(product),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  minimumSize: const Size(100, 36),
                                ),
                                child: const Text(
                                  'CHECK',
                                  style: TextStyle(fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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
                    const Row(
                      children: [
                        Icon(Icons.history, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'HISTORY CHECK HARI INI',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildHistoryItem('Front pillar upper outer', 'OK', '08:30'),
                    _buildHistoryItem('Front pillar lower outer', 'NG', '09:15'),
                    _buildHistoryItem('Cowl assembly', 'OK', '10:45'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _quickCheck(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHistoryItem(String productName, String status, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: status == 'OK' ? Colors.green[50] : Colors.red[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            status == 'OK' ? Icons.check_circle : Icons.error,
            color: status == 'OK' ? Colors.green : Colors.red,
          ),
        ),
        title: Text(productName),
        subtitle: Text('Checked at $time'),
        trailing: Chip(
          label: Text(status),
          backgroundColor: status == 'OK' ? Colors.green[100] : Colors.red[100],
          labelStyle: TextStyle(
            color: status == 'OK' ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _startQualityCheck(Map<String, dynamic> product) {
    Navigator.pushNamed(
      context,
      '/quality-check',
      arguments: {
        'product': product,
        'picId': widget.picId,
      },
    );
  }

  void _quickCheck() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildQuickCheckForm(),
    );
  }

  Widget _buildQuickCheckForm() {
    final products = _categoryProducts[widget.category] ?? [];
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUICK CHECK',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField(
            items: products.map((product) {
              return DropdownMenuItem(
                value: product['id'],
                child: Text(product['name']),
              );
            }).toList(),
            onChanged: (value) {},
            decoration: const InputDecoration(
              labelText: 'Pilih Produk',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Nomor Batch/Seri',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Status Kualitas:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, size: 16),
                      SizedBox(width: 4),
                      Text('OK'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close, size: 16),
                      SizedBox(width: 4),
                      Text('NG'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Quality check berhasil disimpan'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('SIMPAN CHECK'),
            ),
          ),
        ],
      ),
    );
  }
}