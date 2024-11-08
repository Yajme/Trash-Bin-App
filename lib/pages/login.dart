import 'package:flutter/material.dart';
import 'package:trash_bin_app/model/globals.dart' as global;
//TODO : create a login page
//! Remember to include the token that can be found global.token to the body of authentication
//! e.g. final token = globals.token
//! {
//!  "username" : "bjarada"
//!   ...
//!  "token" : token
//! }
class Login extends StatefulWidget{

@override
  State<Login> createState() => _StateLogin();
}

class _StateLogin extends State<Login>{


@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('login Page'),),
      body: Container(child: Text('This is a login page'),),
    );
  }
}