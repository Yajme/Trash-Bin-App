library my_prj.globals;
import 'package:trash_bin_app/api/firebase_api.dart';
String token = 'fcmToken';
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

  User({
    this.address = '',
    this.birthday = '',
    this.name,
    this.phoneNumber =''
  });
}

class Name {
final String first;
final String last;

Name({
  required this.first,
  required this.last
});

getFullName(){
  return '$first $last';
}
}