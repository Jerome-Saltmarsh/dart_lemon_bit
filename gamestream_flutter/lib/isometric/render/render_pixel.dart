import 'package:gamestream_flutter/classes/library.dart';
import 'package:gamestream_flutter/game_images.dart';
import 'package:lemon_engine/engine.dart';

void renderPixelRedV2(Vector3 value) {
  renderPixelRed(value.renderX, value.renderY);
}

void renderPixelRed(double x, double y) {
  Engine.renderSprite(
      image: GameImages.atlas_gameobjects,
      dstX: x,
      dstY: y,
      srcX: 144,
      srcY: 0,
      srcWidth: 8,
      srcHeight: 8,
      anchorX: 0.5,
      anchorY: 0.5);
}
