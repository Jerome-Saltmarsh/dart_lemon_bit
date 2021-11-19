import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/render/functions/applyLightBright.dart';
import 'package:bleed_client/render/state/dynamicShading.dart';

void applyCharacterLightEmission(List<Character> characters) {
  for (Character character in characters) {
    applyLightBrightSmall(dynamicShading, character.x, character.y);
  }
}

void applyNpcLightEmission(List<Character> characters) {
  for (Character character in characters) {
    applyLightBright2Small(dynamicShading, character.x, character.y);
  }
}
