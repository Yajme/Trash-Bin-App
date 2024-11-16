import 'package:flutter/material.dart';
import 'package:trash_bin_app/model/globals.dart' as global;
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _StateHome();
}

class _StateHome extends State<Home> {
  final String userId = global.user_id;
  String largestCategory = "";
  double largestPoint = 0.0;
  double recentPoints = 0.0;
  double currentPoints = 0.0;

  @override
  void initState() {
    super.initState();
    getWasteRecords();
  }

  Future<void> getWasteRecords() async {
    final userId = global.user_id; // Ensure this is set correctly
    if (userId == null) {
      print('Error: userId is null.');
      return;
    }

    final url = Uri.parse(
        'https://trash-bin-api.vercel.app/waste/records?user_id=$userId');
    print('Fetching data from: $url');

    try {
      final response = await http.get(url);
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Decode the response body as a List
        final List<dynamic> dataList = json.decode(response.body);

        if (dataList.isNotEmpty) {
          // Example to calculate the required fields
          String largestCategory = "N/A";
          double largestPoint = 0.0;
          double recentPoints = 0.0;
          double currentPoints = 0.0;

          // Process data to calculate required values
          for (var record in dataList) {
            if (record['points'] is num &&
                (record['points'] as num).toDouble() > largestPoint) {
              largestPoint = (record['points'] as num).toDouble();
              largestCategory = record['category'];
            }
            recentPoints += (record['points'] as num?)?.toDouble() ?? 0.0;
          }
          currentPoints =
              recentPoints; // Adjust logic for current points if necessary

          if (mounted) {
            setState(() {
              this.largestCategory = largestCategory;
              this.largestPoint = largestPoint;
              this.recentPoints = recentPoints;
              this.currentPoints = currentPoints;
            });
            print('Data fetched and updated successfully.');
          }
        } else {
          print('No records found.');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No records found.')),
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

  final name = global.user?.name?.getFullName();
  final double availablePoints = 100.32; // Example available points
  final TextEditingController _pointsController = TextEditingController();

  void _showRedeemPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Redeem Points'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You are about to redeem your points. Enter the amount below:',
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Points to Redeem',
                  hintText: 'Enter points',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final input = _pointsController.text;
                if (input.isEmpty) {
                  _showError('Please enter a valid number.');
                  return;
                }

                final points = double.tryParse(input);
                if (points == null || points <= 0) {
                  _showError('Please enter a valid number greater than zero.');
                  return;
                }

                if (points > availablePoints) {
                  _showError('You cannot redeem more points than available.');
                  return;
                }

                // Redeem request logic
                _redeemPoints(points);
              },
              child: const Text('Redeem'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _redeemPoints(double points) async {
    try {
      final response = await http.post(
        Uri.parse('https://trash-bin-api.vercel.app/transaction/redeem'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': points,
          'user_id': global.user_id, // Use global.user_id here
        }),
      );

      print('Response status: ${response.statusCode}');
      print(
          'Response body: ${response.body}'); // Log the response body for debugging

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print(
            'Parsed Response Data: $data'); // Log the parsed response data for further debugging
        _showSuccessDialog('Successfully redeemed $points points!');
      } else if (response.statusCode == 500) {
        final errorData = json.decode(response.body);
        String errorMessage =
            errorData['message'] ?? 'Internal server error occurred';
        _showErrorDialog('Server Error: $errorMessage');
      } else {
        _showErrorDialog(
            'Failed to contact server. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: const Color(0xFF8DA45D),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tuesday, November 19, 2024',
              style: TextStyle(fontSize: 12),
            ),
            Row(
              children: [
                Icon(Icons.location_on, size: 16),
                SizedBox(width: 5),
                Text(
                  'Pinagkawitan, Lipa',
                  style: TextStyle(fontSize: 12),
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
              'Hi $name,',
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
                      'PHP $currentPoints',
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
                const IconLabel(icon: Icons.list_alt, label: 'Records'),
                const IconLabel(icon: Icons.sync_alt, label: 'Transfer'),
                IconLabel(
                  icon: Icons.redeem,
                  label: 'Redeem',
                  onTap: _showRedeemPopup,
                ),
                const IconLabel(icon: Icons.swap_horiz, label: 'Convert'),
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 32, color: const Color(0xFF8DA45D)),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
