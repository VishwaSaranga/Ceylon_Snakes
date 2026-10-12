import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ceylon_snakes/services/classifier.dart';
import 'package:ceylon_snakes/screens/result_screen.dart';
import 'package:ceylon_snakes/screens/scan_screen.dart';
import 'package:ceylon_snakes/screens/history_screen.dart';
import 'package:ceylon_snakes/screens/favorites_screen.dart';
import 'package:ceylon_snakes/screens/chat_bot_screen.dart';
import 'package:ceylon_snakes/providers/theme_provider.dart';
import 'package:ceylon_snakes/screens/about_us_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  const HomeScreen({super.key, this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final Classifier _classifier = Classifier();
  bool _isLoading = false;
  ScanMode _scanMode = ScanMode.offline;

  final List<String> _safetyTips = [
    'Maintain a safe distance. Use Zoom!',
    'Do not use Flash. It scares the snake.',
    "Don't block the snake's escape route.",
    "Don't poke or provoke the animal.",
  ];

  @override
  void initState() {
    super.initState();
    _classifier.loadModel();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? Theme.of(context).scaffoldBackgroundColor
          : const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // 1. Green Header Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.35, // Approx 30-35%
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF145A32), // Dark Green
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),

          // 2. Scrollable Content
          SingleChildScrollView(
            child: Column(
              children: [
                // Header Content
                Padding(
                  padding: EdgeInsets.fromLTRB(24, topPadding + 20, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Logo & Settings
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 45,
                            width: 45,
                            fit: BoxFit.contain,
                          ),
                          GestureDetector(
                            onTap: () => _showSettingsDialog(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.settings_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Greeting
                      Text(
                        'Hello, Explorer!',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Description Text
                      Text(
                        'Welcome to the Ceylon Snakes. Your trusted guide for snake identification and safety around Sri Lanka.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Hero Card (Identify Snake)
                Transform.translate(
                  offset: const Offset(0, 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildHeroCard(context),
                  ),
                ),

                const SizedBox(height: 24),

                const SizedBox(height: 24),

                // Secondary Section (Quick Access)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          'Quick Access',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            // Ensure text is visible on dark background
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF333333),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 16,
                        alignment: WrapAlignment.start,
                        children: [
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 64) / 3,
                            child: _buildQuickAccessCard(
                              title: 'Hospitals',
                              icon: Icons.local_hospital_rounded,
                              iconColor: Colors.redAccent,
                              onTap: () => widget.onTabChange?.call(2),
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 64) / 3,
                            child: _buildQuickAccessCard(
                              title: 'Library',
                              icon: Icons.menu_book_rounded,
                              iconColor: Colors.blueAccent,
                              onTap: () => widget.onTabChange?.call(3),
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 64) / 3,
                            child: _buildQuickAccessCard(
                              title: 'Safety Tips',
                              icon: Icons.health_and_safety_rounded,
                              iconColor: Colors.orangeAccent,
                              onTap: () => widget.onTabChange?.call(1),
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 64) / 3,
                            child: _buildQuickAccessCard(
                              title: 'History',
                              icon: Icons.history_rounded,
                              iconColor: Colors.purpleAccent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HistoryScreen()),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 64) / 3,
                            child: _buildQuickAccessCard(
                              title: 'Favorites',
                              icon: Icons.favorite_rounded,
                              iconColor: Colors.pinkAccent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const FavoritesScreen()),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 64) / 3,
                            child: _buildQuickAccessCard(
                              title: 'SerpentX',
                              icon: Icons.forum_rounded,
                              iconColor: Colors.teal,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ChatBotScreen()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40), // Bottom padding
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return GestureDetector(
      onTap: _onIdentifySnake,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2ECC71), Color(0xFF145A32)], // Green Gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF145A32).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.camera,
                size: 150,
                color: Colors.white.withOpacity(0.1),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.center_focus_strong,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'AI Powered Recognition',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          'Identify Snake',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Click Here to Scan',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Large Camera Illustration/Icon on the right
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF145A32),
                      size: 35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Logic & Actions ---

  Future<void> _onIdentifySnake() async {
    await _showSafetyWarning(context);
  }

  Future<void> _showSafetyWarning(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.redAccent, size: 32),
                const SizedBox(width: 12),
                Text(
                  "Safety First",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ..._safetyTips
                .map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tip,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showImageSourceOptions();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "I Understand & Continue",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showImageSourceOptions() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Start Identification",
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 16),

                // MODE SELECTION LABEL
                Text(
                  "Processing Mode",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),

                // SEGMENTED CONTROL TOGGLE SWITCH BEFORE SCAN BUTTONS
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CupertinoSlidingSegmentedControl<ScanMode>(
                    groupValue: _scanMode,
                    backgroundColor: Colors.transparent,
                    thumbColor:
                        isDarkMode ? const Color(0xFF145A32) : Colors.white,
                    children: {
                      ScanMode.offline: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              size: 16,
                              color: _scanMode == ScanMode.offline
                                  ? (isDarkMode
                                      ? Colors.white
                                      : const Color(0xFF145A32))
                                  : (isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[700]),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Offline Mode',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _scanMode == ScanMode.offline
                                    ? (isDarkMode
                                        ? Colors.white
                                        : const Color(0xFF145A32))
                                    : (isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ScanMode.online: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: _scanMode == ScanMode.online
                                  ? (isDarkMode
                                      ? Colors.white
                                      : const Color(0xFF145A32))
                                  : (isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[700]),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Online Mode (High Accuracy)',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _scanMode == ScanMode.online
                                      ? (isDarkMode
                                          ? Colors.white
                                          : const Color(0xFF145A32))
                                      : (isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[700]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    },
                    onValueChanged: (ScanMode? value) {
                      if (value != null) {
                        setModalState(() {
                          _scanMode = value;
                        });
                        setState(() {
                          _scanMode = value;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // SCAN BUTTONS AFTER TOGGLE SWITCH
                _buildBottomSheetOption(
                  icon: Icons.camera_alt_rounded,
                  color: Colors.green,
                  title: "Take a Photo",
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndAnalyzeImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 12),
                _buildBottomSheetOption(
                  icon: Icons.photo_library_rounded,
                  color: Colors.blue,
                  title: "Choose from Gallery",
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndAnalyzeImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 12),
                _buildBottomSheetOption(
                  icon: Icons.fullscreen_rounded,
                  color: Colors.purple,
                  title: "Open Full Scanner Screen",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
              color: isDarkMode
                  ? Colors.grey[800]!
                  : Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Theme',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildThemeOption(context,
                      icon: Icons.light_mode,
                      title: 'Light Mode',
                      isSelected: themeProvider.themeMode == ThemeMode.light,
                      onTap: () {
                    themeProvider.setTheme(ThemeMode.light);
                    Navigator.pop(context);
                  }),
                  _buildThemeOption(context,
                      icon: Icons.dark_mode,
                      title: 'Dark Mode',
                      isSelected: themeProvider.themeMode == ThemeMode.dark,
                      onTap: () {
                    themeProvider.setTheme(ThemeMode.dark);
                    Navigator.pop(context);
                  }),
                  _buildThemeOption(context,
                      icon: Icons.brightness_auto,
                      title: 'System Default',
                      isSelected: themeProvider.themeMode == ThemeMode.system,
                      onTap: () {
                    themeProvider.setTheme(ThemeMode.system);
                    Navigator.pop(context);
                  }),
                  const Divider(height: 30),
                  ListTile(
                    leading: Icon(Icons.info_outline_rounded,
                        color: isDarkMode ? Colors.white : Colors.black87),
                    title: Text(
                      'About Us',
                      style: GoogleFonts.poppins(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16,
                        color:
                            isDarkMode ? Colors.grey[600] : Colors.grey[400]),
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutUsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: GoogleFonts.poppins(color: textColor)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF2ECC71))
          : null,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _pickAndAnalyzeImage(ImageSource source) async {
    try {
      final XFile? image = _scanMode == ScanMode.online
          ? await _picker.pickImage(source: source)
          : await _picker.pickImage(
              source: source,
              maxWidth: 800,
              maxHeight: 800,
              imageQuality: 50,
            );
      if (image == null) return;

      setState(() => _isLoading = true);

      // Analyze using selected scan mode
      final result =
          await _classifier.predict(File(image.path), mode: _scanMode);

      if (mounted) {
        setState(() => _isLoading = false);
      }

      if (mounted && result != null) {
        final navResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              image: File(image.path),
              result: result,
            ),
          ),
        );

        if (navResult == 'scan_another' && mounted) {
          _onIdentifySnake();
        }
      } else if (mounted && result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Could not identify snake. Please try another image.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    } on UnverifiedImageException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on NoInternetException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on ServerException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
