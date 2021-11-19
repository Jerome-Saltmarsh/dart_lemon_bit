import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/functions/applyLightMedium.dart';
import 'package:bleed_client/render/functions/applyLightBright.dart';
import 'package:bleed_client/render/state/bakeMap.dart';
import 'package:bleed_client/state/game.dart';

void applyEnvironmentObjectsToBakeMapping(){
  for (EnvironmentObject env in game.environmentObjects){
    if (env.type == ObjectType.Torch){
      applyLightBrightMedium(bakeMap, env.x, env.y);
    }
    if (env.type == ObjectType.House01){
      applyLightMedium(bakeMap, env.x, env.y);
    }
    if (env.type == ObjectType.House02){
      applyLightMedium(bakeMap, env.x, env.y);
    }
  }
}
