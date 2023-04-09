import 'package:lemon_engine/lemon_engine.dart';

void renderText({required String text, required double x, required double y}){
  // if (!Engine.screen.contains(x, y)) return;
  const charWidth = 4.5;
  Engine.writeText(text, x - charWidth * text.length, y);
}

