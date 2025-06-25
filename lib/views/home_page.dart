import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/models/ingredient.dart';
import 'package:smart_virtual_refrigerator/viewmodels/ingredient_viewmodel.dart';
import 'package:smart_virtual_refrigerator/viewmodels/leftover_viewmodel.dart';
import 'package:smart_virtual_refrigerator/viewmodels/login_viewmodel.dart';
import 'package:smart_virtual_refrigerator/viewmodels/profile_viewmodel.dart';
import 'package:smart_virtual_refrigerator/views/expiring_notifications_page.dart';
import 'package:smart_virtual_refrigerator/views/profile_view.dart';
import 'package:smart_virtual_refrigerator/views/recipe_community_page.dart';
import 'package:smart_virtual_refrigerator/views/recipe_details_page.dart';
import 'package:smart_virtual_refrigerator/views/settings_view.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../views/login_view.dart';
import 'fridge_page.dart'; // Make sure this path is correct
import 'package:smart_virtual_refrigerator/viewmodels/recipe_viewmodel.dart';
import '../views/login_view.dart';
import 'package:smart_virtual_refrigerator/views/grocery_view.dart';
import 'package:smart_virtual_refrigerator/viewmodels/grocery_viewmodel.dart';
import 'package:smart_virtual_refrigerator/models/leftover.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _HomeBody(),
    RecipeCommunityPage(),
    const FridgePage(),
    const GroceryListView(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {

       return Scaffold(
      backgroundColor: const Color(0xFFFBFCFE),
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            selectedIconTheme: const IconThemeData(size: 28),
            unselectedIconTheme: const IconThemeData(size: 24),
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.receipt), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
            ],
          ),
        ),
      ),
    );

  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  bool _hasFetchedData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetchedData) {
      final signout = Provider.of<LoginViewModel>(context, listen: false);
      final userId = signout.user?.uid ?? "";
      final ingredientVM = Provider.of<IngredientViewModel>(context, listen: false);
      final leftoverVM = Provider.of<LeftoverViewModel>(context, listen: false);
      final notificationVM = Provider.of<NotificationViewModel>(context, listen: false);

      ingredientVM.fetchIngredients(userId);
      leftoverVM.fetchLeftovers();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notificationVM.generateNotifications(
          ingredientVM.ingredients,
          leftoverVM.leftovers,
        );
      });

      Provider.of<RecipeViewModel>(context, listen: false).fetchAIRecommendations();

      _hasFetchedData = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredientVM = Provider.of<IngredientViewModel>(context);
    final leftoverVM = Provider.of<LeftoverViewModel>(context);

     final expiringSoonItems = [
    ...ingredientVM.expiringSoonIngredients.map((e) => {
          'type': 'ingredient',
          'name': e.name,
          'quantity': e.quantity,
          'image': e.image,
          'expiry': e.expiredDate, 
        }),
    ...leftoverVM.expiringSoonLeftovers.map((e) => {
          'type': 'leftover',
          'name': e.name,
          'quantity': e.quantity.toString(),
          'image': e.imageUrl ?? '',
          'expiry': e.expiryDate,
        }),
  ]..sort((a, b) => (a['expiry'] as DateTime).compareTo(b['expiry'] as DateTime));


    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView(
            children: [
              _buildHeader(context),
              Consumer<RecipeViewModel>(
                builder: (context, recipeVM, child) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: recipeVM.categories.map((category) {
                        final isSelected = recipeVM.selectedCategory ==
                            category;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (_) =>
                                recipeVM.updateCategory(category),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recipes you can make',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      Provider.of<RecipeViewModel>(context, listen: false)
                          .fetchAIRecommendations();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Consumer<RecipeViewModel>(
                builder: (context, VM, _) {
                  if (VM.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Loading AI recommendations...\nIf it takes too long, try refreshing again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final filteredRecipes = VM.selectedCategory == 'All'
                      ? VM.aiRecommendedRecipes
                      : VM.aiRecommendedRecipes
                      .where((recipe) => recipe.category == VM.selectedCategory)
                      .toList();

                  if (filteredRecipes.isEmpty) {
                    return const Text("No AI recommended recipes available.");
                  }

                  return SizedBox(
                    height: 250,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: filteredRecipes.map((recipe) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailsPage(recipe: recipe),
                                ),
                              );
                            },
                            child: Container(
                              width: 250,
                              height: 250,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      recipe.imageUrl,
                                      width: 250,
                                      height: 250,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          Container(color: Colors.grey[300]),
                                    ),
                                    Container(
                                      width: 250,
                                      height: 250,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.3),
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          recipe.category,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 12,
                                      left: 12,
                                      right: 12,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            recipe.dishName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 4,
                                            children: recipe.ingredients
                                                .take(2)
                                                .map((ing) => Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${ing['name']}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ))
                                                .toList(),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.star,
                                                  size: 14, color: Colors.white),
                                              const SizedBox(width: 4),
                                              Text(
                                                recipe.numberFavourites?.toString() ?? '12',
                                                style: const TextStyle(
                                                    color: Colors.white, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Expiring soon',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const Spacer(),
                  Text(
                    '${expiringSoonItems.length} items',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: expiringSoonItems.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = expiringSoonItems[index];

                  final String name = item['name'] as String? ?? '';
                  final String image = item['image'] as String? ?? '';
                  final DateTime expiry = item['expiry'] as DateTime; 
                  final String type = item['type'] as String? ?? '';
                  final String quantity = item['quantity'] as String? ?? '';
                  
                     return GestureDetector(
                    onTap: () async {
                      final shouldAdd = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Add to Grocery List?'),
                          content: Text('Do you want to add "$name" to your grocery list?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      );
                      if (shouldAdd == true) {
                        final groceryVM = Provider.of<GroceryListViewModel>(context, listen: false);
                        if (type == 'ingredient') {
                          Ingredient? ingredient;
                          try {
                            ingredient = ingredientVM.expiringSoonIngredients.firstWhere((i) => i.name == name && i.quantity == quantity && i.expiredDate == expiry);
                          } catch (_) {
                            ingredient = null;
                          }
                          if (ingredient != null) {
                            groceryVM.addExpiringIngredient(ingredient);
                          }
                        } else if (type == 'leftover') {
                          Leftover? leftover;
                          try {
                            leftover = leftoverVM.expiringSoonLeftovers.firstWhere((l) => l.name == name && l.quantity.toString() == quantity && l.expiryDate == expiry);
                          } catch (_) {
                            leftover = null;
                          }
                          if (leftover != null) {
                            groceryVM.addExpiringLeftover(leftover);
                          }
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added "$name" to grocery list!')),
                        );
                      }
                    },
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image (not tappable)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                              child: image.isNotEmpty
                                ? Image.network(
                                    image,
                                    width: double.infinity,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.image),
                                  )
                                : Container(
                                    width: double.infinity,
                                    height: 70,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported),
                                  ),
                          ),
                          const SizedBox(height: 4),

                        // Name
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        Text(
                          type == 'ingredient' ? 'Ingredient' : 'Leftover',
                          style: TextStyle(
                          fontSize: 11,
                          color: type == 'ingredient' ? Colors.blue : Colors.green,
                          fontWeight: FontWeight.w500,
                          ),
                        ),

                        // Expiry Date
                       Text(
                            '${expiry.difference(DateTime.now()).inDays} day(s) left',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);
    profileVM.loadUserData();
    final userName = profileVM.user?.name ?? 'Guest';
    final imageUrl = profileVM.user?.imageUrl;

    return Container(
      height: 100,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageProfilePage()),
              );
            },
            child: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                imageUrl ?? 'https://p3-pc-sign.douyinpic.com/tos-cn-i-0813/oEI5tAfqNcIAkc9BAxgeENFEYGA6AnxjDAAXCh~tplv-dy-aweme-images:q75.webp?biz_tag=aweme_images&from=327834062&lk3s=138a59ce&s=PackSourceEnum_SEARCH&sc=image&se=false&x-expires=1750053600&x-signature=lH4UpxReCL0OQMJMLP9eRWASGMI%3D',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, $userName 👋',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Welcome back, $userName' , style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // Background color
              borderRadius: BorderRadius.circular(12), // Adjust radius as needed
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExpiringNotificationsPage()),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
