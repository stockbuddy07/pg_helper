import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.teal,
        elevation: 1,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 600, // Limit for large screens
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/staymate.png',
                      height: constraints.maxHeight * 0.25,
                      fit: BoxFit.contain,
                    ),

                    // Welcome Title
                    const Text(
                      'Welcome to StayMate!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),

                    // Description
                    const Flexible(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'StayMate is your friendly companion in managing your PG lifestyle. Whether you’re a student or working professional, we’ve made it easier for you to keep track of your stay, access important information, and handle everything smoothly from one place.\n\n'
                              'From profile management to instant communication with owners, StayMate is built with your comfort in mind.\n\n'
                              'No more paperwork. No more confusion. Just convenience, clarity, and control — all at your fingertips.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    // Tagline
                    const Text(
                      '✨ Simplifying PG Life, One Tap at a Time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
