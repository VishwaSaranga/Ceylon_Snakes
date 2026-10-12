import 'dart:async';
import 'package:flutter/material.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start checks after initial delay for branding
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _checkSystemRequirements();
    });
  }

  Future<void> _checkSystemRequirements() async {
    // 1. Check Connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    bool hasInternet = !connectivityResult.contains(ConnectivityResult.none);

    // 2. Check Location Service
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (hasInternet && isLocationEnabled) {
      // All good, proceed
      _navigateToHome();
    } else {
      // Something is missing, show warning
      if (!mounted) return;
      _showWarningDialog(
          hasInternet: hasInternet, isLocationEnabled: isLocationEnabled);
    }
  }

  void _showWarningDialog(
      {required bool hasInternet, required bool isLocationEnabled}) {
    List<String> missing = [];
    if (!hasInternet) missing.add("• Internet Connection");
    if (!isLocationEnabled) missing.add("• Location Services");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("System Requirements Check"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                "To use the full features of Ceylon Snakes app, please enable:"),
            const SizedBox(height: 10),
            Text(
              missing.join("\n"),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 10),
            const Text(
                "You can continue without them, but some features (like Hospital map, Online Scan) may not work."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _navigateToHome(); // Continue regardless
            },
            child: const Text("Continue Anyway"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _checkSystemRequirements(); // Retry
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              foregroundColor: Colors.white,
            ),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported,
                    size: 100, color: Colors.green);
              },
            ),
            const SizedBox(height: 24),
            // App Name
            const Text(
              'Ceylon Snakes',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green, // Matching theme
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
