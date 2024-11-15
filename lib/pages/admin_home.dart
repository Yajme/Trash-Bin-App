import 'package:flutter/material.dart';

//TODO : create home page
class AdminHome extends StatefulWidget {
  @override
  State<AdminHome> createState() => _StateHome();
}

class _StateHome extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home'),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: [
              Text('This is a admin home'),
              
            ],
          ),
        ),
      ),
    );
  }
}
