import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/viewmodels/recipe_viewmodel.dart';
import 'package:smart_virtual_refrigerator/views/create_recipe_view.dart';
import 'recipe_details_page.dart';
import '../models/recipe.dart';


class RecipeCommunityPage extends StatelessWidget {
  const RecipeCommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeViewModel()..fetchAllRecipesWithFavourites(),
      child: Scaffold(
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.receipt, color: Colors.black),
              ),
              onTap: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateRecipePage()),
                  );
                });
              },
            ),
          ],
        ),
        body: Consumer<RecipeViewModel>(
          builder: (context, viewModel, _) {
            final bookmarkedRecipes = viewModel.favouriteRecipes;
            final communityRecipes = viewModel.allRecipes;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text(
                    'Your Bookmarked Recipes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (bookmarkedRecipes.isEmpty)
                    const Text('No favourites yet.')
                  else
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: bookmarkedRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = bookmarkedRecipes[index];
                          return _recipeCard(context, recipe);
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Community Recipes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (communityRecipes.isEmpty)
                    const Text('No community recipes found.')
                  else
                    Column(
                      children: communityRecipes.map((recipe) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          leading: SizedBox(
                            width: 60,
                            height: 60,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                recipe.imageUrl.isNotEmpty ? recipe.imageUrl : 'https://via.placeholder.com/60',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(recipe.dishName),
                          subtitle: Text('Shared by ${recipe.userId}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailsPage(recipe: recipe),
                              ),
                            );

                            if (updated == true) {
                              // Refresh recipes
                              Provider.of<RecipeViewModel>(context, listen: false).fetchAllRecipesWithFavourites();
                            }
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _recipeCard(BuildContext context, Recipe recipe) {
    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailsPage(recipe: recipe),
          ),
        );

        if (updated == true) {
          Provider.of<RecipeViewModel>(context, listen: false).fetchAllRecipesWithFavourites();
        }
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                recipe.imageUrl.isNotEmpty
                    ? recipe.imageUrl
                    : 'https://via.placeholder.com/140x90',
                width: 140,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.dishName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

}
