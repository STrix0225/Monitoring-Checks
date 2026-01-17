// lib/screens/pic/pic_dashboard.dart (UPDATE LENGKAP)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monitoringng2/providers/auth_provider.dart';
import 'package:monitoringng2/providers/target_provider.dart';
import 'package:monitoringng2/providers/ng_item_provider.dart';
import 'package:monitoringng2/models/target_model.dart';
import 'package:monitoringng2/models/qc_record_model.dart';
import 'package:monitoringng2/models/ng_item_model.dart';
import 'package:monitoringng2/screens/pic/qc_form_screen.dart';
import 'package:monitoringng2/screens/pic/qc_history_screen.dart';
import 'package:monitoringng2/services/qc_service.dart';
import 'package:monitoringng2/utils/constants.dart';
import 'package:monitoringng2/widgets/custom_app_bar.dart';

class PicDashboard extends StatefulWidget {
  const PicDashboard({super.key});

  @override
  State<PicDashboard> createState() => _PicDashboardState();
}

class _PicDashboardState extends State<PicDashboard> {
  late Map<String, int> _stats = {
    'targets': 0,
    'qcToday': 0,
    'ngItems': 0,
  };
  final QCService _qcService = QCService();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    
    if (user != null && user.userId.isNotEmpty) {
      final targetProvider = context.read<TargetProvider>();
      final stats = await targetProvider.getPICStats(user.userId);
      
      setState(() {
        _stats = {
          'targets': stats['totalQCToday'] ?? 0,
          'qcToday': stats['okQCToday'] ?? 0,
          'ngItems': stats['ngItems'] ?? 0,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard PIC',
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QCHistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(20),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    (user?.name ?? 'P').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'PIC',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.specialCode ?? '-',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        user?.department ?? '-',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;
                
                if (user == null || user.userId.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Target Aktif',
                        value: '0',
                        icon: Icons.assignment,
                        color: Theme.of(context).primaryColor,
                        onTap: null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StreamBuilder<List<QCRecord>>(
                        stream: FirebaseFirestore.instance
                            .collection(AppConstants.qcRecordsCollection)
                            .where('picId', isEqualTo: user.userId)
                            .snapshots()
                            .map((snapshot) => snapshot.docs
                                .map((doc) => QCRecord.fromFirestore(doc))
                                .toList()),
                        builder: (context, snapshot) {
                          final qcRecords = snapshot.data ?? [];
                          final now = DateTime.now();
                          final startOfDay = DateTime(now.year, now.month, now.day);
                          final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
                          
                          final todayCount = qcRecords
                              .where((record) =>
                                  record.qcTimestamp.isAfter(startOfDay) &&
                                  record.qcTimestamp.isBefore(endOfDay))
                              .length;

                          return _buildStatCard(
                            title: 'QC Hari Ini',
                            value: todayCount.toString(),
                            icon: Icons.checklist,
                            color: Colors.green,
                            onTap: () => _showQCTodayList(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StreamBuilder<List<NGItem>>(
                        stream: FirebaseFirestore.instance
                            .collection(AppConstants.ngItemsCollection)
                            .where('picId', isEqualTo: user.userId)
                            .where('status', isEqualTo: 'pending')
                            .snapshots()
                            .map((snapshot) => snapshot.docs
                                .map((doc) => NGItem.fromFirestore(doc))
                                .toList()),
                        builder: (context, snapshot) {
                          final ngItems = snapshot.data ?? [];

                          return _buildStatCard(
                            title: 'Barang NG',
                            value: ngItems.length.toString(),
                            icon: Icons.warning,
                            color: Colors.orange,
                            onTap: () => _showNGItemsList(),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Assigned Targets
          Expanded(
            child: _buildTargetsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final card = Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );

    return onTap != null ? InkWell(onTap: onTap, child: card) : card;
  }

  Widget _buildTargetsList() {
    return Consumer2<AuthProvider, TargetProvider>(
      builder: (context, authProvider, targetProvider, child) {
        final user = authProvider.user;
        
        if (user == null || user.specialCode == null) {
          return const Center(
            child: Text('User tidak valid. Silakan login ulang.'),
          );
        }

        return StreamBuilder<List<DailyTarget>>(
          stream: targetProvider.getTargetsByPICStream(user.specialCode!),
          builder: (context, snapshot) {
            // Update stats based on stream data
            if (snapshot.hasData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _stats['targets'] != snapshot.data!.length) {
                  setState(() {
                    _stats['targets'] = snapshot.data!.length;
                  });
                }
              });
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Retry loading
                        targetProvider.loadActiveTargets();
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Tidak ada target yang ditugaskan',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Hubungi kepala departemen untuk mendapatkan target',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final targets = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: targets.length,
              itemBuilder: (context, index) {
                final target = targets[index];
                return _buildTargetCard(target);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTargetCard(DailyTarget target) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    target.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: target.isActive ? Theme.of(context).primaryColor : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    target.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Category & Customer
            Text(
              'Kategori: ${target.category}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Customer: ${target.customer}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Target: ${target.quantity} pcs',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            // Progress
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: ${target.currentProgress}/${target.quantity}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${target.progressPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: target.progressPercentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    target.progressPercentage >= 100
                        ? Colors.green
                        : Theme.of(context).primaryColor,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),

            // Action Button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QCFormScreen(target: target),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('MULAI QC'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
    }
  }

  // Show QC Hari Ini as bottom sheet
  void _showQCTodayList() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    if (user == null || user.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User tidak valid')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'QC Hari Ini',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<QCRecord>>(
                stream: FirebaseFirestore.instance
                    .collection(AppConstants.qcRecordsCollection)
                    .where('picId', isEqualTo: user.userId)
                    .snapshots()
                    .map((snapshot) => snapshot.docs
                        .map((doc) => QCRecord.fromFirestore(doc))
                        .toList()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final qcRecords = snapshot.data ?? [];
                  
                  // Filter today's records
                  final now = DateTime.now();
                  final startOfDay = DateTime(now.year, now.month, now.day);
                  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
                  
                  final todayRecords = qcRecords
                      .where((record) =>
                          record.qcTimestamp.isAfter(startOfDay) &&
                          record.qcTimestamp.isBefore(endOfDay))
                      .toList()
                      ..sort((a, b) => b.qcTimestamp.compareTo(a.qcTimestamp));

                  if (todayRecords.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.checklist, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text('Belum ada QC hari ini'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: todayRecords.length,
                    itemBuilder: (context, index) {
                      final record = todayRecords[index];
                      final isOK = record.status == 'OK';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      record.productName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isOK ? Colors.green : Colors.orange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isOK ? 'OK' : 'NG',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kategori: ${record.category}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Waktu: ${record.qcTimestamp.hour.toString().padLeft(2, '0')}:${record.qcTimestamp.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              if (!isOK && record.failedPoints.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Alasan: ${record.failedPoints.join(", ")}',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show NG Items as bottom sheet
  void _showNGItemsList() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User tidak valid')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Barang NG',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<NGItem>>(
                stream: FirebaseFirestore.instance
                    .collection(AppConstants.ngItemsCollection)
                    .where('picId', isEqualTo: user.userId)
                    .where('status', isEqualTo: 'pending')
                    .snapshots()
                    .map((snapshot) => snapshot.docs
                        .map((doc) => NGItem.fromFirestore(doc))
                        .toList()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final ngItems = snapshot.data ?? [];

                  if (ngItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
                          const SizedBox(height: 16),
                          const Text('Tidak ada barang NG'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: ngItems.length,
                    itemBuilder: (context, index) {
                      final item = ngItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.status == 'pending'
                                          ? Colors.orange
                                          : Colors.blue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      item.status.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kategori: ${item.category}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Alasan: ${item.reason}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Waktu: ${item.ngTimestamp.hour.toString().padLeft(2, '0')}:${item.ngTimestamp.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}