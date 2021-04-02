import 'package:ble_scanner/screens/scanner_page.dart';
import 'package:flutter/material.dart';


void main() {
  
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BLE Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScannerPage(),
    );
  }
}
