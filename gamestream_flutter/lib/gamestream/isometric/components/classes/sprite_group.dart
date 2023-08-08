import 'package:gamestream_flutter/gamestream/isometric/classes/sprite.dart';

class SpriteGroup {
  final Sprite idle;
  final Sprite running;
  final Sprite strike;

  SpriteGroup({
    required this.idle,
    required this.running,
    required this.strike,
  });
}
