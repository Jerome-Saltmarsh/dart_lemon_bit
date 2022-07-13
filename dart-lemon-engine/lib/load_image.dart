
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';

Future<Image> loadImage(String url) async {
  final data = await rootBundle.load(url);
  final img = Uint8List.view(data.buffer);
  final completer = Completer<Image>();
  decodeImageFromList(img, (Image img) {
    return completer.complete(img);
  });
  return completer.future;
}