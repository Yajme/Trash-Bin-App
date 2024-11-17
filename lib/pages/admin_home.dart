import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:trash_bin_app/model/globals.dart' as global;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

//TODO : create home page
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
              data['first_name'] ?? 'Admin'; // Default to 'User' if null
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
            Text(
              'Hi Admin!,',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text(
              'Welcome to Back!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
