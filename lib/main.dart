// ...existing code...
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monitoringng2/config/firebase_config.dart';
import 'package:monitoringng2/config/routes.dart';
import 'package:monitoringng2/providers/auth_provider.dart';
import 'package:monitoringng2/providers/theme_provider.dart';
import 'package:monitoringng2/providers/target_provider.dart';
import 'package:monitoringng2/providers/ng_item_provider.dart';
import 'package:monitoringng2/screens/auth/login_screen.dart';
import 'package:monitoringng2/screens/head/head_dashboard.dart';
import 'package:monitoringng2/screens/pic/pic_dashboard.dart';
import 'package:monitoringng2/utils/constants.dart';
import 'package:monitoringng2/models/user_model.dart';
import 'package:device_preview/device_preview.dart';
import 'package:monitoringng2/providers/pic_provider.dart';
// ...existing code...

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseConfig.initializeFirebase();
  
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TargetProvider()),
        ChangeNotifierProvider(create: (_) => NGItemProvider()),
        ChangeNotifierProvider(create: (_) => PicProvider()), // <-- ditambahkan
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: themeProvider.currentTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: Routes.generateRoute,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

// ...existing code...
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const SplashScreen();
        }
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Redirect berdasarkan role user (gunakan enum UserRole)
        final userRole = authProvider.user?.role;
        if (userRole == UserRole.headDept) {
          return const HeadDashboard();
        } else if (userRole == UserRole.pic) {
          return const PicDashboard();
        }

        return const LoginScreen();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'PT Futaba Indonesia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}