import 'package:gamestream_flutter/game_state.dart';
import 'package:lemon_engine/engine.dart';

void renderFloatingTexts() {
  for (final floatingText in GameState.floatingTexts) {
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
  if (!Engine.screen.contains(x, y)) return;
  const charWidth = 4.5;
  Engine.writeText(text, x - charWidth * text.length, y);
}

