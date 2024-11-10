import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trash_bin_app/api/firebase_api.dart';
import 'package:trash_bin_app/pages/home.dart';
import 'package:trash_bin_app/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trash_bin_app/model/constants.dart';

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
    options:  FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? "", 
      appId: dotenv.env['FIREBASE_APP_ID'] ?? "", 
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? "", 
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? ""
      ),
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
  bool isLoggedIn = true;
  @override
  void initState() {
    super.initState();
    //! InitPref() is commented out for development purposes
    //initPref();
  }

  Future initPref() async{
    final pref = await SharedPreferences.getInstance();

    setState(() {
      isLoggedIn = pref.getBool('isLoggedIn') ?? false;
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
          iconTheme: IconThemeData(color: ColorTheme.textColor['option 2'])
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: ColorTheme.accentColor,
            unselectedItemColor: Colors.grey
          ),
      ),
      debugShowCheckedModeBanner: false,
      //* If the [isLoggedIn] is set to true, the initial page will be set to the main page
      //* Otherwise the page will be redirected to login
      initialRoute: isLoggedIn ? '/main' : '/login',
      routes: {
        '/main' : (context) => const MainScaffolding(),
        '/login' : (context) =>Login(),
        //TODO: Add more routes here especially for admin
      },
    );
  }
}
class MainScaffolding extends StatefulWidget{
const MainScaffolding({super.key});
@override
  State<MainScaffolding> createState() => _StateMainScaffolding();
}

class _StateMainScaffolding extends State<MainScaffolding>{
int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
           resizeToAvoidBottomInset: false,
           body: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: bottomNavBarItems,
              currentIndex: _selectedIndex,
              //* Whenever an icon is pressed, the [index] of the bottomNavigation is set to [_selectedIndex] 
              //* which will change the page in the scaffolding
              //* The pages is based on the List of pages
              onTap: (index){
               setState(() {
                 _selectedIndex = index;
               });
              },
            )

    );
  }
}
 final List<Widget> _pages=[
      Home(),
      Home(), //TODO: Change to QR Page, also create a QR Page
      Home(), //TODO: Change to Profile Page
    ];
const List<BottomNavigationBarItem> bottomNavBarItems = [
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
