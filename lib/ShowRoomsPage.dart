import 'package:flutter/material.dart';
import 'RoomsBySharingPage.dart';

class ShowRoomsPage extends StatelessWidget {
  final List<String> sharingOptions = ['2', '3', '4', '5'];

  final List<Color> cardColors = [
    Color(0xFF80DEEA), // Light Cyan
    Color(0xFF81C784), // Light Green
    Color(0xFFFFAB91), // Soft Orange
    Color(0xFFCE93D8), // Light Purple
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Room Sharing"),
        backgroundColor: const Color(0xD72A8AEA),
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
            final cardColor = cardColors[index % cardColors.length];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoomsBySharingPage(sharing: sharing),
                  ),
                );
              },
              child: Card(
                color: cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "$sharing Sharing",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
