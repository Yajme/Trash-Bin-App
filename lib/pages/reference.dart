import 'package:flutter/material.dart';
import 'package:trash_bin_app/model/globals.dart' as global;
import 'package:trash_bin_app/model/constants.dart';

class ReferencePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final referenceNumber = args['referenceNumber'];
    final redeemedAmount = args['redeemedAmount'];
    final remainingPoints = args['remainingPoints'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Redemption Receipt'),
        backgroundColor: Color.fromARGB(255, 125, 207, 58),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long,
                      size: 40, color: ColorTheme.primaryColor),
                  const SizedBox(height: 10),
                  const Text(
                    'Redemption succeed for',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    global.user?.name?.getFullName() ?? 'User',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Php $redeemedAmount',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ColorTheme.primaryColor),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'using your points',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text(
                    'Ref. No. $referenceNumber',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${DateTime.now().toString().split('.')[0]}', // Current date and time
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Amount Paid', 'Php $redeemedAmount'),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                            'Remaining Points', 'Php $remainingPoints'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTheme.accentColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.black54)),
        Text(value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
