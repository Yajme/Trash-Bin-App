// API Link: https://trash-bin-api.vercel.app/user/register
// Parameters to be sent: username,password,first name, last name, address, birthday
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trash_bin_app/pages/login.dart';

void main() {
  runApp(const Trash2CashApp());
}

class Trash2CashApp extends StatelessWidget {
  const Trash2CashApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trash 2 Cash',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const RegistrationPage(),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  String? _selectedMonth;
  String? _selectedDay;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final address = _addressController.text.trim();
    final year = _yearController.text.trim();
    final month = _selectedMonth;
    final day = _selectedDay;

    if (username.isEmpty ||
        password.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        address.isEmpty ||
        month == null ||
        day == null ||
        year.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please fill out all fields.';
      });
      return;
    }

    final birthday = '$year-${month.padLeft(2, '0')}-${day.padLeft(2, '0')}';

    final url = Uri.parse('https://trash-bin-api.vercel.app/user/register');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'username': username,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'birthday': birthday,
      'role': 'user', // Add the default role here
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Debugging: Print the response status code and body for debugging purposes
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(responseData['message'] ?? 'Registration Successful!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          // Print the error message for debugging
          print('Error Response: ${responseData['error']}');
          _errorMessage =
              responseData['error'] ?? 'Registration failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Trash 2 Cash',
                style: TextStyle(
                  fontSize: 32.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.greenAccent[700],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    _buildTextField('Username', _usernameController),
                    const SizedBox(height: 15.0),
                    _buildTextField('Password', _passwordController,
                        obscureText: true),
                    const SizedBox(height: 15.0),
                    _buildTextField('First Name', _firstNameController),
                    const SizedBox(height: 15.0),
                    _buildTextField('Last Name', _lastNameController),
                    const SizedBox(height: 15.0),
                    Row(
                      children: [
                        _buildDropdownField(
                            'MM', 12, (value) => _selectedMonth = value),
                        const SizedBox(width: 10.0),
                        _buildDropdownField(
                            'DD', 31, (value) => _selectedDay = value),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: _buildTextField('YYYY', _yearController),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    _buildTextField('Address', _addressController),
                    const SizedBox(height: 20.0),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14.0),
                      ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[900],
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'REGISTER',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'Already have account? Login',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Color.fromARGB(255, 255, 255, 255),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.yellow[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      String label, int count, void Function(String?) onChanged) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.yellow[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
        items: List.generate(
          count,
          (index) => DropdownMenuItem(
            value: (index + 1).toString(),
            child: Text((index + 1).toString().padLeft(2, '0')),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
