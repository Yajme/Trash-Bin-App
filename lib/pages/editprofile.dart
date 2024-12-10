import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:trash_bin_app/model/globals.dart' as global;

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with current user data
    firstNameController.text = global.user!.name!.getFirstName();
    lastNameController.text = global.user!.name!.getLastName();
    birthdayController.text = global.user!.birthday;
    addressController.text = global.user!.address;
    _loadUserData();
  }

  void _loadUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(global.user_id).get();
    if (userDoc.exists) {
      firstNameController.text = userDoc['first_name'] ?? '';
      lastNameController.text = userDoc['last_name'] ?? '';
      birthdayController.text = DateFormat('M/d/yyyy').format((userDoc['birthday'] as Timestamp).toDate());
      addressController.text = userDoc['address'] ?? '';
    }
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    firstNameController.dispose();
    lastNameController.dispose();
    birthdayController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthday(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        // Format date as needed, e.g., mm/dd/yyyy
        birthdayController.text = DateFormat('M/d/yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _saveChanges() async {
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;

    Map<String, dynamic> data = {
      'first_name': firstName,
      'last_name': lastName,
      'address': addressController.text,
      'birthday': Timestamp.fromDate(_parseDate(birthdayController.text)), // Convert to Firestore Timestamp
      'user': FirebaseFirestore.instance.collection('users').doc(global.user_id), // Reference to users collection
    };

    try {
      // Check if user document exists
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(global.user_id).get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User document not found.')));
        return;
      }

      // Check for existing user information
      QuerySnapshot userInfoSnapshot = await FirebaseFirestore.instance.collection('user_information').where('user', isEqualTo: userDoc.reference).get();

      if (userInfoSnapshot.docs.isNotEmpty) {
        String userInfoId = userInfoSnapshot.docs[0].id;

        await FirebaseFirestore.instance.collection('user_information').doc(userInfoId).update(data);

        // Successfully updated, navigate back and refresh
        Navigator.pop(context, true); // Pass true to indicate changes were made
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User information not found.')));
      }
    } catch (e) {
      print('Error updating user information: $e'); // Log error details
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  DateTime _parseDate(String dateStr) {
    try {
      DateFormat format = DateFormat("M/d/yyyy"); // Adjust format as needed
      return format.parseStrict(dateStr); // Use parseStrict for strict validation
    } catch (e) {
      print('Error parsing date: $e');
      throw FormatException('Invalid date format'); // Handle invalid format
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            GestureDetector(
              onTap: () => _selectBirthday(context), // Open date picker on tap
              child: AbsorbPointer( // Prevent keyboard from showing
                child: TextField(
                  controller: birthdayController,
                  decoration: InputDecoration(labelText: 'Birthday'),
                ),
              ),
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges, // Call save changes method on button press
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}