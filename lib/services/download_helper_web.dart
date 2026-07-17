// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';

void downloadFile({
  required String filename,
  required List<int> bytes,
  required String mimeType,
  required BuildContext context,
}) {
  final blob = html.Blob([Uint8List.fromList(bytes)], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute("download", filename)
    ..click();
  html.Url.revokeObjectUrl(url);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Downloaded $filename successfully.'),
      backgroundColor: const Color(0xFF4CD7F6),
    ),
  );
}
