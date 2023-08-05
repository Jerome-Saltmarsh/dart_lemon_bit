import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:lemon_engine/src/functions/load_image_from_bytes.dart';

Future<Image> loadImageAsset(String url) async {
  final byteData = await rootBundle.load(url);
  final bytes = Uint8List.view(byteData.buffer);
  return await loadImageFromBytes(bytes);
}
