import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trash_bin_app/model/globals.dart' as global;
import 'package:trash_bin_app/model/constants.dart';

class RedemptionPage extends StatefulWidget {
  @override
  _RedemptionPageState createState() => _RedemptionPageState();
}

class _RedemptionPageState extends State<RedemptionPage> {
  final TextEditingController _pointsController = TextEditingController();
  double currentPoints = 100.0;

  Future<void> _redeemPoints(double points) async {
    try {
      final response = await http.post(
        Uri.parse('https://trash-bin-api.vercel.app/transaction/redeem'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': points,
          'user_id': global.user_id,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
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

  void _redeem() {
    final input = _pointsController.text;
    if (input.isEmpty) {
      _showErrorDialog('Please enter a valid number.');
      return;
    }

    final points = double.tryParse(input);
    if (points == null || points <= 0) {
      _showErrorDialog('Please enter a valid number greater than zero.');
      return;
    }

    if (points > currentPoints) {
      _showErrorDialog('You cannot redeem more points than available.');
      return;
    }

    _redeemPoints(points);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color is white now
      appBar: AppBar(
        backgroundColor: Colors.white, // Matches the page color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.black), // Icon color to match
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/user'); // Navigate back
          },
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: ColorTheme.primaryColor, // Inner green color
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Points Redemption',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color:
                      Colors.white, // Text color matches the green background
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter points you want to redeem:',
                style: TextStyle(
                    fontSize: 16, color: Colors.white), // Text color is white
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white, // Input box color remains white
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  hintText: 'Enter points',
                  hintStyle:
                      const TextStyle(color: Colors.black54), // Hint text color
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _redeem,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      ColorTheme.accentColor, // Dark green button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  'REDEEM',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
