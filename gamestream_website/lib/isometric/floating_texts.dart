
import 'package:gamestream_flutter/isometric/classes/floating_text.dart';
import 'package:lemon_math/library.dart';

final floatingTexts = <FloatingText>[];

void spawnFloatingText(double x, double y, String text) {
  final floatingText = _getFloatingTextInstance();
  floatingText.duration = 50;
  floatingText.x = x;
  floatingText.y = y;
  floatingText.xv = giveOrTake(0.2);
  floatingText.value = text;
}

FloatingText _getFloatingTextInstance(){
  for (final floatingText in floatingTexts) {
    if (floatingText.duration > 0) continue;
    return floatingText;
  }
  final instance = FloatingText();
  floatingTexts.add(instance);
  return instance;
}