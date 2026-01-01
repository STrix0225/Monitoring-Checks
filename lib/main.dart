import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:monitoringng1/screens/auth/login_screen.dart';
import 'package:monitoringng1/screens/head/dashboard_screen.dart';
import 'package:monitoringng1/screens/head/ng_details_screen.dart';
import 'package:monitoringng1/screens/pic/dashboard2_screen.dart';
import 'package:monitoringng1/models/pic_model.dart';
import 'package:monitoringng1/screens/pic/quality_check_screen.dart';
import 'package:monitoringng1/models/daily_target_model.dart';

void main() => runApp(
  DevicePreview(
    enabled: true,
    builder: (context) => const MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quality Check System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/head-dashboard': (context) => const DashboardNgPage(),
        '/ng-details': (context) => NgDetailsScreen(
          productName: ModalRoute.of(context)?.settings.arguments as String? ?? 'Unknown Product',
        ),
        '/pic-dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;

          String picId = 'PIC-BODY-001';
          String category = 'Body Parts';

          if (args is PicLineModel) {
            picId = args.id_pic;
            category = args.line.isNotEmpty ? args.line : category;
          } else if (args is Map<String, dynamic>) {
            picId = args['id_pic'] ?? args['picId'] ?? picId;
            category = args['category'] ?? args['line'] ?? category;
          }

          return PicDashboardScreen(
            picId: picId,
            category: category,
          );
        },
        '/quality-check': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;

          DailyTargetModel target;
          String picId = '';

          if (args is DailyTargetModel) {
            target = args;
          } else if (args is Map<String, dynamic>) {
            if (args.containsKey('target') && args['target'] is Map<String, dynamic>) {
              target = DailyTargetModel.fromJson(args['target']);
            } else {
              target = DailyTargetModel(
                customer: args['customer'] ?? '',
                category: args['category'] ?? '',
                product: args['product'] ?? '',
                targetQty: args['targetQty'] ?? 0,
                deliveryDate: args['deliveryDate'] is String
                    ? DateTime.tryParse(args['deliveryDate']) ?? DateTime.now()
                    : DateTime.now(),
                createdAt: DateTime.now(),
              );
            }
            picId = args['picId'] ?? '';
          } else {
            target = DailyTargetModel(
              customer: '',
              category: '',
              product: '',
              targetQty: 0,
              deliveryDate: DateTime.now(),
              createdAt: DateTime.now(),
            );
          }

          return QualityCheckScreenV2(
            target: target,
            picId: picId,
          );
        },
      },
    );
  }
}