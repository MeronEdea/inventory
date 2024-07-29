import 'package:flutter/material.dart';
import 'screens/inventory_screen.dart';
import 'screens/rent_screen.dart';
import 'screens/renter_list_screen.dart';
import 'screens/history_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InventoryScreen(),
      routes: {
        '/rent': (context) => RentScreen(),
        '/renters': (context) => RenterListScreen(),
        '/history': (context) => HistoryScreen(),
      },
    );
  }
}
