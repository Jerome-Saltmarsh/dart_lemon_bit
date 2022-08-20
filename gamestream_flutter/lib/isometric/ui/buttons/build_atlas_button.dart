


import 'package:flutter/widgets.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:lemon_engine/render_single_atlas.dart';
import 'package:lemon_engine/state/atlas.dart';

Widget buildCanvasImage({
    required double srcX,
    required double srcY,
    required double srcWidth,
    required double srcHeight,
}){
  return buildCanvas(
    paint: (Canvas canvas, Size size){
      canvasRenderAtlas(
        canvas: canvas,
        atlas: atlas,
        srcX: srcX,
        srcY: srcY,
        srcWidth: srcWidth,
        srcHeight: srcHeight,
        dstX: 0,
        dstY: 0,
      );
    },
  );
}
