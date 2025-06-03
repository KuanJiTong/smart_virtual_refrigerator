import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/models/ingredient.dart';
import 'package:smart_virtual_refrigerator/viewmodels/ingredient_viewmodel.dart';
import 'package:smart_virtual_refrigerator/viewmodels/login_viewmodel.dart';
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
    const Center(child: Text('Favorites')),
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
    final signout = Provider.of<LoginViewModel>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: ''), // FridgePage
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Home Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await signout.signOut();

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
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
                            selectedColor: Colors.black,
                            backgroundColor: Colors.grey[300],
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
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
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final displayName = loginVM.user?.displayName ?? 'Guest';

    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(
            'https://p3-pc-sign.douyinpic.com/tos-cn-i-0813/oEI5tAfqNcIAkc9BAxgeENFEYGA6AnxjDAAXCh~tplv-dy-aweme-images:q75.webp?biz_tag=aweme_images&from=327834062&lk3s=138a59ce&s=PackSourceEnum_SEARCH&sc=image&se=false&x-expires=1750053600&x-signature=lH4UpxReCL0OQMJMLP9eRWASGMI%3D',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, $displayName 👋',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Welcome back', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        )
      ],
    );
  }
}
