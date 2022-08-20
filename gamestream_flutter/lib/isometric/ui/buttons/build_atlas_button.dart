


import 'package:flutter/widgets.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:lemon_engine/render_single_atlas.dart';
import 'package:lemon_engine/state/atlas.dart';

Widget buildAtlasButton(){
  return buildCanvas(
      paint: (Canvas canvas, Size size){
        canvasRenderAtlas(
          canvas: canvas,
          atlas: atlas,
          srcX: 0,
          srcY: 0,
          srcWidth: 50,
          srcHeight: 50,
          dstX: 0,
          dstY: 0,
        );
      },
  );
}