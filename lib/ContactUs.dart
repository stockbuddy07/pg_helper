import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  final String userFirstName;
  final String userLastName;

  const ContactUs({
    Key? key,
    required this.userFirstName,
    required this.userLastName,
  }) : super(key: key);

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final String phoneNumber = '+911010101010';
  final String emailAddress = 'support@staymate.com';
  final String websiteUrl = 'https://www.staymate.com';
  final String address = '123 PG Street, Bangalore, India - 560001';

  void _copyToClipboard(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final availableHeight = screenHeight - topPadding - kToolbarHeight;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // back button color
        title: const Text(
          "Contact Us",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
      ),

      body: SizedBox(
        height: availableHeight,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header Section
              Column(
                children: [
                  Icon(Icons.support_agent, size: 60, color: Colors.blueAccent),
                  const SizedBox(height: 10),
                  Text(
                    'Hello ${widget.userFirstName}!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'We\'re here to help you',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              // Contact Methods - Compact Version
              Column(
                children: [
                  _buildCompactContactItem(
                    icon: Icons.email,
                    label: 'Email Support',
                    value: emailAddress,
                    onTap: () => _copyToClipboard(context, "Email", emailAddress),
                    actionIcon: Icons.send,
                    action: () => _launchUrl('mailto:$emailAddress'),
                  ),
                  const SizedBox(height: 12),
                  _buildCompactContactItem(
                    icon: Icons.phone,
                    label: 'Call Support',
                    value: phoneNumber,
                    onTap: () => _copyToClipboard(context, "Phone", phoneNumber),
                    actionIcon: Icons.call,
                    action: () => _launchUrl('tel:$phoneNumber'),
                  ),
                  const SizedBox(height: 12),
                  _buildCompactContactItem(
                    icon: Icons.language,
                    label: 'Website',
                    value: websiteUrl,
                    onTap: () => _copyToClipboard(context, "Website", websiteUrl),
                    actionIcon: Icons.open_in_new,
                    action: () => _launchUrl(websiteUrl),
                  ),
                  const SizedBox(height: 15),
                  _buildCompactContactItem(
                    icon: Icons.location_on,
                    label: 'Our Office',
                    value: address,
                    onTap: () => _copyToClipboard(context, "Address", address),
                    actionIcon: Icons.map,
                    action: () => _launchUrl('https://maps.google.com/?q=$address'),
                  ),
                ],
              ),

              // Social Media & Address
              Column(
                children: [
                  const Text(
                    'Connect with us',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      _buildSocialIcon(Icons.facebook, () => _launchUrl('https://facebook.com/staymate')),
                      const SizedBox(width: 15),
                      _buildSocialIcon(Icons.chat, () => _launchUrl('https://wa.me/$phoneNumber')),
                                     ],
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required IconData actionIcon,
    required VoidCallback action,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(actionIcon, size: 20, color: Colors.blueAccent),
            onPressed: action,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: Colors.blueAccent),
      ),
    );
  }
}