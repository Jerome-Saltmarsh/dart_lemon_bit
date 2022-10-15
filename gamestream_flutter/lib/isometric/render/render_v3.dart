import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/render/get_character_render_color.dart';
import 'package:lemon_engine/render.dart';

void renderV3({
  required Vector3 value,
  required double srcX,
  required double srcWidth,
  required double srcHeight,
  double srcY = 0,
}) =>
    renderBuffer(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: srcX,
      srcY: srcY,
      srcWidth: srcWidth,
      srcHeight: srcHeight,
      color: getNodeBelowShade(value),
    );
