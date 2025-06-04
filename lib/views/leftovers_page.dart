import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/views/update_leftover_view.dart';
import '../viewmodels/fridge_viewmodel.dart';

class LeftoversPage extends StatefulWidget {
  final List<Map<String, dynamic>> leftovers;

  const LeftoversPage({super.key, required this.leftovers});

  @override
  State<LeftoversPage> createState() => _LeftoversPageState();
}

class _LeftoversPageState extends State<LeftoversPage> {
  late List<Map<String, dynamic>> leftovers;

  @override
  void initState() {
    super.initState();
    leftovers = widget.leftovers;
  }

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
          itemCount: leftovers.length,
          itemBuilder: (context, index) {
            final leftover = leftovers[index];
            final imageUrl = (leftover['imageUrl'] as String?) ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UpdateLeftoverView(leftover: leftover),
                  ),
                );

                if (result == true) {
                  Navigator.pop(context, true);
                }
              },
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _placeholderImage();
                            },
                          )
                        : _placeholderImage(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leftover['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          leftover['expiryDate'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    leftover['quantity'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),            
            );
          },
        ),
      ),
    );
  }

  // Placeholder widget for missing or invalid images
  Widget _placeholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported, size: 40),
    );
  }
}