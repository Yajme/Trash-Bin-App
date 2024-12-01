import 'package:flutter/material.dart';
import 'package:trash_bin_app/model/globals.dart' as global;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
class Home extends StatefulWidget {
  @override
  State<Home> createState() => _StateHome();
}

class _StateHome extends State<Home> {
  final String userId = global.user_id;
  String largestCategory = "Loading...";
  double largestPoint = 0.0;
  double recentPoints = 0.0;
  double currentPoints = 0.0;
  String _dateString = '';
  String _locationString = 'Fetching location...';
  //Timer? _timer;
  @override
  void initState() {
    super.initState();
    getWasteRecords();
    _updateDate();
     _getLocation();
  }
 void _updateDate() {
    // Update the date every minute
    
      setState(() {
        _dateString = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
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
  Future<void> getWasteRecords() async {
    final userId = global.user_id;
    if (userId == '' || userId.isEmpty) {
      print('Error: userId is null.');
      return;
    }

    final url = Uri.parse(
        'https://trash-bin-api.vercel.app/waste/dashboard?user_id=$userId');
    print('Fetching data from: $url');

    try {
      final response = await http.get(url);
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          String fetchedLargestCategory = data['largest_category'] ?? "N/A";
          double fetchedLargestPoint =
              (data['largest_point'] as num?)?.toDouble() ?? 0.0;
          double fetchedRecentPoints =
              (data['recent_points'] as num?)?.toDouble() ?? 0.0;
          double fetchedCurrentPoints =
              (data['current_points'] as num?)?.toDouble() ?? 0.0;

          if (mounted) {
            setState(() {
              largestCategory = fetchedLargestCategory;
              largestPoint = fetchedLargestPoint;
              recentPoints = fetchedRecentPoints;
              currentPoints = fetchedCurrentPoints;
            });
            print('Data fetched and updated successfully.');
          }
        } else {
          print('No data found in the response.');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No data found.')),
            );
          }
        }
      } else {
        print('Failed to fetch records. Status code: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to fetch records: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      print('Error occurred: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred: $e')),
        );
      }
    }
  }

  void navigateToPage(String route){
    Navigator.pushNamed(context, route);
  }
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
              _dateString,
              style: TextStyle(fontSize: 12),
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
              'Hi ${global.user?.name?.getFullName() ?? "User"},',
              style: const TextStyle(fontSize: 20),
            ),
            const Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Points',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'PHP ${currentPoints.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CategoryInfo(
                          label: largestCategory,
                          value: 'Largest Category',
                        ),
                        CategoryInfo(
                          label: recentPoints.toStringAsFixed(2),
                          value: 'Recent Points',
                        ),
                        CategoryInfo(
                          label: largestPoint.toStringAsFixed(2),
                          value: 'Largest Amount',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconLabel(icon: Icons.list_alt, label: 'Records', onTap: (){
                  navigateToPage('/records');
                },),
                IconLabel(icon: Icons.receipt_long, label: 'Transfer',onTap:(){
                  navigateToPage('/transactions');
                }),
                IconLabel(
                  icon: Icons.redeem,
                  label: 'Redeem',
                  onTap: (){
                    navigateToPage('/redeem');
                  },
                ),
                IconLabel(icon: Icons.restore_from_trash, label: 'Convert',onTap: (){
                  navigateToPage('/convert');
                },),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryInfo extends StatelessWidget {
  final String label;
  final String value;

  const CategoryInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8DA45D),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const IconLabel({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          IconButton(onPressed: onTap, icon: Icon(icon, size: 32, color: const Color(0xFF8DA45D))),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
  }
}
