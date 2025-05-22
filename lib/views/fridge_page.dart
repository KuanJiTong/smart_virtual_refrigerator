import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/fridge_viewmodel.dart';
import 'leftovers_page.dart';

class FridgePage extends StatelessWidget {
  const FridgePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FridgeViewModel(),
      child: const FridgeViewBody(),
    );
  }
}

class FridgeViewBody extends StatelessWidget {
  const FridgeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FridgeViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Fridge'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    // Search Bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search ingredient',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Leftovers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Leftovers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Row(
                          children: [
                            Text('${vm.allLeftovers.length} items', style: const TextStyle(color: Colors.grey)),
                            if (vm.allLeftovers.length > 3)
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LeftoversPage()),
                                  );
                                },
                                child: const Text('View All'),
                              ),
                          ],
                        ),
                      ],
                    ),
                 

                    const SizedBox(height: 12),
                    SizedBox(
                      height: 150,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: vm.allLeftovers.map((leftover) {
                          return _leftoverCard(
                            imagePath: 'assets/${leftover['image']}',
                            title: leftover['title'],
                            date: leftover['date'],
                            quantity: leftover['quantity'],
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Ingredients
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('${vm.filteredIngredients.length} items', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: ['All', 'Vegetables', 'Fruit', 'Meat'].map((label) {
                        return GestureDetector(
                          onTap: () {
                            vm.setCategory(label);
                          },
                          child: _ingredientFilter(
                            label: label,
                            isSelected: vm.selectedCategory == label,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: vm.filteredIngredients.map((ingredient) {
                        return SizedBox(
                          width: (MediaQuery.of(context).size.width - 56) / 2,
                          child: _ingredientCard(
                            'assets/${ingredient['image']}',
                            ingredient['quantity'],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _leftoverCard({
    required String imagePath,
    required String title,
    required String date,
    required int quantity,
  }) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(quantity.toString()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _ingredientFilter({required String label, bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.yellow : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label),
    );
  }

  Widget _ingredientCard(String imagePath, String quantity) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 48),
          const SizedBox(height: 8),
          Text(quantity, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
