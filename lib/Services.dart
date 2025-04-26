import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'drawerSideNavigation.dart';

class Services extends StatefulWidget {
  const Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PG Services'),
        backgroundColor: Color(0xff12d3c6),

      ),
      endDrawer: const DrawerCode(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildServiceCard('Wi-Fi', 'High-speed internet with unlimited data and connectivity throughout the day.'),
              const SizedBox(height: 16),
              _buildServiceCard('Laundry Service', 'Weekly laundry service for clothes, including washing and ironing.'),
              const SizedBox(height: 16),
              _buildServiceCard('Room Cleaning', 'Daily room cleaning service to maintain hygiene and comfort.'),
              const SizedBox(height: 16),
              _buildServiceCard('24/7 Security', 'Round-the-clock security with CCTV cameras for safety and peace of mind.'),
              const SizedBox(height: 16),
              _buildServiceCard('Kitchen Facilities', 'Access to kitchen with all necessary utensils and appliances for self-cooking.'),
              const SizedBox(height: 16),
              _buildServiceCard('24/7 Water Supply', 'Continuous access to clean, filtered water for drinking and other needs.'),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create a service card
  Widget _buildServiceCard(String title, String description) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff12d3c6)),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                  fontSize: 16, color: Colors.black87, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
