import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/models/leftover.dart';
import 'package:smart_virtual_refrigerator/viewmodels/leftover_viewmodel.dart';

class UpdateLeftoverView extends StatefulWidget {
  final Map<String, dynamic> leftover;

  const UpdateLeftoverView({super.key, required this.leftover});

  @override
  State<UpdateLeftoverView> createState() => _UpdateLeftoverViewState();
}

class _UpdateLeftoverViewState extends State<UpdateLeftoverView> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  late TextEditingController _dateStoredController;
  late TextEditingController _expiryDateController;

  String _selectedCategory = '';
  String _selectedLocation = '';
  String _id = '';
  String ?_imageUrl = '';
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final l = widget.leftover;

    _nameController = TextEditingController(text:l['name']);
    _quantityController = TextEditingController(text: l['quantity'].toString());
    _notesController = TextEditingController(text: l['notes'] ?? '');
    _dateStoredController = TextEditingController(
      text: _formatDate(DateTime.parse(l['dateStored']))
    );

    _expiryDateController = TextEditingController(
      text: l['expiryDate'] != null && l['expiryDate'].isNotEmpty
          ? _formatDate(DateTime.parse(l['expiryDate']))
          : '',
    );

    _selectedCategory = l['category'];
    _selectedLocation = l['location'];
    _id = l['id'];
    _imageUrl = l['imageUrl'];
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 75);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => controller.text = _formatDate(picked));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final leftoverVM = Provider.of<LeftoverViewModel>(context, listen: false);
    String? imageUrl = widget.leftover['imageUrl'];

    if (_imageFile != null) {
      imageUrl = await leftoverVM.uploadImage(_imageFile!);
    }

    final updated = Leftover(
      name: _nameController.text.trim(),
      quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
      category: _selectedCategory,
      location: _selectedLocation,
      dateStored: DateTime.parse(_dateStoredController.text),
      expiryDate: _expiryDateController.text.isNotEmpty
          ? DateTime.parse(_expiryDateController.text)
          : null,
      notes: _notesController.text.trim(),
      imageUrl: imageUrl,
    );

    await leftoverVM.updateLeftover(_id,updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Leftover updated successfully")),
    );
    Navigator.pop(context);
  }

  Future<void> _deleteLeftover() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Leftover'),
        content: const Text('Are you sure you want to delete this leftover?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final leftoverVM = Provider.of<LeftoverViewModel>(context, listen: false);
      try {
        await leftoverVM.deleteLeftover(_id);
        Navigator.of(context).pop(true); 
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Leftover")),
      body: Stack(
        children: [Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, height: 150)
                      : (_imageUrl != null
                          ? Image.network(_imageUrl!, height: 150)
                          : Container(
                              height: 150,
                              color: Colors.grey[300],
                              child: const Icon(Icons.add_a_photo, size: 50),
                            )),
                ),
                const SizedBox(height: 16),
        
                _textField(_nameController, "Name"),
                const SizedBox(height: 12),
                _textField(_quantityController, "Quantity"),
                const SizedBox(height: 12),
        
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: ['Home Cooked Meal', 'Takeout / Delivery', 'Half-used Ingredients', 'Snacks', 'Desserts', 'Soups & Stews', 'Sauces & Dips', 'Others']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val ?? ''),
                  decoration: const InputDecoration(labelText: "Category"),
                ),
        
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedLocation,
                  items: ['Fridge', 'Freezer']
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedLocation = val ?? ''),
                  decoration: const InputDecoration(labelText: "Location"),
                ),
        
                const SizedBox(height: 12),
                _textField(_dateStoredController, "Date Stored", readOnly: true,
                  onTap: () => _selectDate(_dateStoredController)),
                const SizedBox(height: 12),
                _textField(_expiryDateController, "Expiry Date", readOnly: true,
                  onTap: () => _selectDate(_expiryDateController)),
                const SizedBox(height: 12),
                _textField(_notesController, "Notes (optional)", isRequired: false),
        
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text("Update Leftover", style: TextStyle(fontSize: 16, color: Colors.black)),
                ),        
                SizedBox(height: 5),
                ElevatedButton(
                  onPressed: _deleteLeftover,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text(
                    "Delete Leftover",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
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
        ]
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label,
      {bool readOnly = false, VoidCallback? onTap, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(labelText: label),
      validator: isRequired ? (val) => val == null || val.isEmpty ? 'Required' : null : null,
    );
  }
}
