import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  final bool isTab;
  const EmergencyScreen({super.key, this.isTab = false});

  Future<void> _callEmergency() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '1990',
    );
    if (!await launchUrl(launchUri)) {
      debugPrint('Could not launch emergency call');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Safety Tips',
          style: TextStyle(
              color: Theme.of(context).appBarTheme.foregroundColor,
              fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: isTab
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: Theme.of(context).appBarTheme.foregroundColor),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Call Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C), // Red
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.local_hospital,
                      color: Colors.white, size: 40),
                  const SizedBox(height: 10),
                  const Text(
                    'Snake Bite Emergency?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Call Ambulance immediately',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFE74C3C),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _callEmergency,
                    icon: const Icon(Icons.call),
                    label: const Text(
                      'Call 1990',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const SizedBox(height: 30),

            Text(
              'Immediate Actions (Do\'s)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 15),
            _buildStep(
              context,
              number: '1',
              title: 'Move Away',
              description:
                  'සර්පයා ඇල්ලීමට/මරා දැමීමට උත්සහ නොකොට, ස්ථානයෙන් ඈත්ව සිටින්න. පළපුරුදු පුද්ගලයෙකු සම්බන්ධ කර ගැනීමට උත්සහ කරන්න.',
              icon: Icons.run_circle_outlined,
              color: Colors.green,
            ),
            _buildStep(
              context,
              number: '2',
              title: 'Stay Calm',
              description:
                  'රෝගියා සන්සුන්ව මෙන්ම දෂ්ට කළ ස්ථානය චලනය නොවන සේ තබා ගන්න. භීතිය හෘද ස්පන්දන වේගය වැඩි කරන අතර විෂ පැතිරීම වැඩි කරයි.',
              icon: Icons.self_improvement,
              color: Colors.blue,
            ),
            _buildStep(
              context,
              number: '3',
              title: 'Give First Aids',
              description:
                  'දෂ්ටනයට ලක්වූ ස්ථානය ගලායන ජලයෙන් මෘදුව පිරිසිදු කරන්න. අධික වේදනාවක් ඇත්නම් පමණක් පැරසිටමෝල් පෙති දෙකක් ලබා දෙන්න. හැකි ඉක්මනින් ළඟම රෝහල වෙත යන්න.',
              icon: Icons.healing,
              color: Colors.orange,
            ),
            _buildStep(
              context,
              number: '4',
              title: 'Remove Jewelry',
              description:
                  'ඉදිමීමක් ඇති විය හැකි බැවින් දෂ්ට කළ ස්ථානය අසල ඇති මුදු, ඔරලෝසු හෝ තද ඇඳුම් ඉවත් කරන්න.',
              icon: Icons.watch_off_outlined,
              color: Colors.purple,
            ),

            const SizedBox(height: 30),

            const Text(
              'What NOT To Do (Don\'ts)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 15),
            _buildDontStep(context,
                'කලබලයට පත් වී රෝගියාට අහිතකර කිසිවක් නොකරන්න. (Do NOT Panic)'),
            _buildDontStep(context,
                'දෂ්ට කළ ස්ථානය කැපීම හෝ මුඛය තබා ඉරීම නොකරන්න. (Do NOT suck out the venom)'),
            _buildDontStep(context,
                'මධ්‍යසාර සහ ආහාර වර්ග සර්ප විෂ ශරීරයේ පැතිරීම ඉක්මන් කරන හෙයින් ඒවා ලබා නොදෙන්න. (Do NOT give alcohol or food)'),
            _buildDontStep(context,
                'උණුවතුරින් තැවීම, අයිස් තැබීම, හෝ කොන්ඩිස් තුවාලාය සිදු වූ ස්ථානයේ තැබීම සිදු නොකරන්න. (Do NOT apply ice, heat, or Condis)'),
            _buildDontStep(context,
                'දෂ්ටනය වූ ස්ථානයේ වෙළුම් පටි යෙදීමෙන් වළකින්න. (Do NOT apply a bandage)'),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDontStep(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.cancel, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
