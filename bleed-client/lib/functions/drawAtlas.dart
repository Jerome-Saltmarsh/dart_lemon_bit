
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/game_engine/global_paint.dart';

void drawAtlas(ui.Image image, List<RSTransform> transforms, List<Rect> rects){
  globalCanvas.drawAtlas(image, transforms, rects, null, null, null, globalPaint);
}