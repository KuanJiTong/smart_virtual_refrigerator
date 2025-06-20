import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/viewmodels/recipe_viewmodel.dart';
import 'package:smart_virtual_refrigerator/views/create_recipe_view.dart';
import 'recipe_details_page.dart';
import '../models/recipe.dart';
import 'favourited_recipes_page.dart';
import 'your_recipes_page.dart';


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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search by dish name',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            Provider.of<RecipeViewModel>(context, listen: false).filterRecipes(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          final viewModel = Provider.of<RecipeViewModel>(context, listen: false);
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (newContext) => _buildFilterSheet(newContext, viewModel),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Favorited Recipes',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text(
                            '${bookmarkedRecipes.length} recipes',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if (bookmarkedRecipes.length > 3)
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FavouritedRecipesPage(recipes: bookmarkedRecipes),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                              ),
                              child: const Text('View All'),
                            ),
                        ],
                      ),
                    ],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Recipes',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Consumer<RecipeViewModel>(
                        builder: (context, vm, _) {
                          final userRecipes = vm.userRecipes;
                          return Row(
                            children: [
                              Text(
                                '${userRecipes.length} recipes',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              if (userRecipes.length > 3)
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => YourRecipesPage(recipes: userRecipes),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text('View All'),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),


                  const SizedBox(height: 12),
                  Consumer<RecipeViewModel>(
                    builder: (context, vm, _) {
                      final userRecipes = vm.userRecipes;

                      if (userRecipes.isEmpty) {
                        return const Text('You haven’t created any recipes yet.');
                      }

                      return SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: userRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = userRecipes[index];
                            return _recipeCard(context, recipe); // ✅ reuse the same card UI
                          },
                        ),
                      );
                    },
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

  Widget _buildFilterSheet(BuildContext context, RecipeViewModel vm) {
  void refreshAndReopen(BuildContext context, void Function() updateFilter) {
    updateFilter();
    Navigator.pop(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (newContext) => _buildFilterSheet(newContext, vm),
        );
      }
    });
  }

  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          const Text('Sort By'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Name A-Z'),
                selected: vm.sortOption == 'name',
                onSelected: (_) {
                  refreshAndReopen(context, () => vm.updateSortOption('name'));
                },
              ),
              ChoiceChip(
                label: const Text('Most Favourited'),
                selected: vm.sortOption == 'favourites',
                onSelected: (_) {
                  refreshAndReopen(context, () => vm.updateSortOption('favourites'));
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    refreshAndReopen(context, () {
                      vm.updateSortOption('name');
                      vm.filterRecipes('');
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Clear Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}



}
