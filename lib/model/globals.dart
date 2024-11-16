library my_prj.globals;

import 'package:trash_bin_app/api/firebase_api.dart';

String token = '';
String role = '';
String user_id = '';
User? user;

clearGlobals() async {
  await FirebaseApi().deleteToken();
  token = '';
  role = '';
  user_id = '';
  user = null;
  token = await FirebaseApi().getToken();
}

class User {
  String address;
  String birthday;
  Name? name;
  String phoneNumber;

  User(
      {this.address = '',
      this.birthday = '',
      this.name,
      this.phoneNumber = ''});

  static User fromMap(Map<String, dynamic> data) {
    return User(
      address: data['address'],
      birthday: data['birthday'],
      name: Name(first: data['name']['first'], last: data['name']['last']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'birthday': birthday,
      'name': {'first': name!.first, 'last': name!.last}
    };
  }
}

class Name {
  final String first;
  final String last;

  Name({required this.first, required this.last});

  getFullName() {
    return '$first $last';
  }
}
