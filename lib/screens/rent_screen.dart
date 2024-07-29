import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/inventory_service.dart';
import '../models/item.dart';
import '../models/renter.dart';

class RentScreen extends StatefulWidget {
  @override
  _RentScreenState createState() => _RentScreenState();
}

class _RentScreenState extends State<RentScreen> {
  final InventoryService _inventoryService = InventoryService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _rentDateController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();

  bool _isLoading = true;
  List<Item> _items = [];
  Map<String, TextEditingController> _quantityControllers = {};
  DateTime? _rentDate;
  DateTime? _returnDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Item> items = await _inventoryService.loadItems();
    setState(() {
      _items = items;
      _isLoading = false;
      for (var item in _items) {
        _quantityControllers[item.name] = TextEditingController();
      }
    });
  }

  Future<void> _saveRenter() async {
  if (_formKey.currentState!.validate()) {
    Map<String, int> selectedItems = {};
    _quantityControllers.forEach((itemName, controller) {
      int quantity = int.tryParse(controller.text) ?? 0;
      if (quantity > 0) {
        selectedItems[itemName] = quantity;
      }
    });

    Renter renter = Renter(
      name: _nameController.text,
      phone: _phoneController.text,
      rentDate: _rentDate!,
      returnDate: _returnDate!,
      rentedItems: selectedItems,
    );

    try {
      await _inventoryService.saveRenter(renter);
      Navigator.pop(context);
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(e.toString()),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent Items'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _rentDateController,
                      decoration: const InputDecoration(
                        labelText: 'Rent Date',
                        hintText: 'mm/dd/yyyy',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a rent date';
                        }
                        return null;
                      },
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (date != null) {
                          setState(() {
                            _rentDate = date;
                            _rentDateController.text = DateFormat.yMd().format(date);
                          });
                        }
                      },
                    ),
                    TextFormField(
                      controller: _returnDateController,
                      decoration: const InputDecoration(
                        labelText: 'Return Date',
                        hintText: 'mm/dd/yyyy',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a return date';
                        }
                        return null;
                      },
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (date != null) {
                          setState(() {
                            _returnDate = date;
                            _returnDateController.text = DateFormat.yMd().format(date);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Items to Rent:', style: TextStyle(fontSize: 16)),
                    ..._items.map((item) {
                      return TextFormField(
                        controller: _quantityControllers[item.name],
                        decoration: InputDecoration(labelText: '${item.name} (Available: ${item.availableQuantity})'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          int quantity = int.tryParse(value ?? '0') ?? 0;
                          if (quantity > item.availableQuantity) {
                            return 'Not enough available';
                          }
                          return null;
                        },
                      );
                    }),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveRenter,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
