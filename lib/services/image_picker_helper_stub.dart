import 'dart:async';
import 'dart:typed_data';

class ImageFileResult {
  final Uint8List bytes;
  final String name;
  ImageFileResult(this.bytes, this.name);
}

Future<ImageFileResult?> pickImageFile() async {
  // Non-web fallback returns null
  return null;
}
