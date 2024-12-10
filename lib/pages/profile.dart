import 'package:flutter/material.dart';
import 'package:trash_bin_app/model/constants.dart';
import 'package:trash_bin_app/pages/editprofile.dart';
import 'package:trash_bin_app/model/globals.dart' as global;

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _StateProfile();
}

class _StateProfile extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildProfileOption(Icons.person, global.user!.name!.getFullName()),
            _buildProfileOption(Icons.cake, global.user!.birthday),
            _buildProfileOption(Icons.home, global.user!.address),
            const SizedBox(height: 20),
            _buildEditButton(context),
            const SizedBox(height: 20),
            _buildLogoutButton(context)
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorTheme.accentColor, ColorTheme.primaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          const Spacer(),
          Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                global.user!.name!.getFullName(),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: ColorTheme.primaryColor),
      title: Text(title),
    );
  }

  Widget _buildPasswordOption(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: ColorTheme.primaryColor),
      title: Text(title),
      trailing: Icon(Icons.visibility_off, color: Colors.grey),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton(
        onPressed: () {Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditProfilePage()),
        );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: ColorTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: Size(double.infinity, 50),
        ),
        child: Text('Edit profile', style: TextStyle(fontSize: 16)),
      ),
    );
  }
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton(
        onPressed: () {

          global.clearGlobals();
                    Navigator.popAndPushNamed(context, '/login');
        },
        style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
    backgroundColor: ColorTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: Size(double.infinity, 50),
        ),
        child:  const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.logout, size: 24, color: Colors.white), // Replace with your logo image
      SizedBox(width: 8), // Spacing between logo and text
      Text('Logout', style: TextStyle(fontSize: 16)),
    ],
  ),
      ),
    );
  }
}
