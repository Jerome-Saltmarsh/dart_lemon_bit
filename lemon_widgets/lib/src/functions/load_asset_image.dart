
import 'dart:ui';

import 'package:lemon_widgets/src/functions/load_asset_bytes.dart';

import 'build_image_from_bytes.dart';

Future<Image> loadImageAsset(String url) async {
  final bytes = await loadAssetBytes(url);
  return await buildImageFromBytes(bytes);
}
