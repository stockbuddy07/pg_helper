import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Add url_launcher to pubspec.yaml

class PrivacyPolicyWithConsent extends StatefulWidget {
  const PrivacyPolicyWithConsent({super.key});

  @override
  State<PrivacyPolicyWithConsent> createState() => _PrivacyPolicyWithConsentState();
}

class _PrivacyPolicyWithConsentState extends State<PrivacyPolicyWithConsent> {
  bool _isChecked = false;

  final String pdfUrl = 'https://yourdomain.com/privacy_policy.pdf'; // Replace with your actual PDF link

  void _launchPDF() async {
    final Uri uri = Uri.parse(pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the PDF.')),
      );
    }
  }

  void _onContinue() {
    if (_isChecked) {
      // Navigate to next screen
      Navigator.pop(context); // Or Navigator.push to home/login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to continue.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '📄 StayMate Privacy Policy',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'We respect your privacy. Here’s what we collect:\n\n'
                          '• Name, email, phone (with your consent)\n'
                          '• App usage and optional location data\n\n'
                          'Why we collect:\n'
                          '• To improve the app\n'
                          '• To connect you with PG owners\n\n'
                          'We do not sell your data. You can update or delete your info anytime.',
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '📧 Contact: support@staymateapp.com',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (value) => setState(() => _isChecked = value!),
                  activeColor: Colors.teal,
                ),
                const Expanded(
                  child: Text(
                    'I agree to the Privacy Policy.',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: _launchPDF,
              icon: const Icon(Icons.picture_as_pdf, color: Colors.teal),
              label: const Text(
                'View Full Privacy Policy (PDF)',
                style: TextStyle(color: Colors.teal),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}