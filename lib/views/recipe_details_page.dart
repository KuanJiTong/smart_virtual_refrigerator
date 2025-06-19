import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'instruction_page.dart';
import '../viewmodels/recipe_viewmodel.dart';
import 'package:provider/provider.dart';
import 'create_recipe_view.dart'; 
import '../viewmodels/create_recipe_viewmodel.dart';



class RecipeDetailsPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<RecipeViewModel>(context, listen: false).authService.userId;
    final isOwner = recipe.userId == userId;

    bool updated = false; 

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
                  recipe.imageUrl,
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
                    // Shopping Cart Icon
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Favourite Icon
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Consumer<RecipeViewModel>(
                        builder: (context, viewModel, _) {
                          final isFav = viewModel.isFavourite(recipe.id);
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey,
                            ),
                            onPressed: () async {
                              await viewModel.toggleFavourite(recipe);
                              updated = true;
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Edit/Delete PopupMenu
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
            child: Container(
    
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
                            Text(recipe.dishName,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              recipe.description,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Classic ${recipe.style} recipe",
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
                          Text("${recipe.numberFavourites} favourites",
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),



                  const SizedBox(height: 16),

                  const SizedBox(height: 24),
                  const Text("Ingredients",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  for (var ing in recipe.ingredients)
                    _ingredientTile(
                        ing['name'],
                        ing['quantity']?.toString() ?? '',
                        ing['unit'] ?? ''),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InstructionPage(recipe: recipe),
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
            ),
          )

        ],
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _ingredientTile(String name, String quantity, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              Text("$quantity $unit", style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 8),
              
            ],
          )
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
                Navigator.pop(context); // Close sheet first
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => CreateRecipeViewModel(editRecipe: recipe),
                      child: const CreateRecipePage(),
                    ),

                  ),
                );
                if (result == true && context.mounted) {
                  Navigator.pop(context, true); // Pass update flag
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Recipe'),
              onTap: () async {
                Navigator.pop(context); // Close sheet first
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
                      .deleteRecipe(recipe.id, recipe.imageUrl);
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
