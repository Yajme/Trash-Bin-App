import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trash_bin_app/model/globals.dart' as global;
import 'package:trash_bin_app/model/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _StateLogin();
}

class _StateLogin extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Username and password cannot be empty';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('https://trash-bin-api.vercel.app/user/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'token': global.token,
        }),
      );

      if (response.statusCode == 200) {
        // Login successful
        final responseData = jsonDecode(response.body);

        // Set global role and user_id and everything else
        await setGlobals(responseData);

        print('Login successful: ${responseData['message']}');
        await setGlobals(responseData);

      } else {
        // Login failed
        final errorData = jsonDecode(response.body);
        setState(() {
          _errorMessage = errorData['message'] ?? 'Login failed';
        });
      }
    } catch (error, stack) {
      setState(() {
        _errorMessage = 'An error occurred: $error ';
        print(stack);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future setGlobals(dynamic data) async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      global.role = data['role'];
      global.user_id = data['user_id'];

      // Cache these values
      pref.setBool('isLoggedIn', true);
      pref.setString('role', global.role);
      pref.setString('user_id', global.user_id);
      pref.setString('token', global.token);

      // Set default user values even for non-'user' roles
      if (data['role'] == 'user') {
        final name = global.Name(
            first: data['name']['first'], last: data['name']['last']);
        global.user = global.User(
          address: data['address'],
          birthday: data['birthday'],
          name: name,
        );
        pref.setString('user', jsonEncode(global.user!.toJson()));
      } else {
        // Set global.user with some default values for other roles
        final name = global.Name(first: 'Admin', last: 'User');
        global.user = global.User(
          address: 'N/A',
          birthday: 'N/A',
          name: name,
        );
        pref.setString('user', jsonEncode(global.user!.toJson()));
      }
    });
    changePage();
  }

  void changePage() {
    if (global.role == 'user') {
      Navigator.pushReplacementNamed(context, '/user');
    }
    if (global.role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.secondaryColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Trash 2 Cash',
                style: TextStyle(
                  fontSize: 32.0,
                  color: Color.fromARGB(255, 0, 0, 0),
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
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        filled: true,
                        fillColor: Colors.yellow[100],
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 12.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.yellow[100],
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 12.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Show error message if login fails
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14.0,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                      child: const Text(
                        'Don’t have an account? Register',
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
}
