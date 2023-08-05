
import 'package:flutter/services.dart';

Future<Uint8List> loadAssetBytes(String url) async {
  final byteData = await rootBundle.load(url);
  return Uint8List.view(byteData.buffer);
}