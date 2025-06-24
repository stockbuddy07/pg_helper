import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UpiPaymentPage extends StatefulWidget {
  const UpiPaymentPage({super.key});

  @override
  State<UpiPaymentPage> createState() => _UpiPaymentPageState();
}

class _UpiPaymentPageState extends State<UpiPaymentPage> {
  final String upiId = 'example@upi';
final String payeeName = 'Your Business Name';
final String amount = '100'; // Optional: You can make it dynamic

  @override
  Widget build(BuildContext context) {
    String upiUrl =
        'upi://pay?pa=$upiId&pn=$payeeName&am=$amount&cu=INR';
    return Scaffold(
      appBar: AppBar(
        title: Text('Pay via UPI'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QrImageView(
                data: upiUrl,
                version: QrVersions.auto,
                size: 240.0,
              ),
              SizedBox(height: 24),
              Text(
                'Scan to Pay',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Or use UPI ID:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 6),
              SelectableText(
                upiId,
                style: TextStyle(fontSize: 18, color: Colors.blueAccent),
              ),
              SizedBox(height: 30),
              Text(
                'Amount: ₹$amount',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
