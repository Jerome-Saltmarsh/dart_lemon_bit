
import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';

Future<Image> loadImage(String url) async {
  final byteData = await rootBundle.load(url);
  final bytes = Uint8List.view(byteData.buffer);
  final codec = await instantiateImageCodec(bytes);
  final frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}
