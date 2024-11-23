import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trash_bin_app/model/globals.dart' as global;
import 'dart:convert';
class UserInfoPage extends StatelessWidget {
  UserInfoPage({super.key});

  final DataTableSource _data = MyData();
  final userId = global.user_id;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Users')),
      body: Column(
        children: [
          PaginatedDataTable(
            columns: const [
              DataColumn(label: Text('First Name')),
              DataColumn(label: Text('Last Name')),
              DataColumn(label: Text('Address')),
              DataColumn(label: Text('Birthday')),
            ], 
            header: const Text('User Information'),
            columnSpacing: 100,
            horizontalMargin: 10,
            source: _data,
            )
        ],
      )
    );
  }
}

class MyData extends DataTableSource {
  List<Map<String, dynamic>> _data = [];

  // Fetch user data from the API
  Future<void> fetchData(String userId) async {
    final userId = global.user_id;
    final url = Uri.parse('https://trash-bin-api.vercel.app/user/all?user_id=$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        _data = List<Map<String, dynamic>>.from(jsonData.map((user) => {
              "first_name": user['first_name'],
              "last_name": user['last_name'],
              "address": user['address'],
              "birthday": user['birthday'],
            }));
        notifyListeners(); // Notify listeners to update the UI
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final user = _data[index];
    return DataRow(cells: [
      DataCell(Text(user['first_name'])),
      DataCell(Text(user['last_name'])),
      DataCell(Text(user['address'])),
      DataCell(Text(user['birthday'].toString())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0; // Adjust this if you implement selection
}