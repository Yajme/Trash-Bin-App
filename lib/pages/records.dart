import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trash_bin_app/model/globals.dart' as global;
import 'dart:convert';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final MyData _data = MyData();

  @override
  void initState() {
    super.initState();
    _data.fetchData(global.user_id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Waste Recycled Records')),
      body: Column(
        children: [
          // Center the header
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Waste Recycle Records',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Wrap the PaginatedDataTable in a Card
          Expanded(
            child: Card(
              elevation: 4, // Add some elevation for a shadow effect
              margin: const EdgeInsets.all(16.0), // Margin around the card
              child: PaginatedDataTable(
                columns: const [
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Product Points')),
                  DataColumn(label: Text('Total Price')),
                  DataColumn(label: Text('User')),
                ],
                columnSpacing: 100,
                horizontalMargin: 10,
                source: _data,
                rowsPerPage: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyData extends DataTableSource {
  List<Map<String, dynamic>> _data = []; // Store user data

  // Fetch user data from the API
  Future<void> fetchData(String userId) async {
    String toSentenceCase(String text) {
      if (text.isEmpty) return text; // Return empty string if input is empty
      return text[0].toUpperCase() + text.substring(1).toLowerCase();
    }
    final url = Uri.parse('https://trash-bin-api.vercel.app/waste/records/all?user_id=$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic>? jsonData = jsonDecode(response.body);
        
        // Check if jsonData is null or empty
        if (jsonData == null || jsonData.isEmpty) {
          print('No data found');
          _data = []; // Assign empty list if no data
        } else {
          _data = List<Map<String, dynamic>>.from(jsonData.map((user) => {
                "category": toSentenceCase(user['category'] ?? ''), // Use default value if null
                "points": user['points'] ?? '',   // Use default value if null
                "name": '${user['name']['first'] ?? 'N/A'} ${user['name']['last'] ?? 'N/A'}', // Use default value if null
              }));
        }
        notifyListeners(); // Notify listeners to update the UI
      } else {
        print('Failed to load user data: ${response.statusCode}');
        _data = []; // Assign empty list if the response is not OK
        notifyListeners(); // Notify listeners to update the UI
      }
    } catch (e) {
      print('Error: $e');
      _data = []; // Assign empty list on error
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final user = _data[index];
    return DataRow(cells: [
      DataCell(Text(user['category'])),
      DataCell(Text(user['points'].toString())),
      DataCell(Text(user['points'].toString())),
      DataCell(Text(user['name'])),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0; // Adjust this if you implement selection
}