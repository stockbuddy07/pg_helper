import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  final String phoneNumber = '+911010101010';
  final String emailAddress = 'support@staymate.com';

  void _copyToClipboard(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.support_agent, size: 80, color: Colors.teal.shade400),
              const SizedBox(height: 24),
              const Text(
                'Need Help?\nWe\'re just a message away!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),

              // Email (copied to clipboard)
              InkWell(
                onTap: () => _copyToClipboard(context, "Email", emailAddress),
                child: Row(
                  children: [
                    const Icon(Icons.email, color: Colors.teal),
                    const SizedBox(width: 12),
                    Text(emailAddress,
                        style: const TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Phone (copied to clipboard)
              InkWell(
                onTap: () => _copyToClipboard(context, "Phone number", phoneNumber),
                child: Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.teal),
                    const SizedBox(width: 12),
                    Text(phoneNumber,
                        style: const TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
