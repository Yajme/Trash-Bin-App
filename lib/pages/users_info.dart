import 'package:flutter/material.dart';
import 'package:trash_bin_app/model/globals.dart' as global;

class UserInfoPage extends StatelessWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Users')),
      body: const Center(child: Text('This is the View Users Page')),
    );
  }
}