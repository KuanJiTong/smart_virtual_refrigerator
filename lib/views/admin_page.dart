import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../viewmodels/login_viewmodel.dart';
import 'login_view.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = {
      'Users': 145,
      'Recipes': 320,
      'Pending Recipes': 7,
    };
    final signout = Provider.of<LoginViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await signout.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              },
              tooltip: 'Logout',
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: stats.entries.map((entry) {
                  return _buildStatCard(entry.key, entry.value.toString());
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/approveRecipes');
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Review Pending Recipes'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/createRecipe');
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add New Community Recipe'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _triggerRetrain(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Retrain Recommendation System'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 8,
            offset: const Offset(2, 2),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _triggerRetrain(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse('https://smart-virtual-refridgerator-ai.onrender.com/retrain'),
      );

      navigator.pop(); // Remove the loading dialog

      if (response.statusCode == 200) {
        scaffold.showSnackBar(
          const SnackBar(content: Text('Model retrained successfully!')),
        );
      } else {
        scaffold.showSnackBar(
          SnackBar(content: Text('Failed to retrain: ${response.body}')),
        );
      }
    } catch (e) {
      navigator.pop();
      scaffold.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
