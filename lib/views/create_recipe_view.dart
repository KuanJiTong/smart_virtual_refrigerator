import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../viewmodels/create_recipe_viewmodel.dart';
import 'home_page.dart';
import '../models/recipe.dart';

class CreateRecipePage extends StatelessWidget {
  const CreateRecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Just return the body, because provider is already wrapped above
    return const _CreateRecipePageBody();
  }
}

class _CreateRecipePageBody extends StatefulWidget {
  const _CreateRecipePageBody();

  @override
  State<_CreateRecipePageBody> createState() => _CreateRecipePageBodyState();
}

class _CreateRecipePageBodyState extends State<_CreateRecipePageBody> {
  final _formKey = GlobalKey<FormState>();

  void _showImageSourceDialog(CreateRecipeViewModel viewModel) {
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
                viewModel.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                viewModel.pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateRecipeViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(title: const Text("Create Recipe")),
          body: Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: vm.pickedImage != null
                          ? Image.file(vm.pickedImage!, height: 150)
                          : Container(
                        height: 150,
                        width: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.add_a_photo, size: 50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _showImageSourceDialog(vm),
                        icon: const Icon(Icons.upload),
                        label: const Text("Upload Image"),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: vm.nameController,
                      decoration: InputDecoration(labelText: "Recipe Name",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: vm.descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(labelText: "Description",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: vm.styleController,
                      decoration: InputDecoration(labelText: "Style",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: vm.selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: vm.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => vm.selectedCategory = val!),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Ingredients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(onPressed: vm.addIngredient, icon: const Icon(Icons.add)),
                      ],
                    ),
                    ...vm.ingredients.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: item['name'],
                              decoration: InputDecoration(labelText: "Name",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: item['quantity'],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: "Qty",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: item['unit'],
                            onChanged: (newValue) => setState(() => item['unit'] = newValue),
                            items: vm.quantityUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => vm.removeIngredient(i),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Cooking Steps", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(onPressed: vm.addCookingStep, icon: const Icon(Icons.add)),
                      ],
                    ),
                    ...vm.cookingSteps.asMap().entries.map((entry) {
                      final i = entry.key;
                      final c = entry.value;
                      return Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: c,
                              decoration: InputDecoration(labelText: "Step ${i + 1}",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => vm.removeCookingStep(i),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        await vm.submitRecipe(context, _formKey);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Recipe created successfully')),
                        );

                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 1)));
                        },
                      child: const Text("Submit Recipe"),
                    ),
                  ],
                ),
              ),
              if (vm.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}
