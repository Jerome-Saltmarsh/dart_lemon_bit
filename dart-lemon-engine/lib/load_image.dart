
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';

Future<Image> loadImage(String url) async {
  final byteData = await rootBundle.load(url);
  final bytes = Uint8List.view(byteData.buffer);
  final codec = await instantiateImageCodec(bytes);
  final frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

// Future loaderImage(String url, ImageDecoderCallback callback) async {
//   final img =  await loadImageBytes(url);
//   decodeImageFromList(img, callback);
// }
//
// Future<Uint8List> loadImageBytes(String url) async {
//   final data = await rootBundle.load(url);
//   return Uint8List.view(data.buffer);
// }
//
// void engineMakeImage(ImageDecoderCallback callback) {
//   int len = 256 * 256 * 4;
//   final pixels = Uint8List(len);
//   for (int i = 0; i < pixels.length; i++) {
//     pixels[i] = Random().nextInt(255);
//   }
//   decodeImageFromPixels(pixels, 256, 256, PixelFormat.rgba8888, callback);
// }