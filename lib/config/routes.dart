import 'package:flutter/material.dart';
import 'package:monitoringng2/screens/auth/login_screen.dart';
import 'package:monitoringng2/screens/auth/register_head_screen.dart';
import 'package:monitoringng2/screens/head/head_dashboard.dart';
import 'package:monitoringng2/screens/pic/pic_dashboard.dart';

class Routes {
  static const String login = '/login';
  static const String registerHead = '/register-head';
  static const String headDashboard = '/head-dashboard';
  static const String picDashboard = '/pic-dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case registerHead:
        return MaterialPageRoute(builder: (_) => const RegisterHeadScreen());
      case headDashboard:
        return MaterialPageRoute(builder: (_) => const HeadDashboard());
      case picDashboard:
        return MaterialPageRoute(builder: (_) => const PicDashboard());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
