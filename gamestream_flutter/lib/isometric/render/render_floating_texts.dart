import 'package:gamestream_flutter/instances/engine.dart';

void renderText({required String text, required double x, required double y}){
  // if (!engine.screen.contains(x, y)) return;
  const charWidth = 4.5;
  engine.writeText(text, x - charWidth * text.length, y);
}

