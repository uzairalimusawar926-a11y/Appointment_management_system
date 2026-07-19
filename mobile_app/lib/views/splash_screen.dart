import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../controllers/auth_controller.dart';
import '../controllers/company_controller.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../utils/app_theme.dart';
import 'auth/login_screen.dart';
import 'auth/server_config_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    
    _animationController.forward();
    
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Storage is already initialized in main.dart
      
      // Check if server URL is configured
      final serverUrl = StorageService().getServerUrl();
      
      if (serverUrl != null && serverUrl.isNotEmpty) {
        // Set base URL and initialize API service
        ApiConfig.setBaseUrl(serverUrl);
        ApiService().initialize();
        
        // Small delay to show splash
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Load company settings
        if (mounted) {
          try {
            await Provider.of<CompanyController>(context, listen: false).fetchCompanySettings();
          } catch (e) {
            debugPrint('Company settings error: $e');
          }
        }
        
        // Check authentication
        if (mounted) {
          final authController = Provider.of<AuthController>(context, listen: false);
          bool isAuthenticated = false;
          
          try {
            isAuthenticated = await authController.checkAuthentication();
          } catch (e) {
            debugPrint('Auth check error: $e');
          }
          
          await Future.delayed(const Duration(seconds: 1));
          
          if (mounted) {
            if (isAuthenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          }
        }
      } else {
        // No server configured, go to server config
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ServerConfigScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ServerConfigScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo or Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Appointment Booking',
                  style: AppTheme.headingStyle.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your appointments effortlessly',
                  style: AppTheme.bodyStyle.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
