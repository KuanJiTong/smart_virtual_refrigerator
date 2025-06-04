import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/views/update_ingredients_view.dart';
import 'package:smart_virtual_refrigerator/views/add_leftover_view.dart';

import '../viewmodels/fridge_viewmodel.dart';
import 'add_ingredients_barcode_view.dart';
import 'leftovers_page.dart';
import '../services/auth_service.dart';

class FridgePage extends StatelessWidget {
  const FridgePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FridgeViewModel(),
      child: Consumer<FridgeViewModel>(
        builder: (context, vm, _) {
          final userId = AuthService().userId;
          if (userId != null && vm.allIngredients.isEmpty && !vm.isLoading) {
            vm.loadIngredients();
          }

          return const FridgeViewBody();
        },
      ),
    );
  }
}

class FridgeViewBody extends StatelessWidget {
  const FridgeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FridgeViewModel>(context);

    final categories = [
                      'All',
                      'Vegetable',
                      'Fruit',
                      'Meat',
                      'Dairy',
                      'Beverage',
                      'Spice',
                      'Grain',
                      'Condiment',
                      'Bread'
                    ];
                    
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
                    // Search bar + filter button
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search ingredient',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onChanged: (value) {
                              vm.setSearchKeyword(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) => _buildFilterSheet(context, vm),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Leftovers Section
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
                                    MaterialPageRoute(
                                      builder: (_) => LeftoversPage(leftovers: vm.allLeftovers),
                                    ),
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
                            imageUrl: 'assets/${leftover['imageUrl']}',
                            name: leftover['name'],
                            expiryDate: leftover['expiryDate'],
                            quantity: leftover['quantity'],
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Ingredients Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('${vm.filteredIngredients.length} items', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    
                    // Category Filter Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        return ChoiceChip(
                          label: Text(category),
                          selected: vm.selectedCategory == category,
                          onSelected: (_) => vm.setCategory(category),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: vm.filteredIngredients.map((ingredient) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final screenWidth = MediaQuery.of(context).size.width;
                            final cardWidth = (screenWidth - 48) / 2;

                            return SizedBox(
                              width: cardWidth,
                              child: _ingredientCard(
                                id: ingredient['id'],
                                image: '${ingredient['image']}',
                                quantity: ingredient['quantity'],
                                name: ingredient['name'],
                                expiredDate: ingredient['expiredDate'],
                                daysLeftToExpire: ingredient['daysLeftToExpire'],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UpdateIngredientsView(ingredient: ingredient),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),

                  ],
                ),
              ),
            ),

            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                    return SafeArea( // <-- Added SafeArea here
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.dinner_dining),
                              title: const Text('Add Leftovers'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddLeftoverView()),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.shopping_basket),
                              title: const Text('Add Ingredients'),
                              onTap: () {
                                Navigator.pop(context); // Close the drawer or current modal if needed
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddIngredientsBarcodeView()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              backgroundColor: Colors.black,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _leftoverCard({
    String? imageUrl,
    required String name,
    required String expiryDate,
    required int quantity,
  }) {

    Widget imageWidget;
    imageWidget = Image.network(
      'https://picsum.photos/seed/${name.hashCode}/100/100',
      width: double.infinity,
      height: 100,
      fit: BoxFit.cover,
    );

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
                child: imageWidget,
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
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            overflow: TextOverflow.ellipsis, // <-- Truncate with "..."
            maxLines: 1, // <-- Ensure it doesn't exceed 1 line
          ),
          Text(expiryDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _ingredientCard({
    required String id,
    required String image,
    required String quantity,
    required String name,
    required String expiredDate,
    required int daysLeftToExpire,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                image,
                height: 35,
                width: 35,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1),
            Text('Qty: $quantity'),
            Text('Expires: $expiredDate'),
            Text(
              'Days left: $daysLeftToExpire',
              style: TextStyle(color: daysLeftToExpire <= 1 ? Colors.red : Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSheet(BuildContext context, FridgeViewModel vm) {
    void refreshAndReopen(BuildContext context, void Function() updateFilter) {
      updateFilter();
      Navigator.pop(context);

      // Delay to allow UI refresh before reopening modal
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
            const Text('Expiry'),
            Wrap(
              spacing: 8,
              children: ExpiryFilter.values.map((filter) {
                return ChoiceChip(
                  label: Text(filter == ExpiryFilter.all ? 'All' : 'Expiring Soon'),
                  selected: vm.expiryFilter == filter,
                  onSelected: (_) {
                    refreshAndReopen(context, () => vm.setExpiryFilter(filter));
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Quantity'),
            Wrap(
              spacing: 8,
              children: QuantityFilter.values.map((filter) {
                return ChoiceChip(
                  label: Text(filter == QuantityFilter.all ? 'All' : 'Low Stock'),
                  selected: vm.quantityFilter == filter,
                  onSelected: (_) {
                    refreshAndReopen(context, () => vm.setQuantityFilter(filter));
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Sort By'),
            Wrap(
              spacing: 8,
              children: SortOrder.values.map((order) {
                String label;
                switch (order) {
                  case SortOrder.nameAZ:
                    label = 'Name A-Z';
                    break;
                  case SortOrder.expirySoonest:
                    label = 'Expiry Soonest';
                    break;
                  case SortOrder.quantityHighToLow:
                    label = 'Quantity High → Low';
                    break;
                }

                return ChoiceChip(
                  label: Text(label),
                  selected: vm.sortOrder == order,
                  onSelected: (_) {
                    refreshAndReopen(context, () => vm.setSortOrder(order));
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      refreshAndReopen(context, () => vm.clearFilters());
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
