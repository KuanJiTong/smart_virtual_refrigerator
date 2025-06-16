import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeDetailsPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.dishName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Image.network(
              recipe.imageUrl,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(height: 200, color: Colors.grey[300]),
            ),
            const SizedBox(height: 16),
            Text(
              recipe.dishName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(recipe.description),
            const SizedBox(height: 16),
            const Text('Ingredients',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...recipe.ingredients.map((ing) => Text(
                "- ${ing['name']} (${ing['quantity'] ?? ''} ${ing['unit'] ?? ''})")),
            const SizedBox(height: 16),
            const Text('Steps',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...recipe.cookingSteps
                .asMap()
                .entries
                .map((entry) => Text("${entry.key + 1}. ${entry.value}")),
          ],
        ),
      ),
    );
  }
}
