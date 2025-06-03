import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/leftover.dart';
import '../viewmodels/leftover_viewmodel.dart';

class AddLeftoverView extends StatefulWidget {
  const AddLeftoverView({super.key});

  @override
  State<AddLeftoverView> createState() => _AddLeftoverViewState();
}

class _AddLeftoverViewState extends State<AddLeftoverView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateStoredController = TextEditingController();
  final _expiryDateController = TextEditingController();

  String _selectedCategory = '';
  String _selectedLocation = '';
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateStoredController.text = _formatDate(now);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 75);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
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

  Future<void> _selectDate({
    required TextEditingController controller,
    required String label,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = _formatDate(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    final leftoverVM = Provider.of<LeftoverViewModel>(context, listen: false);
    if (!_formKey.currentState!.validate()) return;

    String? imageUrl;
    if (_imageFile != null) {
      imageUrl = await leftoverVM.uploadImage(_imageFile!);
    }

    final leftover = Leftover(
      name: _nameController.text.trim(),
      quantity: _quantityController.text.trim(),
      category: _selectedCategory,
      location: _selectedLocation,
      dateStored: DateTime.parse(_dateStoredController.text),
      expiryDate: _expiryDateController.text.isEmpty
          ? null
          : DateTime.parse(_expiryDateController.text),
      notes: _notesController.text.trim(),
      imageUrl: imageUrl,
    );

    await leftoverVM.addLeftover(leftover);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Leftover added successfully")),
    );
    Navigator.pop(context);
  }

  Widget _styledTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    VoidCallback? onTap,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: isRequired
          ? (value) =>
              value == null || value.isEmpty ? 'Required' : null
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Leftover")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: _imageFile == null
                    ? Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.add_a_photo, size: 50),
                      )
                    : Image.file(_imageFile!, height: 150),
              ),
              const SizedBox(height: 16),

              //Name
              _styledTextField(
                controller: _nameController, 
                label: "Name",
                isRequired: true 
              ),

              const SizedBox(height: 12),

              //Quantity
              _styledTextField(
                controller: _quantityController, 
                label: "Quantity",
                isRequired: true
              ),

              const SizedBox(height: 12),

              //Category
              DropdownButtonFormField<String>(
                value: _selectedCategory.isEmpty ? null : _selectedCategory,
                items: ['Home Cooked Meal',
                        'Takeout / Delivery',
                        'Half-used Ingredients',
                        'Snacks',
                        'Desserts',
                        'Soups & Stews',
                        'Sauces & Dips',
                        'Others']
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val ?? ''),
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                  value == null || value.isEmpty ? 'Please select a category' : null,
              ),

              const SizedBox(height: 12),

              //Location
              DropdownButtonFormField<String>(
                value: _selectedLocation.isEmpty ? null : _selectedLocation,
                items: ['Fridge', 'Freezer']
                    .map((l) =>
                        DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedLocation = val ?? ''),
                decoration: InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                  value == null || value.isEmpty ? 'Please select a location' : null,
              ),

              const SizedBox(height: 12),

              //Date Stored
              _styledTextField(
                controller: _dateStoredController,
                label: "Date Stored",
                readOnly: true,
                isRequired: true,
                onTap: () => _selectDate(
                  controller: _dateStoredController,
                  label: "Date Stored",
                ),
              ),

              const SizedBox(height: 12),

              //Expiry Date
              _styledTextField(
                controller: _expiryDateController,
                label: "Expiry Date",
                readOnly: true,
                isRequired: true,
                onTap: () => _selectDate(
                  controller: _expiryDateController,
                  label: "Expiry Date",
                ),
              ),

              const SizedBox(height: 12),

              //Notes
              _styledTextField(
                controller: _notesController, 
                label: "Notes (optional)",
                isRequired: false
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Add Leftover"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
