import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/inventory_service.dart';
import '../models/renter.dart';

class RenterListScreen extends StatefulWidget {
  @override
  _RenterListScreenState createState() => _RenterListScreenState();
}

class _RenterListScreenState extends State<RenterListScreen> {
  final InventoryService _inventoryService = InventoryService();
  List<Renter> _renters = [];

  @override
  void initState() {
    super.initState();
    _loadRenters();
  }

  Future<void> _loadRenters() async {
    List<Renter> renters = await _inventoryService.loadRenters();
    setState(() {
      _renters = renters;
    });
  }

  Future<void> _onReturn(Renter renter) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Return'),
          content: Text('Are you sure you want to return the items rented by ${renter.name}?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _inventoryService.returnItems(renter);
      _loadRenters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rentee List'),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Rent Items'),
              onTap: () {
                Navigator.pushNamed(context, '/rent');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Rentee List'),
              onTap: () {
                Navigator.pushNamed(context, '/renters');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.pushNamed(context, '/history');
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _renters.length,
        itemBuilder: (context, index) {
          Renter renter = _renters[index];
          String rentedItemsText = renter.rentedItems.entries
              .map((entry) => '${entry.key} (${entry.value})')
              .join(', ');

          return ListTile(
            title: Text(renter.name),
            subtitle: Text(
                'Phone: ${renter.phone}\nRented Items: $rentedItemsText\nRent Date: ${DateFormat.yMd().format(renter.rentDate)}\nReturn Date: ${DateFormat.yMd().format(renter.returnDate)}'),
            trailing: IconButton(
              icon: const Icon(Icons.reply),
              onPressed: () => _onReturn(renter),
            ),
          );
        },
      ),
    );
  }
}
