import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:lemon_engine/render.dart';

void renderGameObject(GameObject value) {
  render(
     dstX: value.renderX,
     dstY: value.renderY,
     srcX: 1664,
     srcY: 0,
     srcWidth: 16,
     srcHeight: 16,
  );
}
