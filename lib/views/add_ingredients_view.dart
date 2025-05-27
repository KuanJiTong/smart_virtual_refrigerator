import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddIngredientsView extends StatefulWidget {
  final String? initialName;
  final String? imageUrl;

  const AddIngredientsView({this.initialName, this.imageUrl, super.key});

  @override
  _AddIngredientsViewState createState() => _AddIngredientsViewState();
}

class _AddIngredientsViewState extends State<AddIngredientsView> {
  final TextEditingController nameController = TextEditingController(text: 'Massimo Sandwich Loaf');
  final TextEditingController quantityController = TextEditingController(text: '12');
  final TextEditingController dateController = TextEditingController();

  bool hasExpiry = true;
  DateTime selectedDate = DateTime(2025, 4, 17);

  final List<String> categories = [
    'Bread',
    'Meat',
    'Vegetable',
    'Fruit',
    'Dairy',
    'Beverage',
    'Spice',
    'Grain',
    'Condiment',
  ];

  String selectedCategory = 'Bread';

  final Map<String, String> unitMapping = {
    'Bread': 'Slice',
    'Meat': 'Gram',
    'Vegetable': 'Gram',
    'Fruit': 'Piece',
    'Dairy': 'Milliliter',
    'Beverage': 'Milliliter',
    'Spice': 'Tablespoon',
    'Grain': 'Gram',
    'Condiment': 'Tablespoon',
  };

  @override
  void initState() {
    super.initState();
    nameController.text = widget.initialName ?? 'Massimo Sandwich Loaf';
    dateController.text = DateFormat('dd MMM yyyy').format(selectedDate);
    selectedCategory = categories.contains('Bread') ? 'Bread' : categories.first;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String quantityUnit = unitMapping[selectedCategory] ?? 'Unit';

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Ingredient"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: widget.imageUrl != null
                  ? Image.network(widget.imageUrl!, height: 180)
                  : Image.network('https://placehold.co/600x400', height: 180),
            ),
            SizedBox(height: 16),

            /// Name
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),

            /// Expire Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Expire", style: TextStyle(fontSize: 16)),
                Switch(
                  value: hasExpiry,
                  onChanged: (val) {
                    setState(() => hasExpiry = val);
                  },
                )
              ],
            ),
            SizedBox(height: 8),

            /// Expiration Date
            if (hasExpiry)
              TextFormField(
                controller: dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: "Expiration Date",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            SizedBox(height: 16),

            /// Quantity
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Quantity ($quantityUnit)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        int current = int.tryParse(quantityController.text) ?? 0;
                        quantityController.text = (current + 1).toString();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        int current = int.tryParse(quantityController.text) ?? 0;
                        if (current > 0) quantityController.text = (current - 1).toString();
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),

            /// Category Dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 32),

            /// Add Button
            ElevatedButton(
              onPressed: () {
                // Save to fridge action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                "Add to Fridge",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }
}

