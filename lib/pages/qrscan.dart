import 'package:flutter/material.dart';

//TODO : QR Scanning Page
class QRScan extends StatefulWidget {
  @override
  State<QRScan > createState() => _StateQRScan ();
}

class _StateQRScan  extends State<QRScan > {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QRScan'),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: [
              Text('QR Scan'),
              
            ],
          ),
        ),
      ),
    );
  }
}
