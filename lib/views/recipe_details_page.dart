import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'instruction_page.dart';
import '../viewmodels/recipe_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/viewmodels/grocery_viewmodel.dart';
import 'package:smart_virtual_refrigerator/viewmodels/grocery_viewmodel.dart';
import '../models/grocery.dart';
import 'create_recipe_view.dart';
import '../viewmodels/create_recipe_viewmodel.dart';
import '../services/firestore_service.dart';
import 'edit_recipe_view.dart';

class RecipeDetailsPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  late Recipe _currentRecipe;
  bool updated = false;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.recipe;
  }

  Future<void> _refreshRecipe() async {
    final newRecipe = await _firestoreService.getRecipeById(_currentRecipe.id);
    if (newRecipe != null) {
      setState(() {
        _currentRecipe = newRecipe;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<RecipeViewModel>(context, listen: false).authService.userId;
    final isOwner = _currentRecipe.userId == userId;

    return Scaffold(
      body: Column(
        children: [
          // Top image section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                child: Image.network(
                  _currentRecipe.imageUrl,
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 40,
                left: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context, updated);
                    },
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                           onPressed: () async {
                          final selected = await showDialog<List<Map<String, dynamic>>>(
                            context: context,
                            builder: (context) {
                              final List<bool> checked = List.generate(widget.recipe.ingredients.length, (_) => true);
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    title: const Text('Add Ingredients to Grocery List'),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: widget.recipe.ingredients.length,
                                        itemBuilder: (context, idx) {
                                          final ing = widget.recipe.ingredients[idx];
                                          return CheckboxListTile(
                                            value: checked[idx],
                                            onChanged: (val) {
                                              setState(() => checked[idx] = val ?? false);
                                            },
                                            title: Text(ing['name'] ?? ''),
                                            subtitle: Text('${ing['quantity'] ?? ''} ${ing['unit'] ?? ''}'),
                                          );
                                        },
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, null),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          final selectedIngredients = <Map<String, dynamic>>[];
                                          for (int i = 0; i < widget.recipe.ingredients.length; i++) {
                                            if (checked[i]) selectedIngredients.add(widget.recipe.ingredients[i]);
                                          }
                                          Navigator.pop(context, selectedIngredients);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                          if (selected != null && selected.isNotEmpty) {
                            final groceryVM = Provider.of<GroceryListViewModel>(context, listen: false);
                            final items = selected.map((ing) => Grocery(
                              name: ing['name'] ?? '',
                              quantity: ing['quantity']?.toString() ?? '',
                              unit: ing['unit'] ?? '',
                              source: 'recipe',
                              imageUrl: null,
                              expiryDate: null,
                            )).toList();
                            groceryVM.addItems(items);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added ${selected.length} ingredient(s) to grocery list!')),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Consumer<RecipeViewModel>(
                        builder: (context, viewModel, _) {
                          final isFav = viewModel.isFavourite(_currentRecipe.id);
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey,
                            ),
                            onPressed: () async {
                              await viewModel.toggleFavourite(_currentRecipe);
                              updated = true;
                              setState(() {}); // update heart count visually
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (isOwner)
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (_) => _buildEditDeleteSheet(context),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Details section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_currentRecipe.dishName,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            _currentRecipe.description,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Classic ${_currentRecipe.style} recipe",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.red, size: 18),
                        const SizedBox(width: 4),
                        Text("${_currentRecipe.numberFavourites} favourites",
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text("Ingredients",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (var ing in _currentRecipe.ingredients)
                  _ingredientTile(
                      ing['name'],
                      ing['quantity']?.toString() ?? '',
                      ing['unit'] ?? ''),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InstructionPage(recipe: _currentRecipe),
                      ),
                    );
                  },
                  child: const Text('Make this Recipe'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _ingredientTile(String name, String quantity, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 16)),
          Text("$quantity $unit", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEditDeleteSheet(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text('Manage Recipe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Recipe'),
              onTap: () async {
                Navigator.pop(context); // Close sheet
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => CreateRecipeViewModel(editRecipe: _currentRecipe),
                      child: EditRecipePage(recipe: _currentRecipe),
                    ),
                  ),
                );
                if (result == true && context.mounted) {
                  await _refreshRecipe(); // 🔁 Fetch updated recipe from Firestore
                  updated = true;
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Recipe'),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Confirm Delete"),
                    content: const Text("Are you sure you want to delete this recipe?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await Provider.of<RecipeViewModel>(context, listen: false)
                      .deleteRecipe(_currentRecipe.id, _currentRecipe.imageUrl);
                  Navigator.pop(context, true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
