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
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  bool hasExpiry = true;
  DateTime selectedDate = DateTime.now().add(Duration(days: 7));
  File? _pickedImage;

  final List<String> categories = [
    'Bread', 'Meat', 'Vegetable', 'Fruit', 'Dairy', 'Beverage', 'Spice', 'Grain', 'Condiment',
  ];

  final List<String> quantityUnits = [
    'Gram', 'Milliliter', 'Slice', 'Piece', 'Tablespoon', 'Cup', 'Unit'
  ];

  final List<String> storageLocations = ['Fridge', 'Freezer', 'Pantry'];

  String selectedCategory = 'Bread';
  String selectedUnit = 'Gram';
  String selectedStorage = 'Fridge';

  @override
  void initState() {
    super.initState();
    nameController.text = widget.initialName ?? '';
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Center(
                    child: _pickedImage != null
                        ? Image.file(_pickedImage!, height: 150)
                        : widget.imageUrl != null
                        ? Image.network(widget.imageUrl!, height: 150)
                        : Container(
                      height: 150,
                      width: 150,
                      color: Colors.grey[300],
                      child: const Icon(Icons.add_a_photo, size: 50),
                    ),
                  ),
                  SizedBox(height: 8),
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
                  SizedBox(height: 8),

                  // Name
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select expiration date';
                        }
                        return null;
                      },
                    ),
                  SizedBox(height: 16),

                  // Quantity with Unit Dropdown
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Quantity",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter quantity';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      DropdownButton<String>(
                        value: selectedUnit,
                        items: quantityUnits.map((String unit) {
                          return DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUnit = value!;
                          });
                        },
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Storage Location
                  DropdownButtonFormField<String>(
                    value: selectedStorage,
                    decoration: InputDecoration(
                      labelText: "Storage Location",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: storageLocations.map((String location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStorage = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a storage location';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32),

                  // Add Button
                  ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      setState(() => _isLoading = true);

                      try {
                        ingredientVM.updateName(nameController.text);
                        ingredientVM.updateCategory(selectedCategory);
                        ingredientVM.updateQuantity(quantityController.text);
                        ingredientVM.updateQuantityUnit(selectedUnit);
                        ingredientVM.toggleExpiry(hasExpiry);
                        ingredientVM.updateStorageLocation(selectedStorage);
                        if (hasExpiry) {
                          ingredientVM.updateExpirationDate(selectedDate);
                        }

                        if (_pickedImage != null) {
                          String uploadedImageUrl = await ingredientVM.uploadPickedImageToFirebase(_pickedImage!);
                          ingredientVM.setImage(uploadedImageUrl);
                        } else {
                          ingredientVM.setImage(widget.imageUrl ?? '');
                        }

                        await ingredientVM.addIngredientToFirebase();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ingredient added to fridge')),
                        );

                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 2)));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add ingredient: $e')),
                        );
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    },
                    child: Text("Add to Fridge"),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
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
