import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/viewmodels/user_viewmodel.dart';
import '../models/recipe.dart';
import '../viewmodels/admin_dashboard_viewmodel.dart';
import 'recipe_details_page.dart'; // Reuse your detail page

class ReviewPendingRecipePage extends StatefulWidget {
  const ReviewPendingRecipePage({super.key});

  @override
  State<ReviewPendingRecipePage> createState() => _ReviewPendingRecipePageState();
}

class _ReviewPendingRecipePageState extends State<ReviewPendingRecipePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<AdminDashboardViewModel>(context, listen: false).fetchPendingRecipes();
  }

  @override
  Widget build(BuildContext context) {

    final vm = Provider.of<AdminDashboardViewModel>(context, listen: false);

    return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserViewModel()..fetchAllUsers())
    ],
    
    child: Scaffold(
      appBar: AppBar(title: const Text('Review Pending Recipes')),
      body: Consumer<AdminDashboardViewModel>(
        builder: (context, vm, _) {
          final userViewModel = Provider.of<UserViewModel>(context);
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.pendingRecipes.isEmpty) {
            return const Center(child: Text('No pending recipes.'));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: vm.pendingRecipes.map((recipe) {
                        final userName = userViewModel.getUserName(recipe.userId);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 3,
                child: ListTile(
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
                  subtitle: Text('Shared by $userName'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () async {
                          vm.approveRecipe(recipe.id);
                          vm.fetchPendingRecipes();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () async {
                          final reason = await _showRejectDialog(context);
                          if (reason != null && reason.trim().isNotEmpty) {
                            await vm.rejectRecipe(recipe.id, reason.trim());
                            await vm.fetchPendingRecipes();
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailsPage(recipe: recipe),
                      ),
                    );
                    if (updated == true) {
                      await Provider.of<AdminDashboardViewModel>(context, listen: false).fetchPendingRecipes();
                    }
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    )
    );
  }

  Future<String?> _showRejectDialog(BuildContext context) async {
    final controller = TextEditingController();
    String? errorText;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reject Reason'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter reason for rejection...',
                      border: const OutlineInputBorder(),
                      errorText: errorText,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text('Reject'),
                  onPressed: () {
                    final reason = controller.text.trim();
                    if (reason.isEmpty) {
                      setState(() {
                        errorText = 'Reason cannot be empty';
                      });
                    } else {
                      Navigator.pop(context, reason);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

}
