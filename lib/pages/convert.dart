import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trash_bin_app/model/globals.dart' as global;

class ConvertWaste extends StatefulWidget{

ConvertWaste({super.key});

@override
  State<ConvertWaste> createState() => _StateConvertWaste();

}

class _StateConvertWaste extends State<ConvertWaste>{
//String qrcode ='';
  @override
  void initState() {
    super.initState();

    // Delay accessing the arguments until after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      print(args['qrcode']);
      await fetchData(args['qrcode']);
    });
  }

  Future<void> fetchData(String qrcode) async {
    try{
    final url = 'https://trash-bin-api.vercel.app/waste/scan?qrcode=$qrcode&user_id=${global.user_id}';
    final response = await http.get(Uri.parse(url));
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      print(data);
    }
    }catch(error){
      print(error);
    }
  }
@override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: Text('Convert Waste'),),
      body: Container(
        child: Padding(
          padding : EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text('QR Code Scanned!', style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(height: 30,),
               Text('You can now exit this page', style: TextStyle(fontWeight: FontWeight.w500),),
            ],
          ),
        ),
      ),
    );
  }
}