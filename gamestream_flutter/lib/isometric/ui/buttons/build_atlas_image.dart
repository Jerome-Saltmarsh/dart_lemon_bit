


import 'package:flutter/widgets.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:lemon_engine/render_single_atlas.dart';
import 'package:lemon_engine/state/atlas.dart';

Widget buildAtlasImageButton({
  required double srcX,
  required double srcY,
  required double srcWidth,
  required double srcHeight,
  required Function? action,
  double scale = 1.0,
}) =>
  onPressed(
    action: action,
    child: onPressed(
      action: action,
      child: Container(
        width: srcWidth,
        height: srcHeight,
        child: buildAtlasImage(
            srcX: srcX,
            srcY: srcY,
            srcWidth: srcWidth,
            srcHeight: srcHeight,
            scale: scale,
        ),
      ),
    ),
  );

Widget buildAtlasImage({
    required double srcX,
    required double srcY,
    required double srcWidth,
    required double srcHeight,
    double scale = 1.0,
}) =>
  Container(
    alignment: Alignment.center,
    width: srcWidth,
    height: srcHeight,
    child: buildCanvas(
      paint: (Canvas canvas, Size size) =>
        canvasRenderAtlas(
          canvas: canvas,
          atlas: atlas,
          srcX: srcX,
          srcY: srcY,
          srcWidth: srcWidth,
          srcHeight: srcHeight,
          dstX: 0,
          dstY: 0,
          scale: scale,
        )
    ),
  );
