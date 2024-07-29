import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/inventory_service.dart';
import '../models/renter.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final InventoryService _inventoryService = InventoryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Renter>>(
        future: _inventoryService.loadHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No history available.'));
          }
          List<Renter> history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              Renter renter = history[index];
              String rentedItemsText = renter.rentedItems.entries
                  .map((entry) => '${entry.key} (${entry.value})') // Change entry.key to entry.key.name if necessary
                  .join(', ');

              return ListTile(
                title: Text(renter.name),
                subtitle: Text(
                    'Phone: ${renter.phone}\nRented Items: $rentedItemsText\nRent Date: ${DateFormat.yMd().format(renter.rentDate)}\nReturn Date: ${DateFormat.yMd().format(renter.returnDate)}'),
              );
            },
          );
        },
      ),
    );
  }
}
