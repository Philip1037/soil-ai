import 'package:flutter/material.dart';

void downloadFile({
  required String filename,
  required List<int> bytes,
  required String mimeType,
  required BuildContext context,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Simulated download of $filename successful.'),
      backgroundColor: const Color(0xFF4CD7F6),
    ),
  );
}
