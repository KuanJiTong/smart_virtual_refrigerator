import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../viewmodels/add_ingredients_viewmodel.dart';
import 'add_ingredients_barcode_view.dart';
import 'fridge_page.dart';
import 'home_page.dart';

class AddIngredientsView extends StatefulWidget {
  final String? initialName;
  final String? imageUrl;

  const AddIngredientsView({this.initialName, this.imageUrl, super.key});

  @override
  _AddIngredientsViewState createState() => _AddIngredientsViewState();
}

class _AddIngredientsViewState extends State<AddIngredientsView> {
  final TextEditingController nameController = TextEditingController(text: 'Ingredient Name');
  final TextEditingController quantityController = TextEditingController(text: '10');
  final TextEditingController dateController = TextEditingController();

  bool hasExpiry = true;
  DateTime selectedDate = DateTime.now().add(Duration(days: 7));
  File? _pickedImage;

  final List<String> categories = [
    'Bread', 'Meat', 'Vegetable', 'Fruit', 'Dairy', 'Beverage', 'Spice', 'Grain', 'Condiment',
  ];

  String selectedCategory = 'Bread';

  final Map<String, String> unitMapping = {
    'Bread': 'Slice', 'Meat': 'Gram', 'Vegetable': 'Gram', 'Fruit': 'Piece',
    'Dairy': 'Milliliter', 'Beverage': 'Milliliter', 'Spice': 'Tablespoon',
    'Grain': 'Gram', 'Condiment': 'Tablespoon',
  };

  @override
  void initState() {
    super.initState();
    nameController.text = widget.initialName ?? 'Massimo Sandwich Loaf';
    dateController.text = DateFormat('dd MMM yyyy').format(selectedDate);
    selectedCategory = categories.contains('Bread') ? 'Bread' : categories.first;
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String quantityUnit = unitMapping[selectedCategory] ?? 'Unit';
    final ingredientVM = Provider.of<AddIngredientViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Ingredient"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddIngredientsBarcodeView())),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: _pickedImage != null
                  ? Image.file(_pickedImage!, height: 180)
                  : widget.imageUrl != null
                  ? Image.network(widget.imageUrl!, height: 180)
                  : Column(
                children: [
                  Image.network(
                    'https://imageplaceholder.net/150x150',
                    height: 180,
                  ),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.upload),
                    label: Text("Upload Image"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Name
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),

            // Expire Switch
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

            // Expiration Date
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

            // Quantity
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

            // Category
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

            // Add Button
            ElevatedButton(
              onPressed: () async {
                ingredientVM.updateName(nameController.text);
                ingredientVM.updateCategory(selectedCategory);
                ingredientVM.updateQuantity(quantityController.text);
                ingredientVM.toggleExpiry(hasExpiry);
                if (hasExpiry) {
                  ingredientVM.updateExpirationDate(selectedDate);
                }

                // If image is picked locally, you'd want to upload it first and get the URL
                if (_pickedImage != null) {
                  // You need to implement your own image upload logic and get the imageUrl
                  String uploadedImageUrl = await ingredientVM.uploadPickedImageToFirebase(_pickedImage!);
                  ingredientVM.setImage(uploadedImageUrl);
                } else {
                  ingredientVM.setImage(widget.imageUrl ?? 'https://imageplaceholder.net/150x150');
                }

                await ingredientVM.addIngredientToFirebase();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ingredient added to fridge')),
                );

                Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 2)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text("Add to Fridge", style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
