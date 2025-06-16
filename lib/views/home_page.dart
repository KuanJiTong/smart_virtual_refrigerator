import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/models/ingredient.dart';
import 'package:smart_virtual_refrigerator/viewmodels/ingredient_viewmodel.dart';
import 'package:smart_virtual_refrigerator/viewmodels/login_viewmodel.dart';
import 'package:smart_virtual_refrigerator/viewmodels/profile_viewmodel.dart';
import 'package:smart_virtual_refrigerator/views/profile_view.dart';
import 'package:smart_virtual_refrigerator/views/recipe_community_page.dart';
import '../views/login_view.dart';
import 'fridge_page.dart'; // Make sure this path is correct
import 'package:smart_virtual_refrigerator/viewmodels/recipe_viewmodel.dart';
import '../views/login_view.dart';

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
    const Center(child: Text('Cart')),
    const Center(child: Text('Settings')),
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

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {

    final signout = Provider.of<LoginViewModel>(context, listen: false);
    final recipeVM = Provider.of<RecipeViewModel>(context);
    final ingredientVM = Provider.of<IngredientViewModel>(context);
    ingredientVM.fetchIngredients(signout.user?.uid ?? "");

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search recipe',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onChanged: (value) {
                  Provider.of<RecipeViewModel>(context, listen: false)
                      .updateSearch(value);
                },
              ),
              const SizedBox(height: 16),
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
                children: const [
                  Text('Recipes you can make',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  Icon(Icons.tune),
                ],
              ),
              const SizedBox(height: 24),
              Column(
                children: recipeVM.filteredRecipes.map((recipe) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          recipe.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error,
                              stackTrace) => const Icon(Icons.broken_image),
                        ),
                      ),
                      title: Text(recipe.title),
                      subtitle: Text(recipe.category),
                    ),
                  );
                }).toList(),

              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('Expiring soon',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children: ingredientVM.expiringSoonIngredients.map((
                    ingredient) {
                  return ListTile(
                    leading: Image.network(ingredient.image, width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.image)),
                    title: Text(ingredient.name),
                    subtitle: Text(
                        '${ingredient.daysLeftToExpire} day(s) left'),
                    trailing: Text(ingredient.quantity),
                  );
                }).toList(),
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
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}
