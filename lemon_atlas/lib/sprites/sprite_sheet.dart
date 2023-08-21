import 'dart:typed_data';

import 'package:image/image.dart';

class SpriteSheet {
  final Image image;
  final Uint8List bounds;
  final String name;

  SpriteSheet({
    required this.image,
    required this.bounds,
    required this.name,
  });
}
