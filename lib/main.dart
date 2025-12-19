import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:monitoringng1/screens/auth/login_screen.dart';
import 'package:monitoringng1/screens/head/dashboard_screen.dart';
import 'package:monitoringng1/screens/head/ng_details_screen.dart';
import 'package:monitoringng1/screens/pic/dashboard2_screen.dart';
import 'package:monitoringng1/screens/pic/quality_check_screen.dart';

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
        '/pic-dashboard': (context) => PicDashboardScreen(
          picId: 'PIC-BODY-001',
          category: 'Body Parts',
        ),
        '/quality-check': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return QualityCheckScreen(
            product: args?['product'] ?? {},
            picId: args?['picId'] ?? '',
          );
        },
      },
    );
  }
}