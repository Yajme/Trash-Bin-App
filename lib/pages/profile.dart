import 'package:flutter/material.dart';
import 'package:trash_bin_app/model/globals.dart' as global;
//TODO : create home page
class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _StateProfile();
}

class _StateProfile extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: [
              Text('Profile Page'),
              ElevatedButton(
                  onPressed: ()  {
                    global.clearGlobals();
                    Navigator.popAndPushNamed(context, '/login');
                  },
                  child: Text('Logout'))
            ],
          ),
        ),
      ),
    );
  }
}
