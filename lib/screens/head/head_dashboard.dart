// ...existing code...
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monitoringng2/providers/auth_provider.dart';
import 'package:monitoringng2/providers/target_provider.dart';
import 'package:monitoringng2/providers/ng_item_provider.dart';
import 'package:monitoringng2/providers/pic_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monitoringng2/screens/head/create_target_screen.dart';
import 'package:monitoringng2/screens/head/create_pic_screen.dart';
import 'package:monitoringng2/screens/head/ng_items_screen.dart';
import 'package:monitoringng2/screens/head/target_list_screen.dart';
import 'package:monitoringng2/models/ng_item_model.dart';
import 'package:monitoringng2/models/target_model.dart';
import 'package:monitoringng2/utils/constants.dart';
import 'package:monitoringng2/widgets/custom_app_bar.dart';

class HeadDashboard extends StatefulWidget {
  const HeadDashboard({super.key});

  @override
  State<HeadDashboard> createState() => _HeadDashboardState();
}

class _HeadDashboardState extends State<HeadDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DashboardHome(),
      const TargetListScreen(),
      const NGItemsScreen(),
      const CreatePICScreen(),
    ];

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NGItemProvider>(context, listen: false).loadPendingItems();
      Provider.of<TargetProvider>(context, listen: false).loadActiveTargets();
      // PicProvider already listens to Firestore in its constructor
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppConstants.appName,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showNotifications,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'profile') {
                _showProfile();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTargetScreen(),
                  ),
                );
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Target',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Barang NG',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Tambah PIC',
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifikasi'),
        content: const Text('Tidak ada notifikasi baru'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showProfile() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue[100],
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileItem('Nama', user?.name ?? '-'),
            _buildProfileItem('Email', user?.email ?? '-'),
            _buildProfileItem('Role', 'Kepala Departemen QC'),
            _buildProfileItem('Departemen', 'Quality Control'),
          ],
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

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang,',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                    return Text(
                      authProvider.user?.name ?? 'Kepala Departemen',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    );
                  }),
                ],
              ),
              GestureDetector(
                onTap: () => _showHeadProfile(context),
                child: const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Grid
          const StatsGrid(),
          const SizedBox(height: 24),

          // Recent Activity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Aktivitas Terbaru',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () => _showAllActivities(context),
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Consumer<TargetProvider>(
                    builder: (context, targetProvider, child) {
                      // Get recent targets sorted by creation date
                      final recentTargets = targetProvider.activeTargets
                          .toList()
                        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                      // Show only 5 most recent activities
                      final displayTargets = recentTargets.take(5).toList();

                      if (displayTargets.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Belum ada aktivitas terbaru',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: displayTargets.length,
                        itemBuilder: (context, index) {
                          final target = displayTargets[index];
                          return _buildActivityItem(
                            title: 'Target baru dibuat',
                            subtitle:
                                '${target.productName} - ${target.quantity} pcs',
                            time: _formatTime(target.createdAt),
                            icon: Icons.add_circle,
                            color: Colors.green,
                            onTap: () => _showTargetDetails(context, target),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  // Helper function to format time
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  // Show target details dialog
  void _showTargetDetails(BuildContext context, DailyTarget target) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Target'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Produk', target.productName),
            _buildDetailItem('Kategori', target.category),
            _buildDetailItem('Quantity', '${target.quantity} pcs'),
            _buildDetailItem('Customer', target.customer),
            _buildDetailItem(
                'Progress', '${target.currentProgress}/${target.quantity} pcs'),
            _buildDetailItem('PIC', target.assignedTo.join(', ')),
            _buildDetailItem('Tanggal Target',
                '${target.targetDate.day}/${target.targetDate.month}/${target.targetDate.year}'),
            _buildDetailItem('Dibuat',
                '${target.createdAt.day}/${target.createdAt.month}/${target.createdAt.year}'),
          ],
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

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // Show all activities dialog
  void _showAllActivities(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Semua Aktivitas'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: Consumer<TargetProvider>(
            builder: (context, targetProvider, child) {
              final allTargets = targetProvider.activeTargets.toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

              if (allTargets.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada aktivitas',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: allTargets.length,
                itemBuilder: (context, index) {
                  final target = allTargets[index];
                  final progress = target.quantity > 0
                      ? ((target.currentProgress / target.quantity) * 100)
                          .toStringAsFixed(0)
                      : '0';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_circle,
                          color: Colors.green,
                        ),
                      ),
                      title: Text(
                        'Target baru dibuat',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${target.productName} - ${target.quantity} pcs',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Progress: $progress% (${target.currentProgress}/${target.quantity})',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                          Text(
                            'PIC: ${target.assignedTo.join(", ")}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatTime(target.createdAt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'AKTIF',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showTargetDetails(context, target);
                      },
                    ),
                  );
                },
              );
            },
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

  // Show head profile dialog
  void _showHeadProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          return AlertDialog(
            title: const Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text('Profile Head'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileField('Nama', user?.name ?? 'Tidak diketahui'),
                _buildProfileField('Email', user?.email ?? 'Tidak diketahui'),
                _buildProfileField('Role', (user?.role ?? 'head').toString()),
                _buildProfileField(
                    'Department', user?.department ?? 'Tidak diketahui'),
                _buildProfileField(
                    'Status', user?.isActive == true ? 'Aktif' : 'Tidak Aktif'),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dashboard untuk monitoring dan pengawasan target produksi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<TargetProvider, NGItemProvider, PicProvider>(
      builder: (context, targetProvider, ngProvider, picProvider, child) {
        // Count only pending (orange) items
        final pendingCount = ngProvider.pendingItems
            .where((item) => item.status == 'pending')
            .length;

        final stats = {
          'Target Aktif': {
            'value': targetProvider.activeTargets.length.toString(),
            'icon': Icons.assignment,
            'color': Colors.blue,
          },
          'Progress Hari Ini': {
            'value': '${targetProvider.todayProgress.toStringAsFixed(0)}%',
            'icon': Icons.trending_up,
            'color': Colors.green,
          },
          'Barang NG': {
            'value': pendingCount.toString(),
            'icon': Icons.warning,
            'color': Colors.orange,
          },
          'Total PIC': {
            'value': picProvider.pics.length.toString(),
            'icon': Icons.people,
            'color': Colors.purple,
          },
        };

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: stats.entries.map((entry) {
            final title = entry.key;
            VoidCallback? onTap;
            if (title == 'Target Aktif') {
              onTap =
                  () => _showTargetList(context, targetProvider.activeTargets);
            } else if (title == 'Progress Hari Ini') {
              onTap = () =>
                  _showTodayProgress(context, targetProvider.activeTargets);
            } else if (title == 'Total PIC') {
              onTap = () => _showPICList(context, picProvider.pics);
            } else if (title == 'Barang NG') {
              onTap = () => _showNGItemsList(context, ngProvider.pendingItems);
            }

            return _buildStatCard(
              context: context,
              title: title,
              value: entry.value['value'] as String,
              icon: entry.value['icon'] as IconData,
              color: entry.value['color'] as Color,
              onTap: onTap,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final card = Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );

    return onTap != null ? InkWell(onTap: onTap, child: card) : card;
  }
}

// ...existing code...
void _showPICList(BuildContext context, List<Pic> pics) async {
  // Fetch latest PICs from Firestore similar to CreateTargetScreen
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'pic')
      .where('isActive', isEqualTo: true)
      .get();

  final fetched = snapshot.docs.map((doc) {
    return Pic.fromDoc(doc);
  }).toList();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Daftar PIC'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: fetched.isEmpty
            ? const Center(child: Text('Tidak ada PIC'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: fetched.length,
                itemBuilder: (context, index) {
                  final pic = fetched[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(pic.name),
                    subtitle: Text(pic.department),
                  );
                },
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

void _showTodayProgress(BuildContext context, List<DailyTarget> targets) async {
  // Group targets by PIC to show progress per PIC
  Map<String, List<DailyTarget>> targetsByPic = {};

  for (var target in targets) {
    // Use the first assigned PIC if multiple are assigned
    final picName = target.assignedTo.isNotEmpty
        ? target.assignedTo.first
        : 'Tidak ada PIC';

    if (targetsByPic.containsKey(picName)) {
      targetsByPic[picName]!.add(target);
    } else {
      targetsByPic[picName] = [target];
    }
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Progress Hari Ini'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: targetsByPic.isEmpty
            ? const Center(child: Text('Tidak ada target aktif hari ini'))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Overall progress summary
                    Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.trending_up,
                                    color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Total Progress Hari Ini',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Consumer<TargetProvider>(
                              builder: (context, provider, child) {
                                final overallProgress = provider.todayProgress;
                                return Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: overallProgress / 100,
                                        backgroundColor: Colors.grey.shade300,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.green),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${overallProgress.toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Progress per PIC
                    ...targetsByPic.entries.map((entry) {
                      final picName = entry.key;
                      final picTargets = entry.value;

                      final totalQuantity = picTargets.fold(
                          0, (sum, target) => sum + target.quantity);
                      final totalProgress = picTargets.fold(
                          0, (sum, target) => sum + target.currentProgress);
                      final progressPercentage = totalQuantity > 0
                          ? (totalProgress / totalQuantity * 100)
                          : 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            child: Icon(Icons.person,
                                color: Colors.blue, size: 20),
                          ),
                          title: Text(
                            picName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: progressPercentage / 100,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        progressPercentage >= 80
                                            ? Colors.green
                                            : progressPercentage >= 50
                                                ? Colors.orange
                                                : Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${progressPercentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$totalProgress dari $totalQuantity pcs (${picTargets.length} target)',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          children: picTargets.map((target) {
                            final targetProgress = target.quantity > 0
                                ? (target.currentProgress /
                                    target.quantity *
                                    100)
                                : 0;
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.assignment, size: 16),
                              title: Text(
                                target.productName,
                                style: const TextStyle(fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${target.currentProgress}/${target.quantity} pcs (${targetProgress.toStringAsFixed(0)}%)',
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: targetProgress >= 100
                                      ? Colors.green
                                      : targetProgress >= 50
                                          ? Colors.orange
                                          : Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${targetProgress.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ],
                ),
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

void _showTargetList(BuildContext context, List<DailyTarget> targets) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Daftar Target Aktif'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: targets.isEmpty
            ? const Center(child: Text('Tidak ada target aktif'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: targets.length,
                itemBuilder: (context, index) {
                  final target = targets[index];
                  final progress = target.quantity > 0
                      ? ((target.currentProgress / target.quantity) * 100)
                          .toStringAsFixed(0)
                      : '0';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.assignment,
                          color: Colors.blue,
                        ),
                      ),
                      title: Text(
                        target.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Kategori: ${target.category}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          Text(
                            'Progress: $progress% (${target.currentProgress}/${target.quantity})',
                            style: const TextStyle(fontSize: 11),
                          ),
                          Text(
                            'Customer: ${target.customer}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'detail') {
                            _showTargetDetails(context, target);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'detail',
                            child: Text('Lihat Detail'),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'AKTIF',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
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

void _showNGItemsList(BuildContext context, List<NGItem> ngItems) async {
  try {
    // Fetch latest NG items from Firestore - filter for pending (orange) only
    final snapshot = await FirebaseFirestore.instance
        .collection(AppConstants.ngItemsCollection)
        .orderBy('ngTimestamp', descending: true)
        .get();

    final allItems = snapshot.docs.map((doc) {
      return NGItem.fromFirestore(doc);
    }).toList();

    // Filter for pending status in Dart
    final fetched = allItems.where((item) => item.status == 'pending').toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daftar Barang NG (Pending)'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: fetched.isEmpty
              ? const Center(child: Text('Tidak ada barang NG pending'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: fetched.length,
                  itemBuilder: (context, index) {
                    final item = fetched[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                _getStatusColor(item.status).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.warning,
                            color: _getStatusColor(item.status),
                          ),
                        ),
                        title: Text(
                          item.productName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Kategori: ${item.category}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              'PIC: ${item.picName}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusLabel(item.status),
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Global helper function for target details
void _showTargetDetails(BuildContext context, DailyTarget target) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Detail Target'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem('Produk', target.productName),
          _buildDetailItem('Kategori', target.category),
          _buildDetailItem('Quantity', '${target.quantity} pcs'),
          _buildDetailItem('Customer', target.customer),
          _buildDetailItem(
              'Progress', '${target.currentProgress}/${target.quantity} pcs'),
          _buildDetailItem('PIC', target.assignedTo.join(', ')),
          _buildDetailItem('Tanggal Target',
              '${target.targetDate.day}/${target.targetDate.month}/${target.targetDate.year}'),
          _buildDetailItem('Dibuat',
              '${target.createdAt.day}/${target.createdAt.month}/${target.createdAt.year}'),
        ],
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

Widget _buildDetailItem(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'pending':
      return Colors.orange;
    case 'confirmed_for_melt':
      return Colors.blue;
    case 'melted':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

String _getStatusLabel(String status) {
  switch (status) {
    case 'pending':
      return 'PENDING';
    case 'confirmed_for_melt':
      return 'KONFIRMASI';
    case 'melted':
      return 'PELEBURAN';
    default:
      return status.toUpperCase();
  }
}
