import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../viewmodels/create_recipe_viewmodel.dart';
import 'home_page.dart';
import '../models/recipe.dart';

class EditRecipePage extends StatelessWidget {
  final Recipe recipe;

  const EditRecipePage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateRecipeViewModel(editRecipe: recipe),
      builder: (context, child) {
        return const _EditRecipePageBody();
      },
    );
  }
}

class _EditRecipePageBody extends StatefulWidget {
  const _EditRecipePageBody();

  @override
  State<_EditRecipePageBody> createState() => _EditRecipePageBodyState();
}

class _EditRecipePageBodyState extends State<_EditRecipePageBody> {
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
          appBar: AppBar(title: const Text("Edit Recipe")),
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
                          : Image.network(
                              vm.imageUrl,
                              height: 150,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  width: 150,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, size: 50),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _showImageSourceDialog(vm),
                        icon: const Icon(Icons.upload),
                        label: const Text("Change Image"),
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
                            icon: const Icon(Icons.delete, color: const Color(0xFFE85C5C)),
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
                            icon: const Icon(Icons.delete, color: const Color(0xFFE85C5C)),
                            onPressed: () => vm.removeCookingStep(i),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        final success = await vm.submitRecipe(_formKey);

                        if (!mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Recipe updated successfully")),
                          );
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to update recipe.")),
                          );
                        }
                      },

                      child: const Text("Update Recipe"),
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
