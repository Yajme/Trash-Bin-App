import 'package:flutter/material.dart';
import 'package:trash_bin_app/model/globals.dart' as global;

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Records')),
      body: const Center(child: Text('This is the View Records Page')),
    );
  }
}