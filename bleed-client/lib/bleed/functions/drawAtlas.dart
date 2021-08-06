
import 'dart:ui' as ui;

import 'dart:ui';

import 'package:flutter_game_engine/game_engine/engine_state.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

void drawAtlas(ui.Image image, List<RSTransform> transforms, List<Rect> rects){
  globalCanvas.drawAtlas(image, transforms, rects, null, null, null, globalPaint);
}