import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item.dart';
import '../models/renter.dart';

class InventoryService {
  static const String _itemsKey = 'items';
  static const String _rentersKey = 'renters';
  static const String _historyKey = 'history';

  Future<List<Item>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> itemsList = prefs.getStringList(_itemsKey) ?? [];
    return itemsList.map((item) => Item.fromJson(jsonDecode(item))).toList();
  }

  Future<void> saveItems(List<Item> items) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> itemsList =
        items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_itemsKey, itemsList);
  }

  Future<void> addItem(String name, int totalQuantity) async {
    List<Item> items = await loadItems();
    Item existingItem = items.firstWhere(
      (item) => item.name == name,
      orElse: () => Item(name: name, totalQuantity: 0, availableQuantity: 0),
    );

    if (existingItem.totalQuantity == 0) {
      items.add(Item(
          name: name,
          totalQuantity: totalQuantity,
          availableQuantity: totalQuantity));
    } else {
      existingItem.totalQuantity += totalQuantity;
      existingItem.availableQuantity += totalQuantity;
    }

    await saveItems(items);
  }

  Future<List<Renter>> loadRenters() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> rentersList = prefs.getStringList(_rentersKey) ?? [];
    return rentersList
        .map((renter) => Renter.fromJson(jsonDecode(renter)))
        .toList();
  }

  Future<void> saveRenter(Renter renter) async {
  bool isAvailable = await checkItemAvailability(renter.rentedItems, renter.rentDate, renter.returnDate);
  if (!isAvailable) {
    // Handle the case where items are not available
    throw Exception("Items not available for the selected dates.");
  }

  final prefs = await SharedPreferences.getInstance();
  List<String> rentersList = prefs.getStringList(_rentersKey) ?? [];
  rentersList.add(jsonEncode(renter.toJson()));
  await prefs.setStringList(_rentersKey, rentersList);

  // Update item quantities
  List<Item> currentItems = await loadItems();
  for (var entry in renter.rentedItems.entries) {
    Item existingItem = currentItems.firstWhere(
      (i) => i.name == entry.key,
      orElse: () => Item(name: entry.key, totalQuantity: 0, availableQuantity: 0),
    );

    existingItem.availableQuantity -= entry.value;
    // Ensure that availableQuantity does not go negative
    if (existingItem.availableQuantity < 0) {
      existingItem.availableQuantity = 0;
    }
  }
  await saveItems(currentItems);
}


  Future<void> returnItems(Renter renter) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> rentersList = prefs.getStringList(_rentersKey) ?? [];
    rentersList.removeWhere(
      (r) => Renter.fromJson(jsonDecode(r)).name == renter.name,
    );
    await prefs.setStringList(_rentersKey, rentersList);

    // Update item quantities
    await _updateItemQuantities();

    // Save to history
    List<String> historyList = prefs.getStringList(_historyKey) ?? [];
    historyList.add(jsonEncode(renter.toJson()));
    await prefs.setStringList(_historyKey, historyList);
  }

  Future<void> _updateItemQuantities() async {
    List<Renter> renters = await loadRenters();
    List<Item> items = await loadItems();

    // Reset available quantities
    for (var item in items) {
      item.availableQuantity = item.totalQuantity;
    }
    DateTime today = DateTime.now();

    // Deduct rented quantities based on date
    for (var renter in renters) {
      if (renter.returnDate.isAfter(today)) {
        for (var entry in renter.rentedItems.entries) {
          Item existingItem = items.firstWhere(
            (i) => i.name == entry.key,
            orElse: () =>
                Item(name: entry.key, totalQuantity: 0, availableQuantity: 0),
          );
          if (existingItem.totalQuantity != 0) {
            existingItem.availableQuantity -= entry.value;
          }
        }
      }
    }
    await saveItems(items);
  }

  Future<List<Renter>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyList = prefs.getStringList(_historyKey) ?? [];
    return historyList
        .map((history) => Renter.fromJson(jsonDecode(history)))
        .toList();
  }

  Future<bool> checkItemAvailability(Map<String, int> requestedItems, DateTime rentDate, DateTime returnDate) async {
  List<Renter> renters = await loadRenters();
  List<Item> items = await loadItems();

  for (var entry in requestedItems.entries) {
    String itemName = entry.key;
    int requestedQuantity = entry.value;

    int totalBooked = 0;

    for (var renter in renters) {
      // Check if there is any overlap in the rental periods
      bool overlap = renter.rentDate.isBefore(returnDate) && renter.returnDate.isAfter(rentDate);
      if (overlap && renter.rentedItems.containsKey(itemName)) {
        totalBooked += renter.rentedItems[itemName]!;
      }
    }

    Item existingItem = items.firstWhere(
      (i) => i.name == itemName,
      orElse: () => Item(name: itemName, totalQuantity: 0, availableQuantity: 0),
    );

    if (totalBooked + requestedQuantity > existingItem.totalQuantity) {
      return false;
    }
  }

  return true;
}


}
