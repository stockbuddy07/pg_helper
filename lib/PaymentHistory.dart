import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'drawerSideNavigation.dart';
import 'HomePage.dart'; // Make sure to import your homepage

class UpiPaymentPage extends StatefulWidget {
  const UpiPaymentPage({super.key});

  @override
  State<UpiPaymentPage> createState() => _UpiPaymentPageState();
}

class _UpiPaymentPageState extends State<UpiPaymentPage> {
  final String upiId = 'staymate@hdfc';
  final String amount = '13,000';
  bool _isCopied = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: upiId));
    setState(() {
      _isCopied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isCopied = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('UPI Payment',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 20
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, size: 28),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const DrawerCode(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Payment Card with blue accent
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade50,
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          'PG Rent Payment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Monthly Rent',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // QR Code Container with white background
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.shade100,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade50,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/qr.jpg',
                                width: 200,
                                height: 200,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Scan QR Code to Pay',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Or Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.blue.shade100,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.blue.shade400,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.blue.shade100,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // UPI ID Section
                        Text(
                          'Pay using UPI ID',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.shade100,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                upiId,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _isCopied ? Icons.check : Icons.content_copy,
                                  color: _isCopied ? Colors.green : Colors.blueAccent,
                                ),
                                onPressed: _copyToClipboard,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Amount Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.shade100,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Amount to Pay',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              Text(
                                '₹$amount',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Payment Instructions with blue accent
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Instructions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionItem('1. Scan the QR code using any UPI app'),
                    _buildInstructionItem('2. Or enter the UPI ID manually'),
                    _buildInstructionItem('3. Verify the amount before payment'),
                    _buildInstructionItem('4. Payment confirmation will be automatic'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: Colors.blue.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}