import 'package:gamestream_flutter/gamestream/isometric/classes/sprite.dart';

class SpriteGroup {
  final Sprite idle;
  final Sprite running;
  final Sprite strike;
  final Sprite hurt;
  final Sprite death;
  final Sprite fire;

  SpriteGroup({
    required this.idle,
    required this.running,
    required this.strike,
    required this.hurt,
    required this.death,
    required this.fire,
  });
}
