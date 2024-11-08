import 'package:flutter/material.dart';

//TODO : create home page
class Home extends StatefulWidget{
  @override
  State<Home> createState() => _StateHome();
}

class _StateHome extends State<Home>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home'),),
      body: Center(
        child: Container(
          child: Column(
            children: [
              Text('Hello World'),
              ElevatedButton(onPressed: (){
                Navigator.pushReplacementNamed(context, '/login');
              }, child: Text('Go to login page'))
            ],
          ),
        ),
      ),
    );
  }
}