import 'package:flutter/material.dart';
import '../models/recipe.dart'; 

class InstructionPage extends StatelessWidget {
  final Recipe recipe;

  const InstructionPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Instructions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                recipe.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            
            const SizedBox(height: 24),
            const Text(
              "Manual",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            ...recipe.cookingSteps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "• $step",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
