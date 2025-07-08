import 'package:flutter/material.dart';
import 'RoomsBySharingPage.dart';

class ShowRoomsPage extends StatelessWidget {
  final List<String> sharingOptions = ['2', '3', '4', '5'];

  final List<Color> iconColors = [
    Colors.blueAccent,
    Colors.green,
    Colors.deepOrange,
    Colors.purple,
  ];

  final List<IconData> sharingIcons = [
    Icons.group,
    Icons.group_work,
    Icons.people_alt,
    Icons.bed,
  ];

  void _navigateToSharingPage(BuildContext context, String sharing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomsBySharingPage(sharing: sharing),
      ),
    );
  }

  Widget _buildSharingCard(BuildContext context, String title, IconData icon, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(2, 2)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: iconColor),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // back button color
        title: const Text(
          "Select Room Sharing",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: sharingOptions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final sharing = sharingOptions[index];
            final iconColor = iconColors[index % iconColors.length];
            final icon = sharingIcons[index % sharingIcons.length];

            return _buildSharingCard(
              context,
              "$sharing Sharing",
              icon,
              iconColor,
                  () => _navigateToSharingPage(context, sharing),
            );
          },
        ),
      ),
    );
  }
}
