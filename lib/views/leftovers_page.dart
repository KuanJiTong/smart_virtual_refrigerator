import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/fridge_viewmodel.dart';

class LeftoversPage extends StatelessWidget {
  const LeftoversPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FridgeViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Leftovers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: vm.allLeftovers.length,
          itemBuilder: (context, index) {
            final leftover = vm.allLeftovers[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/${leftover['image']}',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leftover['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(leftover['date'], style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text(
                    leftover['quantity'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
