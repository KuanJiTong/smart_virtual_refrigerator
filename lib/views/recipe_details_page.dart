import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'instruction_page.dart';
import '../viewmodels/recipe_viewmodel.dart';
import 'package:provider/provider.dart';


class RecipeDetailsPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => Navigator.pop(context),
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
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
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
                            },
                          );
                        },
                      )
,
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
}
