import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/viewmodels/admin_dashboard_viewmodel.dart';
import '../models/recipe.dart';
import '../services/auth_service.dart'; // adjust path to your actual AuthService

class InstructionPage extends StatefulWidget {
  final Recipe recipe;

  const InstructionPage({Key? key, required this.recipe}) : super(key: key);

  @override
  State<InstructionPage> createState() => _InstructionPageState();
}

class _InstructionPageState extends State<InstructionPage> {
  bool isAdmin = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => checkAdminStatus());
  }

  Future<void> checkAdminStatus() async {
    bool result = await AuthService().isCurrentUserAdmin();
    setState(() {
      isAdmin = result;
      isLoading = false;
    });
  }

  void _handleSuccess(String message) {
    Navigator.pop(context); 
    Navigator.pop(context); 
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showRejectionDialog() {
    final TextEditingController _reasonController = TextEditingController();
    final vm = Provider.of<AdminDashboardViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reject Recipe"),
          content: TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              hintText: "Enter rejection reason",
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String reason = _reasonController.text.trim();
                if (reason.isNotEmpty) {
                  Navigator.of(context).pop(); 
                  vm.rejectRecipe(widget.recipe.id,reason);
                  _handleSuccess("Recipe rejected successfully.");
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AdminDashboardViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Instructions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.recipe.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
            const Text(
              "Manual",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.recipe.cookingSteps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "• $step",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const Spacer(),
            if (!isLoading && isAdmin)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      vm.approveRecipe(widget.recipe.id);
                      _handleSuccess("Recipe rejected successfully.");
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("Approve"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showRejectionDialog,
                    icon: const Icon(Icons.close),
                    label: const Text("Reject"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
