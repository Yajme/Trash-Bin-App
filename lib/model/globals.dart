library my_prj.globals;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

Future<void> fetchUserData() async {
  final pref = await SharedPreferences.getInstance();
  String? userDataJson = pref.getString('user_data');

  if (userDataJson != null) {
    Map<String, dynamic> userDataMap = jsonDecode(userDataJson);
    user = User.fromMap(userDataMap);
  } else {
    // Fetch user data from Firestore if not found in SharedPreferences
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user_id).get();
    
    if (userDoc.exists) {
      // Safely access data
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      if (data != null) {
        user = User.fromMap(data);
        // Save to SharedPreferences if needed
        pref.setString('user_data', jsonEncode(user?.toJson()));
      }
    }
  }
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
      phoneNumber: data['phoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'birthday': birthday,
      'name': name?.toJson(),
      'phoneNumber': phoneNumber,
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