import 'package:gamestream_flutter/isometric/floating_texts.dart';
import 'package:lemon_engine/engine.dart';

void renderFloatingTexts() {
  for (final floatingText in floatingTexts) {
    if (floatingText.duration <= 0) continue;
    floatingText.duration--;
    renderText(
        text: floatingText.value,
        x: floatingText.x,
        y: floatingText.y
    );
    floatingText.y -= 1;
    floatingText.x += floatingText.xv;
  }
}

void renderText({required String text, required double x, required double y}){
  if (!engine.screen.contains(x, y)) return;
  const charWidth = 4.5;
  engine.writeText(text, x - charWidth * text.length, y);
}

