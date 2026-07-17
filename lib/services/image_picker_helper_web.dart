import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

class ImageFileResult {
  final Uint8List bytes;
  final String name;
  ImageFileResult(this.bytes, this.name);
}

Future<ImageFileResult?> pickImageFile() {
  final completer = Completer<ImageFileResult?>();
  final uploadInput = html.FileUploadInputElement();
  uploadInput.accept = 'image/*,application/pdf';
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((e) {
        final bytes = reader.result as Uint8List;
        completer.complete(ImageFileResult(bytes, file.name));
      });
    } else {
      completer.complete(null);
    }
  });

  return completer.future;
}
