import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:smart_virtual_refrigerator/views/create_recipe_view.dart';
import 'package:smart_virtual_refrigerator/views/profile_view.dart';

class RecipeCommunityPage extends StatelessWidget {
  final List<Map<String, String>> bookmarkedRecipes = [
    {
      'title': 'Avocado Toast',
      'image': 'https://example.com/avocado.jpg',
    },
    {
      'title': 'Chicken Salad',
      'image': 'https://example.com/salad.jpg',
    },
  ];

  final List<Map<String, String>> communityRecipes = [
    {
      'title': 'Beef Stew',
      'image': 'https://example.com/beef.jpg',
    },
    {
      'title': 'Vegan Curry',
      'image': 'https://example.com/curry.jpg',
    },
    {
      'title': 'Spaghetti',
      'image': 'https://example.com/spaghetti.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Recipes'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 12,
        spaceBetweenChildren: 8,
        children: [
          SpeedDialChild(
            label: 'Create New Recipe',
            backgroundColor: Colors.transparent,
            labelStyle: const TextStyle(fontSize: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.receipt, color: Colors.black),
            ),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateRecipePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Your Bookmarked Recipes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: bookmarkedRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = bookmarkedRecipes[index];
                  return _recipeCard(recipe['title']!, recipe['image']!);
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Community Recipes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Column(
              children: communityRecipes.map((recipe) {
                return ListTile(
                  leading: Image.network(recipe['image']!, width: 60, height: 60, fit: BoxFit.cover),
                  title: Text(recipe['title']!),
                  subtitle: const Text('Shared by user123'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to recipe detail
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recipeCard(String title, String imageUrl) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(imageUrl, width: 140, height: 90, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
