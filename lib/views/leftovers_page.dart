import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_virtual_refrigerator/models/leftover.dart';
import 'package:smart_virtual_refrigerator/utils/popup.dart';
import 'package:smart_virtual_refrigerator/viewmodels/leftover_viewmodel.dart';
import 'package:smart_virtual_refrigerator/views/update_leftover_view.dart';
import '../viewmodels/fridge_viewmodel.dart';

class LeftoversPage extends StatefulWidget {
  final List<Map<String, dynamic>> leftovers;

  const LeftoversPage({super.key, required this.leftovers});

  @override
  State<LeftoversPage> createState() => _LeftoversPageState();
}

class _LeftoversPageState extends State<LeftoversPage> {
  bool _deleted = false;
  late List<Map<String, dynamic>> leftovers;

  @override
  void initState() {
    super.initState();
    leftovers = widget.leftovers;
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LeftoverViewModel>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _deleted); // return true if deleted
        return false; // prevent default pop
      },
      child: Scaffold(
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
              final name = leftover['name'];
              final notes = leftover['notes'];
              final category = leftover['category'];
              final location = leftover['location'];
              final expiryDate = leftover['expiryDate'];
              final dayToExpiry = DateTime.parse(expiryDate).difference(DateTime.now()).inDays;
              final isExpired = dayToExpiry < 0;
      
              return Dismissible(
                key: Key(leftover['id'].toString()), 
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Icon(Icons.delete_forever, color: Colors.white, size: 26),
                      SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                onDismissed: (direction) {
                  setState(() {
                    vm.deleteLeftover(leftover['id']);
                    leftovers.removeAt(index); 
                    _deleted = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${leftover['name']} deleted')),
                  );
                },
                child: Container(
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
                      Stack(
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
                          if (notes != null && notes.isNotEmpty)
                          Positioned(
                            top: 4.0,
                            left: 4.0,
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
                          )
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Category: $category',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Location: $location',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 1),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: isExpired
                                        ? const Color(0xFFE85C5C) // expired
                                        : dayToExpiry <= 2
                                            ? const Color(0xFFFF9800) // almost expired
                                            : Colors.grey,  
                                  size: 16,
                                ),
                                const SizedBox(width: 4), // Small space between icon and text
                                Padding(
                                  padding: const EdgeInsets.only(top: 1.8),
                                  child: Text(
                                    '$expiryDate (${isExpired ? 'Expired' : '$dayToExpiry day${dayToExpiry == 1 ? '' : 's'} left'})',
                                    style: TextStyle(
                                      color: isExpired
                                              ? const Color(0xFFE85C5C) // expired
                                              : dayToExpiry <= 2
                                                  ? const Color(0xFFFF9800) // almost expired
                                                  : Colors.grey,                                
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
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
                ),
              );
            },
          ),
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