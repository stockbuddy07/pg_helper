import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UpiPaymentPage extends StatefulWidget {
  const UpiPaymentPage({super.key});

  @override
  State<UpiPaymentPage> createState() => _UpiPaymentPageState();
}

class _UpiPaymentPageState extends State<UpiPaymentPage> {
  final String upiId = 'harshilsfilm@okhdfcbank';
  final String payeeName = 'Harshil Patel';
  final String amount = '13000';

  @override
  Widget build(BuildContext context) {
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
              // ✅ Display static QR image from assets
              Image.asset(
                'assets/qr.jpg',
                width: 240,
                height: 240,
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
