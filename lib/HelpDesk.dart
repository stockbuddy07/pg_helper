import 'package:flutter/material.dart';

class HelpDesk extends StatefulWidget {
  const HelpDesk({super.key});

  @override
  State<HelpDesk> createState() => _HelpDeskState();
}

class _HelpDeskState extends State<HelpDesk> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Desk'),
        backgroundColor: Color(0xff12d3c6), // same teal color
      ),
      body: const Center(
        child: Text(
          'Help Desk',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
