import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const Color _brandGreen = Color(0xFF145A32);

  Future<void> _openLink(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) throw Exception('Could not launch $url');
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 80,
                width: 80,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Ceylon Snakes',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : _brandGreen,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Identify • Learn • Protect',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
            _SectionTitle('What is Ceylon Snakes?', isDarkMode: isDarkMode),
            const SizedBox(height: 8),
            _BodyText(
              'Ceylon Snakes is a mobile application that helps people in Sri '
              'Lanka identify snakes from a photo. Using a two-stage deep '
              'learning approach, the app first locates the snake in the image '
              'and then identifies its species and venom category. It currently '
              'recognises eight snake species commonly found around human '
              'settlements in Sri Lanka.\n\n'
              'Beyond identification, the app provides snakebite first-aid '
              'guidance, a nearby hospital locator for anti-venom treatment, '
              'and one-tap access to emergency services. When the app is not '
              'confident about a result, it shows a safety warning instead of '
              'guessing.',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 24),
            _SectionTitle('Our Aim', isDarkMode: isDarkMode),
            const SizedBox(height: 8),
            _BodyText(
              'To provide an accessible, reliable and safety-first tool that '
              'helps the public recognise common Sri Lankan snakes, respond '
              'calmly and correctly during snake encounters and snakebite '
              'incidents, and reduce the unnecessary killing of snakes caused '
              'by fear and misidentification.',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 24),
            _SectionTitle('Our Vision', isDarkMode: isDarkMode),
            const SizedBox(height: 8),
            _BodyText(
              'A Sri Lanka where fear and misinformation no longer cost lives, '
              'whether human or snake. A place where everyone, from rural '
              'farming communities to city residents, can quickly find '
              'trustworthy information, reach medical care in time, and live '
              'safely alongside the island\'s valuable wildlife.',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 24),
            _SectionTitle('Terms and Conditions', isDarkMode: isDarkMode),
            const SizedBox(height: 8),
            _BodyText(
              'By using Ceylon Snakes, you agree to the following terms.',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 12),
            _TermItem(
              number: 1,
              title: 'Awareness tool, not medical advice',
              body: 'Ceylon Snakes is designed to support public awareness and '
                  'education. It does not provide medical diagnosis and must '
                  'never replace professional snake identification or advice '
                  'from a qualified medical practitioner.',
              isDarkMode: isDarkMode,
            ),
            _TermItem(
              number: 2,
              title: 'Accuracy and limitations',
              body:
                  'The app recognises only eight Sri Lankan snake species and '
                  'cannot identify species outside this set. Results may be '
                  'wrong, especially with poor lighting, blurry or partial '
                  'photos, camouflage or cluttered backgrounds. Offline mode '
                  'uses a simplified model and may be less accurate than '
                  'online mode. If the app shows a low-confidence warning, do '
                  'not rely on the result.',
              isDarkMode: isDarkMode,
            ),
            _TermItem(
              number: 3,
              title: 'In a snakebite emergency',
              body:
                  'Do not wait for the app to identify the snake. Seek medical '
                  'help immediately by calling 1990 or going to the nearest '
                  'hospital. Treat every snakebite as an emergency, whatever '
                  'the app reports.',
              isDarkMode: isDarkMode,
            ),
            _TermItem(
              number: 4,
              title: 'Your personal safety',
              body:
                  'Never approach, handle, provoke or try to catch a snake to '
                  'take a photo. Keep a safe distance at all times. We are not '
                  'responsible for any injury resulting from interacting with '
                  'snakes.',
              isDarkMode: isDarkMode,
            ),
            _TermItem(
              number: 5,
              title: 'Images and location',
              body:
                  'The app needs access to your camera or gallery to identify '
                  'snakes, and to your location to find nearby hospitals. In '
                  'offline mode, images are processed on your device. In online '
                  'mode, images may be sent to our server for analysis. Please '
                  'do not upload images that contain people or private '
                  'information.',
              isDarkMode: isDarkMode,
            ),
            _TermItem(
              number: 6,
              title: 'Third-party services',
              body:
                  'Maps and hospital data are provided through OpenStreetMap, '
                  'and navigation opens in Google Maps. These services are '
                  'governed by their own terms, and hospital information may '
                  'be incomplete or out of date.',
              isDarkMode: isDarkMode,
            ),
            _TermItem(
              number: 7,
              title: 'Research prototype and no warranty',
              body:
                  'Ceylon Snakes was developed as an undergraduate final-year '
                  'research project and is provided "as is", without '
                  'warranties of any kind. To the fullest extent permitted by '
                  'law, the developers and Horizon Campus are not liable for '
                  'any loss, injury or damage arising from the use of, or '
                  'reliance on, this app.',
              isDarkMode: isDarkMode,
            ),
            _TermItem(
              number: 8,
              title: 'Changes to these terms',
              body: 'These terms may be updated as the app develops. Continued '
                  'use of the app after an update means you accept the revised '
                  'terms.',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 12),
            _SectionTitle('Our Team', isDarkMode: isDarkMode),
            const SizedBox(height: 8),
            _BodyText(
              'Ceylon Snakes is an undergraduate final-year research project '
              'at Horizon Campus, Malabe, Sri Lanka, combining deep learning '
              'and mobile computing.',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 16),
            _TeamCard(
              name: 'W.V.S. Dissanayaka',
              role: 'App Designer and Developer',
              affiliation: 'Intake 11 NMC | Horizon Campus, Malabe',
              linkedInLabel: 'Vishwa Saranga',
              onLinkedInTap: () => _openLink(
                context,
                'https://www.linkedin.com/in/vishwasaranga',
              ),
              isDarkMode: isDarkMode,
            ),
            _TeamCard(
              name: 'S.A.C. Udayanga',
              role: 'AI Pipeline and Backend Developer',
              affiliation: 'Intake 11 NMC | Horizon Campus, Malabe',
              linkedInLabel: 'Chathura Udayanga',
              onLinkedInTap: () => _openLink(
                context,
                'https://www.linkedin.com/in/udayanga-c/',
              ),
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 8),
            Text(
              'Research Project Supervisors',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : _brandGreen,
              ),
            ),
            const SizedBox(height: 12),
            _TeamCard(
              name: 'Ms. Dulika Fonseka',
              role: 'Lecturer',
              affiliation: 'Horizon Campus, Malabe',
              isDarkMode: isDarkMode,
            ),
            _TeamCard(
              name: 'Mr. Daminda Herath',
              role: 'Senior Lecturer',
              affiliation: 'Horizon Campus, Malabe',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final bool isDarkMode;

  const _SectionTitle(this.text, {required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : AboutUsScreen._brandGreen,
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  final bool isDarkMode;

  const _BodyText(this.text, {required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        height: 1.6,
        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
      ),
    );
  }
}

class _TermItem extends StatelessWidget {
  final int number;
  final String title;
  final String body;
  final bool isDarkMode;

  const _TermItem({
    required this.number,
    required this.title,
    required this.body,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AboutUsScreen._brandGreen,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              '$number',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.6,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final String name;
  final String role;
  final String affiliation;
  final String? linkedInLabel;
  final VoidCallback? onLinkedInTap;
  final bool isDarkMode;

  const _TeamCard({
    required this.name,
    required this.role,
    required this.affiliation,
    required this.isDarkMode,
    this.linkedInLabel,
    this.onLinkedInTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.06)
            : AboutUsScreen._brandGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.12)
              : AboutUsScreen._brandGreen.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AboutUsScreen._brandGreen,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? const Color(0xFF58D68D)
                        : AboutUsScreen._brandGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  affiliation,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                if (onLinkedInTap != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: onLinkedInTap,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.link,
                            size: 18,
                            color: Color(0xFF0A66C2),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'LinkedIn: ${linkedInLabel ?? ''}',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF0A66C2),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
