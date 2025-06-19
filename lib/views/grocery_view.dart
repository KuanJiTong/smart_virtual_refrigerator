import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/grocery_viewmodel.dart';
import '../models/grocery.dart';
import '../viewmodels/ingredient_viewmodel.dart';
import '../viewmodels/recipe_viewmodel.dart';

class GroceryListView extends StatefulWidget {
  const GroceryListView({super.key});

   @override
  State<GroceryListView> createState() => _GroceryListViewState();
}

class _GroceryListViewState extends State<GroceryListView> {
  bool _hasFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetched) {
      final groceryVM = Provider.of<GroceryListViewModel>(context, listen: false);
      groceryVM.fetchGroceries();
      _hasFetched = true;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<GroceryListViewModel>(
      builder: (context, groceryVM, _) {
        final items = groceryVM.groceryList;
        // Sort: unbought first, then bought
        final unboughtItems = items.where((item) => !item.bought).toList();
        final boughtItems = items.where((item) => item.bought).toList();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Grocery List'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () => groceryVM.clearList(),
                tooltip: 'Clear All',
              ),
            ],
          ),
          body: items.isEmpty
              ? const Center(child: Text('No items in grocery list'))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListView(
                    children: [
                      // Unbought items section
                      ...unboughtItems.map((item) => 
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Dismissible(
                            key: ValueKey('unbought_${item.name}_${item.quantity}_${item.unit}_${item.source}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => groceryVM.removeItem(item),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                onTap: () => groceryVM.toggleBought(item),
                                leading: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(item.imageUrl!, width: 40, height: 40, fit: BoxFit.cover),
                                      )
                                    : Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.yellow[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.shopping_cart, color: Colors.amber),
                                      ),
                                title: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    decoration: item.bought ? TextDecoration.lineThrough : null,
                                    color: item.bought ? Colors.grey : Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  '${item.quantity} ${item.unit} (${item.source})'
                                  + (item.expiryDate != null ? '\nExp: \'${item.expiryDate!.toLocal().toString().split(' ')[0]}' : ''),
                                  style: TextStyle(
                                    fontSize: 13,
                                    decoration: item.bought ? TextDecoration.lineThrough : null,
                                    color: item.bought ? Colors.grey : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ),
                      ),
                      // Bought items section
                      if (boughtItems.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 8),
                          child: Row(
                            children: const [
                              Icon(Icons.check_circle, color: Colors.grey, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Crossed Over',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        ...boughtItems.map((item) => 
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Dismissible(
                              key: ValueKey('bought_${item.name}_${item.quantity}_${item.unit}_${item.source}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (_) => groceryVM.removeItem(item),
                              child: Card(
                                color: Colors.grey[100],
                                elevation: 1,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  onTap: () => groceryVM.toggleBought(item),
                                  leading: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(item.imageUrl!, width: 40, height: 40, fit: BoxFit.cover),
                                        )
                                      : Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.shopping_cart, color: Colors.grey),
                                        ),
                                  title: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${item.quantity} ${item.unit} (${item.source})'
                                    + (item.expiryDate != null ? '\nExp: \'${item.expiryDate!.toLocal().toString().split(' ')[0]}' : ''),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ),
                      ),
                    ],
                  ]
                ),
              ),
              floatingActionButton: Builder(
              builder: (context) => FloatingActionButton(
              onPressed: () async {
                final ingredientVM = Provider.of<IngredientViewModel>(context, listen: false);
                final recipeVM = Provider.of<RecipeViewModel>(context, listen: false);
                final expiringIngredients = ingredientVM.expiringSoonIngredients;
                final favRecipes = recipeVM.favouriteRecipes;
                final Set<String> suggestions = {
                  ...expiringIngredients.map((e) => e.name),
                  ...favRecipes.expand((r) => r.ingredients.map((i) => i['name'] ?? '')),
                }..removeWhere((s) => s == null || s.isEmpty);

               String name = '';
                String quantity = '';
                String unit = '';
                final units = ['g', 'ml', 'pcs', 'cup', 'unit'];
                await showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Add Grocery Item'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                decoration: const InputDecoration(labelText: 'Name'),
                                onChanged: (val) => setState(() => name = val),
                              ),
                             const SizedBox(height: 16),
                              TextField(
                                decoration: const InputDecoration(labelText: 'Quantity'),
                                keyboardType: TextInputType.number,
                                onChanged: (val) => setState(() => quantity = val),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: unit.isNotEmpty ? unit : null,
                                items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                onChanged: (val) => setState(() => unit = val ?? ''),
                                decoration: const InputDecoration(labelText: 'Unit'),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: name.isNotEmpty && quantity.isNotEmpty && unit.isNotEmpty
                                  ? () async {
                                      await groceryVM.addItem(Grocery(
                                        name: name,
                                        quantity: quantity,
                                        unit: unit,
                                        source: 'manual',
                                      ));
                                      Navigator.pop(context);
                                    }
                                  : null,
                              child: const Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
              tooltip: 'Add Grocery',
            ),
          ),
        );
      },
    );
  }
} 