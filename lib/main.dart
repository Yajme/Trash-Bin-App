import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trash_bin_app/api/firebase_api.dart';
import 'package:trash_bin_app/pages/home.dart';
import 'package:trash_bin_app/pages/admin_home.dart';
import 'package:trash_bin_app/pages/login.dart';
import 'package:trash_bin_app/pages/qrscan.dart';
import 'package:trash_bin_app/pages/profile.dart';
import 'package:trash_bin_app/pages/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trash_bin_app/model/constants.dart';
import 'package:trash_bin_app/model/globals.dart' as global;
import 'package:trash_bin_app/pages/records.dart';
import 'package:trash_bin_app/pages/transactions.dart';
import 'package:trash_bin_app/pages/users_info.dart';
import 'package:trash_bin_app/pages/redeem.dart';
import 'package:trash_bin_app/pages/reference.dart';
import 'package:trash_bin_app/pages/convert.dart';
//TODO: Create a separate file for user and admins
//TODO: Enable camera permissions for qr scanning
//TODO: Implement QR scanning for trash disposal
//TODO: Create page for registering the users

//* For API Documentation : https://github.com/Yajme/trash-bin-api/?tab=readme-ov-file#trash-bin-api
//* API LINK: https://trash-bin-api.vercel.app/
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? "",
        appId: dotenv.env['FIREBASE_APP_ID'] ?? "",
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? "",
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? ""),
  );
  await FirebaseApi().initNotifications();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  //* Set this to false to access the Login Page
  bool isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    initPref();
  }

  Future<void> initPref() async {
    final pref = await SharedPreferences.getInstance();

    setState(() {
      isLoggedIn = pref.getBool('isLoggedIn') ?? false;
      if (isLoggedIn) {
        //Set Global Variables here
        global.user_id = pref.getString('user_id') ?? '';
        global.token = pref.getString('token') ?? '';
        global.role = pref.getString('role') ?? '';
        var userData =
            Map<String, dynamic>.from(jsonDecode(pref.getString('user')!));
        global.user = global.User.fromMap(userData);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xfff5f5f5),
        appBarTheme: AppBarTheme(
            titleTextStyle: TextStyle(color: ColorTheme.textColor['option 2']),
            backgroundColor: ColorTheme.primaryColor,
            iconTheme: IconThemeData(color: ColorTheme.textColor['option 2'])),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: ColorTheme.accentColor,
            unselectedItemColor: Colors.grey),
      ),
      debugShowCheckedModeBanner: false,
      //* If the [isLoggedIn] is set to true, the initial page will be set to the main page
      //* Otherwise the page will be redirected to login
      home: isLoggedIn
          ? global.role == 'admin'
              ? const AdminMainScaffolding()
              : const UserMainScaffolding()
          : Login(),
      routes: {
        '/user': (context) => const UserMainScaffolding(),
        '/admin': (context) => const AdminMainScaffolding(),
        '/login': (context) => Login(),
        '/records': (context) => const RecordsPage(),
        '/transactions': (context) => TransactionsPage(),
        '/users_info': (context) => const UserInfoPage(),
        '/register': (context) => const RegistrationPage(),
        '/redeem': (context) => RedemptionPage(),
        '/reference': (context) => ReferencePage(),
        '/convert' : (context) => ConvertWaste()
        //TODO: Add more routes here especially for admin
      },
    );
  }
}

class AdminMainScaffolding extends StatefulWidget {
  const AdminMainScaffolding({super.key});
  @override
  State<AdminMainScaffolding> createState() => _StateAdminMainScaffolding();
}

class _StateAdminMainScaffolding extends State<AdminMainScaffolding> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: IndexedStack(
          index: _selectedIndex,
          children: _adminPages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: adminBottomNavBarItems,
          currentIndex: _selectedIndex,
          //* Whenever an icon is pressed, the [index] of the bottomNavigation is set to [_selectedIndex]
          //* which will change the page in the scaffolding
          //* The pages is based on the List of pages
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ));
  }
}

class UserMainScaffolding extends StatefulWidget {
  const UserMainScaffolding({super.key});
  @override
  State<UserMainScaffolding> createState() => _StateUserMainScaffolding();
}

class _StateUserMainScaffolding extends State<UserMainScaffolding> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: IndexedStack(
          index: _selectedIndex,
          children: _userPages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: userBottomNavBarItems,
          currentIndex: _selectedIndex,
          //* Whenever an icon is pressed, the [index] of the bottomNavigation is set to [_selectedIndex]
          //* which will change the page in the scaffolding
          //* The pages is based on the List of pages
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ));
  }
}

final List<Widget> _adminPages = [
  AdminHome(),
  Profile(),
];
const List<BottomNavigationBarItem> adminBottomNavBarItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.person),
    label: 'Profile',
  ),
];
final List<Widget> _userPages = [
  Home(), //*Replace the Scaffold to more appropriate page for handling undefined role
  QRScan(),
  Profile(),
];
const List<BottomNavigationBarItem> userBottomNavBarItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.qr_code),
    label: 'QR',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.person),
    label: 'Profile',
  ),
];
