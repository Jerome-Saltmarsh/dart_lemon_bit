
import 'package:gamestream_flutter/game_images.dart';
import 'package:gamestream_flutter/instances/engine.dart';

void renderBoxYellow64(double x, double y){
  engine.renderSprite(
    image: GameImages.atlas_gameobjects,
    dstX: x,
    dstY: y,
    srcX: 560,
    srcY: 0,
    srcWidth: 64,
    srcHeight: 64,
    scale: 0.7,
  );
}