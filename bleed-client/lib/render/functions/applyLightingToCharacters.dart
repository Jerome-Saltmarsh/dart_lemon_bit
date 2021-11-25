import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/render/functions/emitLight.dart';
import 'package:bleed_client/render/state/dynamicShading.dart';
import 'package:bleed_client/variables/lantern.dart';

void applyCharacterLightEmission(List<Character> characters) {
  switch(lantern){
    case LanternMode.Off:
      break;
    case LanternMode.Low:
      for (Character character in characters) {
        emitLightLow(dynamicShading, character.x, character.y);
      }
      break;
    case LanternMode.Medium:
      for (Character character in characters) {
        emitLightMedium(dynamicShading, character.x, character.y);
      }
      break;
    case LanternMode.High:
      for (Character character in characters) {
        emitLightHigh(dynamicShading, character.x, character.y);
      }
      break;
  }

}

void applyNpcLightEmission(List<Character> characters) {
  for (Character character in characters) {
    emitLightMedium(dynamicShading, character.x, character.y);
  }
}
