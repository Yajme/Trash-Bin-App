import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trash_bin_app/model/globals.dart' as global;
import 'dart:convert';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final MyData _data = MyData();

  @override
  void initState() {
    super.initState();
    _data.fetchData(global.user_id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Transactions Records')),
      body: Column(
        children: [
          // Center the header
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Transactions Records',
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
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Points')),
                  DataColumn(label: Text('Date')),
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
    final url = Uri.parse('https://trash-bin-api.vercel.app/transaction/records?filter=all&user_id=$userId');
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
                "name": '${user['name']['first'] ?? 'Unknown'} ${user['name']['last'] ?? 'Name'}', // Use default value if null
                "points": user['points'] ?? '',   // Use default value if null
                "created_at": user['created_at']?.toString() ?? '', // Use default value if null
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
      DataCell(Text(user['name'])),
      DataCell(Text(user['points'].toString())),
      DataCell(Text(user['created_at'].toString())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0; // Adjust this if you implement selection
}