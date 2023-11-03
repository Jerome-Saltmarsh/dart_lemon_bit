

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Future<ui.Image> captureCanvasToImage(GlobalKey key, {double pixelRatio = 1.0}) async {
  final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary;
  return await boundary.toImage(pixelRatio: pixelRatio);
}

Future<Uint8List> convertImageToBytesPng(ui.Image image) async {
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png) ?? (throw Exception());
  return byteData.buffer.asUint8List();
}