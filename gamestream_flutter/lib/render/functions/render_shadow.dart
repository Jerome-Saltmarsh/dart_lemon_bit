import 'package:gamestream_flutter/library.dart';

void renderShadow(double x, double y, double z, {double scale = 1}) =>
    Engine.renderSprite(
      image: GameImages.atlas_gameobjects,
      dstX: (x - y) * 0.5,
      dstY: ((y + x) * 0.5) - z,
      srcX: 0,
      srcY: 32,
      srcWidth: 8,
      srcHeight: 8,
      scale: scale,
    );
