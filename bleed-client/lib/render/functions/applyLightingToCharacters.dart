import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/render/functions/applyLightBright.dart';
import 'package:bleed_client/render/state/dynamicShading.dart';
import 'package:bleed_client/variables/ambientLight.dart';
import 'package:bleed_client/variables/lantern.dart';

void applyCharacterLightEmission(List<Character> characters) {
  if (ambientLight.index <= Shading.Bright.index) return;

  for (Character character in characters) {
    if (lantern){
      applyLightBrightSmall(dynamicShading, character.x, character.y);
    } else {
      // applyLightMedium(dynamicShading, character.x, character.y);
    }
  }
}
