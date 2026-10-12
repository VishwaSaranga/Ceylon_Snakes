import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ceylon_snakes/services/classifier.dart';
import 'package:ceylon_snakes/screens/result_screen.dart';

class ScanScreen extends StatefulWidget {
  final ImageSource? initialSource;
  const ScanScreen({super.key, this.initialSource});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final Classifier _classifier = Classifier();
  
  // Default mode is Offline Mode
  ScanMode _selectedMode = ScanMode.offline;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _classifier.loadModel();
    if (widget.initialSource != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickAndAnalyze(widget.initialSource!);
      });
    }
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    try {
      final XFile? image = _selectedMode == ScanMode.online
          ? await _picker.pickImage(source: source)
          : await _picker.pickImage(
              source: source,
              maxWidth: 800,
              maxHeight: 800,
              imageQuality: 50,
            );
      if (image == null) return;

      setState(() => _isLoading = true);

      final file = File(image.path);
      final result = await _classifier.predict(file, mode: _selectedMode);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              image: file,
              result: result,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not identify snake. Please try another image.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    } on UnverifiedImageException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on NoInternetException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ServerException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF145A32);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Snake Scanner',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Banner / Intro
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2ECC71), Color(0xFF145A32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF145A32).withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.center_focus_strong,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scan & Identify',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Select scanning mode below before capturing or choosing an image.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // MODE SELECTION HEADER
                Text(
                  'Select Processing Mode',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // SEGMENTED CONTROL TOGGLE SWITCH (OFFLINE / ONLINE)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CupertinoSlidingSegmentedControl<ScanMode>(
                    groupValue: _selectedMode,
                    backgroundColor: Colors.transparent,
                    thumbColor: isDarkMode
                        ? primaryColor
                        : Colors.white,
                    children: {
                      ScanMode.offline: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              size: 18,
                              color: _selectedMode == ScanMode.offline
                                  ? (isDarkMode
                                      ? Colors.white
                                      : primaryColor)
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
                                color: _selectedMode == ScanMode.offline
                                    ? (isDarkMode
                                        ? Colors.white
                                        : primaryColor)
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
                            vertical: 12, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: _selectedMode == ScanMode.online
                                  ? (isDarkMode
                                      ? Colors.white
                                      : primaryColor)
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
                                  color: _selectedMode == ScanMode.online
                                      ? (isDarkMode
                                          ? Colors.white
                                          : primaryColor)
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
                        setState(() {
                          _selectedMode = value;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Mode Info Card
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedMode == ScanMode.offline
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedMode == ScanMode.offline
                          ? Colors.blue.withOpacity(0.3)
                          : Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedMode == ScanMode.offline
                            ? Icons.info_outline
                            : Icons.cloud_done_outlined,
                        size: 20,
                        color: _selectedMode == ScanMode.offline
                            ? Colors.blue
                            : Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedMode == ScanMode.offline
                              ? 'Offline Mode uses local TFLite model. Works anytime without internet.'
                              : 'Online Mode sends image to Cloud API for highest accuracy recognition.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // SCAN BUTTONS (Placed after the mode toggle switch)
                Text(
                  'Capture or Upload',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Take Photo Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickAndAnalyze(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded, size: 24),
                    label: Text(
                      'Take a Photo',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Choose from Gallery Button
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickAndAnalyze(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded, size: 24),
                    label: Text(
                      'Choose from Gallery',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDarkMode ? Colors.white : primaryColor,
                      side: BorderSide(
                        color: isDarkMode ? Colors.white54 : primaryColor,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      _selectedMode == ScanMode.online
                          ? 'Analyzing image via Cloud AI...'
                          : 'Analyzing image locally...',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
