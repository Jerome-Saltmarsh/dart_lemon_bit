


import 'package:flutter/widgets.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:lemon_engine/engine.dart';
import 'dart:ui' as ui;

Widget buildAtlasImageButton({
  required ui.Image image,
  required double srcX,
  required double srcY,
  required double srcWidth,
  required double srcHeight,
  required Function? action,
  double scale = 1.0,
  String hint = "",
}) =>
  onPressed(
    action: action,
    hint: hint,
    child: onPressed(
      action: action,
      hint: hint,
      child: Container(
        width: srcWidth,
        height: srcHeight,
        child: buildAtlasImage(
            image: image,
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
    required ui.Image image,
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
        Engine.renderExternalCanvas(
          canvas: canvas,
          image: image,
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
