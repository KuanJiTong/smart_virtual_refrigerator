import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../viewmodels/add_ingredients_viewmodel.dart';
import '../viewmodels/update_ingredients_viewmodel.dart';
import 'fridge_page.dart';
import 'home_page.dart';

class UpdateIngredientsView extends StatefulWidget {
  final Map<String, dynamic> ingredient;

  const UpdateIngredientsView({super.key, required this.ingredient});

  @override
  _UpdateIngredientsViewState createState() => _UpdateIngredientsViewState();
}

class _UpdateIngredientsViewState extends State<UpdateIngredientsView> {
  bool _isLoading = false;
  late TextEditingController nameController;
  late TextEditingController quantityController;
  late TextEditingController dateController;

  bool hasExpiry = false;
  DateTime selectedDate = DateTime.now();
  File? _pickedImage;

  final List<String> categories = [
    'Bread', 'Meat', 'Vegetable', 'Fruit', 'Dairy', 'Beverage', 'Spice', 'Grain', 'Condiment',
  ];

  late String selectedCategory;

  final Map<String, String> unitMapping = {
    'Bread': 'Slice', 'Meat': 'Gram', 'Vegetable': 'Gram', 'Fruit': 'Piece',
    'Dairy': 'Milliliter', 'Beverage': 'Milliliter', 'Spice': 'Tablespoon',
    'Grain': 'Gram', 'Condiment': 'Tablespoon',
  };

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.ingredient['name'] ?? '');
    quantityController = TextEditingController(
      text: RegExp(r'\d+').stringMatch(widget.ingredient['quantity']) ?? '',
    );

    selectedCategory = widget.ingredient['category'] ?? categories.first;

    if (widget.ingredient['expiredDate'] != '') {
      hasExpiry = true;
      selectedDate = DateTime.parse(widget.ingredient['expiredDate']);
    }
    dateController = TextEditingController(
      text: hasExpiry ? DateFormat('dd MMM yyyy').format(selectedDate) : DateFormat('dd MMM yyyy').format(DateTime.now()),
    );
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

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String quantityUnit = unitMapping[selectedCategory] ?? 'Unit';
    final ingredientVM = Provider.of<UpdateIngredientsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Ingredient"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 2))),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Center(
                child: _pickedImage != null
                    ? Image.file(_pickedImage!, height: 150)
                    : widget.ingredient['image'] != ''
                    ? Image.network(widget.ingredient['image'], height: 150)
                    : Container(
                      height: 150,
                      width: 150,
                      color: Colors.grey[300],
                      child: const Icon(Icons.add_a_photo, size: 50),
                    ),
              ),
              Center(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(Icons.upload),
                      label: const Text("Upload Image"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
        
              // Name
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
        
              // Expiry Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Has Expiry", style: TextStyle(fontSize: 16)),
                  Switch(
                    value: hasExpiry,
                    onChanged: (val) {
                      setState(() => hasExpiry = val);
                    },
                  )
                ],
              ),
              const SizedBox(height: 8),
        
              // Expiry Date
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
              const SizedBox(height: 16),
        
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
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          int current = int.tryParse(quantityController.text) ?? 0;
                          quantityController.text = (current + 1).toString();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          int current = int.tryParse(quantityController.text) ?? 0;
                          if (current > 0) quantityController.text = (current - 1).toString();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
        
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
              const SizedBox(height: 32),
        
              // Update Button
              ElevatedButton(
                onPressed: () async {
                  setState(() => _isLoading = true);

                  try {
                    ingredientVM.updateName(nameController.text);
                    ingredientVM.updateCategory(selectedCategory);
                    ingredientVM.updateQuantity(quantityController.text);
                    ingredientVM.toggleExpiry(hasExpiry);

                    if (hasExpiry) {
                      ingredientVM.updateExpirationDate(selectedDate);
                    }

                    if (_pickedImage != null) {
                      String uploadedUrl = await ingredientVM.uploadPickedImageToFirebase(_pickedImage!);
                      ingredientVM.setImage(uploadedUrl);
                    } else {
                      ingredientVM.setImage(widget.ingredient['image'] ?? 'https://imageplaceholder.net/150x150');
                    }

                    await ingredientVM.updateIngredientInFirebase(widget.ingredient['id']);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ingredient updated successfully')),
                    );

                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 2)));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update ingredient: $e')),
                    );
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                child: const Text("Update Ingredient"),
              ),
              SizedBox(height: 5),
              ElevatedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: const Text('Are you sure you want to delete this ingredient? This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete', style: TextStyle(color: const Color(0xFFE85C5C))),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    setState(() => _isLoading = true);
                    try {
                      await ingredientVM.deleteIngredientFromFirebase(widget.ingredient['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ingredient deleted successfully')),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 2)),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete ingredient: $e')),
                      );
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE85C5C),
                ),
                child: const Text(
                  "Delete Ingredient",
                  ),
              ),

            ],
          ),
        ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
      ]),
    );
  }
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

}
