import 'package:flutter/material.dart';

void showNoteDialog(BuildContext context, String name, String noteText) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.sticky_note_2_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Note of $name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          noteText,
          style: TextStyle(fontSize: 16, height: 1.4),
        ),
        actionsPadding: EdgeInsets.only(right: 8, bottom: 8),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close),
            label: Text('Close'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.deepOrange,
            ),
          ),
        ],
      );
    },
  );
}

