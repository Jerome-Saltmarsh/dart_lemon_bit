
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/render/functions/emitLight.dart';
import 'package:bleed_client/render/state/bakeMap.dart';
import 'package:bleed_client/state/game.dart';

class GameActions {

  void applyEnvironmentObjectsToBakeMapping(){
    for (EnvironmentObject env in game.environmentObjects){
      if (env.type == ObjectType.Torch){
        emitLightHigh(bakeMap, env.x, env.y);
        continue;
      }
      if (env.type == ObjectType.House01){
        emitLightLow(bakeMap, env.x, env.y);
        continue;
      }
      if (env.type == ObjectType.House02){
        emitLightLow(bakeMap, env.x, env.y);
        continue;
      }
    }
  }

}