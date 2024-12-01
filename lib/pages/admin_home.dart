import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:trash_bin_app/model/globals.dart' as global;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminHome extends StatefulWidget {
  @override
  State<AdminHome> createState() => _StateHome();
}

class _StateHome extends State<AdminHome> {
  String firstName = '';
  String lastName = '';
  String _dateString = '';
  String _locationString = 'Fetching location...';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _updateDate();
    _getLocation();
  }

  void _updateDate() {
    // Update the date every minute
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      setState(() {
        _dateString = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
      });
    });
  }

  Future<void> _getLocation() async {
    // Request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, // Set the desired accuracy
          distanceFilter: 10, // Optional: Set the distance filter
        ),
      );
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];

      setState(() {
        _locationString =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}"; // Detailed address
      });
    } else {
      setState(() {
        _locationString = 'Location access denied';
      });
    }
  }

  Future<void> _fetchUserData() async {
    final userId = global.user_id;
    final url =
        Uri.parse('https://trash-bin-api.vercel.app/user/all?user_id=$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          firstName =
              data['first_name'] ?? 'Admin'; // Default to 'Admin' if null
          lastName = data['last_name'] ?? '';
        });
      } else {
        print('Failed to load user data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildCard({
    required String title, 
    required String subtitle, 
    required IconData icon,
    required VoidCallback onTap, 
    }) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.9,
    height: 150,
    child: InkWell(
      onTap: onTap,
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center the icon vertically
                children: [
                  Icon(icon, size: 72.0),
                  const SizedBox(height: 8, width: 100,), // Space between the icon and the text
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 4), // Space between title and subtitle
                    Text(subtitle),
                  ],
                ),
              ),
              const Center(child: Icon(Icons.navigate_next_rounded, size: 30.0)),
            ],
          ),
        ),
      ),
    ),
  );
}


  final userId = global.user_id;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: const Color(0xFF8DA45D),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _dateString.isNotEmpty ? _dateString : 'Fetching date...',
              style: const TextStyle(fontSize: 12),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 5),
                Text(
                  _locationString,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Hi Admin!,',
              style: TextStyle(fontSize: 20),
            ),
            const Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildCard(
                    title: 'View Records',
                    subtitle: 'View all user records of recycled materials',
                    icon: FontAwesomeIcons.solidFileLines,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/records',
                      );
                    },
                  ),
                  _buildCard(
                    title: 'View Transactions',
                    subtitle: 'View all user transactions of redeemed points',
                    icon: FontAwesomeIcons.cashRegister,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/transactions',
                      );
                    },
                  ),
                  _buildCard(
                    title: 'View Users',
                    subtitle: 'View all Registered User Information',
                    icon: Icons.people,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/users_info',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
