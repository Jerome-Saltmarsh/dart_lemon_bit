import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/render/functions/emitLight.dart';
import 'package:bleed_client/render/state/dynamicShading.dart';
import 'package:bleed_client/state/game.dart';

void applyCharacterLightEmission(List<Character> characters) {
  for(Character character in characters){
    if (character.team == game.player.team){
      emitLightHigh(modules.game.state.dynamicShading, character.x, character.y);
    }
  }
}

void applyNpcLightEmission(List<Character> characters) {
  final dynamicShading = modules.game.state.dynamicShading;
  for (Character character in characters) {
    emitLightMedium(dynamicShading, character.x, character.y);
  }
}
