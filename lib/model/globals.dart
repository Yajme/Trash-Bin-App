library my_prj.globals;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trash_bin_app/api/firebase_api.dart';

String? referenceNumber;
String token = '';
String role = '';
String user_id = '';
User? user;

clearGlobals() async {
  final pref = await SharedPreferences.getInstance();
  pref.clear();
  await FirebaseApi().deleteToken();
  token = '';
  role = '';
  user_id = '';
  user = null;
  await FirebaseApi().getToken();
}

class User {
  String address;
  String birthday;
  Name? name;
  String phoneNumber;

  User({
    this.address = '',
    this.birthday = '',
    this.name,
    this.phoneNumber = '',
  });

  static User fromMap(Map<String, dynamic> data) {
    return User(
      address: data['address'],
      birthday: data['birthday'],
      name: Name.fromMap(data['name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'birthday': birthday,
      'name': name?.toJson(),
    };
  }

  String getFirstName() => name?.first ?? '';
  String getLastName() => name?.last ?? '';
}

class Name {
  final String first;
  final String last;

  Name({required this.first, required this.last});

  static Name fromMap(Map<String, dynamic> data) {
    return Name(
      first: data['first'],
      last: data['last'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first': first,
      'last': last,
    };
  }

  String getFullName() {
    return '$first $last';
  }

  String getFirstName(){
    return first;
  }

  String getLastName(){
    return last;
  }
}