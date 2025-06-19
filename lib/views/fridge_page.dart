import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/utils/popup.dart';
import 'package:smart_virtual_refrigerator/viewmodels/leftover_viewmodel.dart';
import 'package:smart_virtual_refrigerator/views/expiring_notifications_page.dart';
import 'package:smart_virtual_refrigerator/views/update_ingredients_view.dart';
import 'package:smart_virtual_refrigerator/views/add_leftover_view.dart';
import 'package:smart_virtual_refrigerator/views/update_leftover_view.dart';

import '../viewmodels/fridge_viewmodel.dart';
import 'add_ingredients_barcode_view.dart';
import 'leftovers_page.dart';
import '../services/auth_service.dart';
import 'dart:math';

class FridgePage extends StatefulWidget {
  const FridgePage({super.key});

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FridgeViewModel()..loadIngredients(),
      child: Consumer<FridgeViewModel>(
        builder: (context, vm, _) {
          return FridgeViewBody();
        },
      ),
    );
  }
}

class FridgeViewBody extends StatefulWidget {
  const FridgeViewBody({super.key});

  @override
  State<FridgeViewBody> createState() => _FridgeViewBodyState();
}

class _FridgeViewBodyState extends State<FridgeViewBody> {

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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Fridge'),
        centerTitle: true,
        actions: [
          Container(
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: BorderRadius.circular(12), // Adjust radius as needed
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ExpiringNotificationsPage()),
                  );
                },
              ),
          )
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
                                onPressed: () async {
                                  final shouldReload = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LeftoversPage(leftovers: vm.allLeftovers),
                                    ),
                                  );

                                  if (shouldReload == true) {
                                    vm.loadIngredients();
                                  }
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
                    SizedBox(
                      height: 150,
                      child: vm.allLeftovers.isEmpty
                          ? Center(
                        child: Text(
                          'No leftovers available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                          : ListView(
                        scrollDirection: Axis.horizontal,
                        children: vm.allLeftovers.map((leftover) {
                          return _leftoverCard(
                            imageUrl: '${leftover['imageUrl'] ?? ''}',
                            name: leftover['name'],
                            expiryDate: leftover['expiryDate'],
                            quantity: leftover['quantity'],
                            category: leftover['category'],
                            location: leftover['location'],
                            notes: leftover['notes'],                            
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UpdateLeftoverView(leftover: leftover),
                                ),
                              );

                              if (result == true) {
                                vm.loadIngredients();
                              }
                            },
                          );
                        }).toList(),
                      )
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

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      child: Row(
                        children: categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: vm.selectedCategory == category,
                              onSelected: (_) => vm.setCategory(category),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    vm.filteredIngredients.isEmpty
                        ? Center(
                      child: Text(
                        'No ingredients available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                        : Wrap(
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
                                quantityUnit: ingredient['quantityUnit'],
                                storageLocation: ingredient['storageLocation'],
                                name: ingredient['name'],
                                expiredDate: ingredient['expiredDate'],
                                daysLeftToExpire: max(
                                  0,
                                  DateTime.parse(ingredient['expiredDate'])
                                      .difference(DateTime.now())
                                      .inDays,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UpdateIngredientsView(
                                        ingredient: ingredient,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 12,
        spaceBetweenChildren: 8,
        children: [
          SpeedDialChild(
            label: 'Add Leftovers',
            backgroundColor: Colors.transparent,
            labelStyle: const TextStyle(fontSize: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.dinner_dining, color: Colors.black),
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddLeftoverView()),
              );
              if (result == true) {
                vm.loadIngredients();
              }
            },
          ),
          SpeedDialChild(
            label: 'Add Ingredients',
            backgroundColor: Colors.transparent,
            labelStyle: const TextStyle(fontSize: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.shopping_basket, color: Colors.black),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddIngredientsBarcodeView()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _leftoverCard({
  String? imageUrl,
  required String name,
  required String expiryDate,
  required int quantity,
  required String category,
  required String location,
  String? notes,
  required VoidCallback onTap,
}) {
  Widget imageWidget;
  final dayToExpiry = DateTime.parse(expiryDate).difference(DateTime.now()).inDays;
  final isExpired = dayToExpiry < 0;
  if (imageUrl != null && imageUrl.isNotEmpty) {
    imageWidget = Image.network(
      imageUrl,
      width: double.infinity,
      height: 100,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: double.infinity,
          height: 100,
          color: Colors.grey[200],
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: 100,
          color: Colors.grey[300],
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, size: 40),
        );
      },
    );
  } else {
    imageWidget = Container(
      width: double.infinity,
      height: 100,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported, size: 40),
    );
  }

    return InkWell(
      onTap: onTap,
      child: Container(
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

                if (notes != null && notes.isNotEmpty)
                 Positioned(
                  top: 8.0,
                  right: 8.0,
                  child: Container(
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.85), // light background box
                      borderRadius: BorderRadius.circular(6), // rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.sticky_note_2_outlined, // pick your icon here
                        size: 13,
                        color: Colors.black87,
                      ),
                      tooltip: 'Show Note',
                      padding: EdgeInsets.all(4), // spacing inside box
                      constraints: BoxConstraints(), // removes default IconButton size
                      onPressed: () => showNoteDialog(context, name, notes),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Tooltip(
                        message: '$name ($location)',
                        waitDuration: Duration(milliseconds: 500), 
                        child: Text(
                          '$name ($location)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: isExpired
                                  ? const Color(0xFFE85C5C) // expired
                                  : dayToExpiry <= 2
                                      ? const Color(0xFFFF9800) // almost expired
                                      : Colors.grey,  
                            size: 12,
                          ),
                          const SizedBox(width: 2), // Small space between icon and text

                          Padding(
                              padding: const EdgeInsets.only(top: 2.5),                            
                              child: Text(
                              '$expiryDate (${isExpired ? 'Expired' : '$dayToExpiry day${dayToExpiry == 1 ? '' : 's'} left'})',
                              style: TextStyle(
                                color: isExpired
                                        ? const Color(0xFFE85C5C) // expired
                                        : dayToExpiry <= 2
                                            ? const Color(0xFFFF9800) // almost expired
                                            : Colors.grey,                                
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9DA5C1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    quantity.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _ingredientCard({
    required String id,
    required String image,
    required String quantity,
    required String quantityUnit,
    required String storageLocation,
    required String name,
    required String expiredDate,
    required int daysLeftToExpire,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 325,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9DA5C1),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Text(
                  '$quantity $quantityUnit(s)',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: (image != '')
                    ? Image.network(
                  image,
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 100,
                      width: 100,
                      alignment: Alignment.center,
                      color: Colors.grey[200],
                      child: const CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 40),
                    );
                  },
                )
                    : Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (daysLeftToExpire / 31).clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  daysLeftToExpire <= 0
                      ? const Color(0xFFE85C5C)
                      : daysLeftToExpire <= 3
                      ? const Color(0xFFE85C5C)
                      : daysLeftToExpire <= 5
                      ? Colors.orange
                      : const Color(0xFF22C97D),
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                daysLeftToExpire == 0 ? 'Expired' : '$daysLeftToExpire day(s) left',
                style: TextStyle(
                  color: daysLeftToExpire == 0 ? Colors.red : Colors.black,
                  fontWeight: daysLeftToExpire == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1)),
            Center(child: Text('($storageLocation)', style: const TextStyle(fontWeight: FontWeight.bold))),
            Center(child: Text('$expiredDate')),

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
