import 'package:flutter/material.dart';
import '../models/recipe.dart';

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
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {},
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
                Text(recipe.dishName,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Classic ${recipe.style} recipe",
                    style: const TextStyle(color: Colors.grey)),

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

                const SizedBox(height: 24),
                const Text("Cooking Steps",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...recipe.cookingSteps
                    .asMap()
                    .entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text("${e.key + 1}. ${e.value}"),
                        )),
              ],
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
              Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.yellow),
                child: const Icon(Icons.add, size: 20),
              )
            ],
          )
        ],
      ),
    );
  }
}
