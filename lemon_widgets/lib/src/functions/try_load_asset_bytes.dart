
import 'package:flutter/services.dart';

Future<Uint8List?> tryLoadAssetBytes(String url) async {
  try {
    final byteData = await rootBundle.load(url);
    return Uint8List.view(byteData.buffer);
  } catch(_) {
    return null;
  }
}