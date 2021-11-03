import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/functions/applyLightMedium.dart';
import 'package:bleed_client/render/drawCanvas.dart';
import 'package:bleed_client/render/functions/applyLightBright.dart';
import 'package:bleed_client/variables/lantern.dart';

void applyCharacterLightEmission(List<Character> characters) {
  for (Character character in characters) {
    if (lantern){
      applyLightBright(render.dynamicShading, character.x, character.y);
    }else{
      applyLightMedium(render.dynamicShading, character.x, character.y);
    }
  }
}
