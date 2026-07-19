import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'controllers/auth_controller.dart';
import 'controllers/appointment_controller.dart';
import 'controllers/company_controller.dart';
// import 'controllers/portal_controller.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'views/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service FIRST
  await StorageService().initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => AppointmentController()),
        ChangeNotifierProvider(create: (_) => CompanyController()),
        ChangeNotifierProvider(create: (_) => PortalController()),
      ],
      child: MaterialApp(
        title: 'Appointment Booking',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
