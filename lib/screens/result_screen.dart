import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ceylon_snakes/screens/emergency_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ceylon_snakes/services/classifier.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ceylon_snakes/providers/snake_provider.dart';
import 'package:ceylon_snakes/models/history_model.dart';

class ResultScreen extends StatefulWidget {
  final File image;
  final Map<String, dynamic> result;

  const ResultScreen({
    super.key,
    required this.image,
    required this.result,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late File _image;
  late Map<String, dynamic> _result;
  final ImagePicker _picker = ImagePicker();
  final Classifier _classifier = Classifier();
  bool _isLoading = false;
  ScanMode _scanMode = ScanMode.offline;

  @override
  void initState() {
    super.initState();
    _image = widget.image;
    _result = widget.result;
    _saveToHistory();
  }

  void _saveToHistory() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      double? latitude;
      double? longitude;

      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 5),
            );
            latitude = position.latitude;
            longitude = position.longitude;
          }
        }
      } catch (e) {
        debugPrint("Error getting location for history: $e");
      }

      if (!mounted) return;

      final provider = Provider.of<SnakeProvider>(context, listen: false);
      final historyItem = ScanHistory(
        snakeName: _result['label'],
        scanDate: DateTime.now(),
        confidenceLevel: "${(_result['confidence'] * 100).toStringAsFixed(1)}%",
        imagePath: _image.path,
        latitude: latitude,
        longitude: longitude,
      );
      provider.addScanHistory(historyItem);
    });
  }

  Future<void> _onScanAnother() async {
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
                  "Scan Another Snake",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
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

                _buildBottomSheetOption(
                  icon: Icons.camera_alt_rounded,
                  color: Colors.green,
                  title: "Take a Photo",
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndAnalyzeImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 16),
                _buildBottomSheetOption(
                  icon: Icons.photo_library_rounded,
                  color: Colors.blue,
                  title: "Choose from Gallery",
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndAnalyzeImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 20),
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
            color:
                isDarkMode ? Colors.grey[800]! : Colors.grey.withOpacity(0.2),
          ),
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
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
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
        setState(() {
          _isLoading = false;
          if (result != null) {
            _image = File(image.path);
            _result = result;
          }
        });

        if (result != null) {
          _saveToHistory();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not identify snake.')),
          );
        }
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String label = _result['label'];
    final double confidence = _result['confidence'] ?? 0.0;
    final int index = _result['index'] ?? -1;
    final int? predictedVenom = _result['predicted_venom'];

    // Check if scan was performed in Online Mode or Offline Mode
    final bool isOnline = _result['scan_mode'] == ScanMode.online ||
        _result['raw_species'] != null ||
        _result['is_online'] == true;

    // Logic for accuracy and venom status
    bool isUnsure = confidence < 0.7;
    // Map predicted_venom: 0 means Non-venomous, non-zero means Venomous
    bool isVenomous = (predictedVenom != null)
        ? (predictedVenom != 0)
        : (index == 0 || index == 1 || index == 3 || index == 4 || index == 6);

    Color statusColor;
    String title;
    String description;
    IconData icon;

    if (isUnsure) {
      statusColor = Colors.orange;
      title = "Unsure / Low Confidence | හඳුනා ගැනීමට අපහසුයි";
      description =
          "The AI is not confident (${(confidence * 100).toStringAsFixed(1)}%).\nPlease be careful and consult an expert.\n\nකරුණාකර විශේෂඥයෙකුගෙන් උපදෙස් ලබා ගන්න. දෂ්ටනයක් හෝ සපාකෑමක් සිදුවී ඇත්නම්, හැකි ඉක්මනින් ළඟම රෝහල වෙත යන්න. සර්පයා මරා දැමීමට හෝ නිදහස් අතින් ඇල්ලීමට උත්සහ කිරීමෙන් වලකින්න.";
      icon = Icons.warning_amber_rounded;
    } else if (isVenomous) {
      statusColor = Colors.red;
      title = "DANGER: Venomous | විෂ සහිත සර්පයෙකි";
      description =
          "This snake is HIGHLY VENOMOUS.\nSeek medical attention immediately if bitten.\n\nමෙම සර්පයා විෂ සහිතය.\nදෂ්ටනයක් සිදුවී ඇත්නම් සිදුවී ඇත්නම් ගලායන ජලයෙන් තුවාලය පිරිසිදු කර, හැකි ඉක්මනින් ළඟම ඇති රජයේ රෝහල වෙත යන්න.";
      icon = Icons.dangerous;
    } else {
      statusColor = Colors.green;
      title = "Safe: Non-Venomous | නිර්විෂ සර්පයෙකි";
      description =
          "This snake is non-venomous.\n\nමෙම සර්පයා නිර්විෂ සර්පයෙකි.\nනමුත් සපාකෑමක් සිදුවී ඇත්නම් ගලායන ජලයෙන් තුවාලය පිරිසිදු කර, ළඟම ඇති රජයේ රෝහල වෙත යන්න.";
      icon = Icons.check_circle;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Identification Result',
          style: TextStyle(
              color: Theme.of(context).appBarTheme.foregroundColor,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Image Section
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    image: DecorationImage(
                      image: FileImage(_image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Result Content
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Header
                      Row(
                        children: [
                          Icon(icon, color: statusColor, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Species Name
                      const Text(
                        "Identified Species",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 8),
                      // Mode Badge & Confidence Badge Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Mode Badge (Online Mode / Offline Mode)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? (isDarkMode
                                      ? const Color(0xFF2ECC71)
                                          .withOpacity(0.18)
                                      : const Color(0xFF2ECC71)
                                          .withOpacity(0.12))
                                  : (isDarkMode
                                      ? Colors.blue.withOpacity(0.18)
                                      : Colors.blue.withOpacity(0.12)),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isOnline
                                    ? const Color(0xFF2ECC71).withOpacity(0.4)
                                    : Colors.blue.withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOnline
                                      ? Icons.auto_awesome
                                      : Icons.wifi_off_rounded,
                                  size: 14,
                                  color: isOnline
                                      ? const Color(0xFF2ECC71)
                                      : (isDarkMode
                                          ? Colors.blue[300]
                                          : Colors.blue[700]),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isOnline ? "Online Mode" : "Offline Mode",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isOnline
                                        ? const Color(0xFF2ECC71)
                                        : (isDarkMode
                                            ? Colors.blue[300]
                                            : Colors.blue[700]),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Confidence Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Confidence: ${(confidence * 100).toStringAsFixed(1)}%",
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.grey[700],
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Description / Warning
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Safety Details",
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Action Buttons based on status
                      if (isVenomous && !isUnsure)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.medical_services),
                            label: const Text(
                              'Safety Tips',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EmergencyScreen(),
                                ),
                              );
                            },
                          ),
                        ),

                      if (!isVenomous && !isUnsure)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.health_and_safety),
                            label: const Text(
                              'View Safety Tips',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EmergencyScreen(),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          onPressed: _onScanAnother,
                          child: Text("Scan Another",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
              ),
            ),
        ],
      ),
    );
  }
}
