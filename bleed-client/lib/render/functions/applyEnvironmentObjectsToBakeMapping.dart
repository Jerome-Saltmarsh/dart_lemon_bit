import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:bleed_client/functions/applyLightMedium.dart';
import 'package:bleed_client/render/functions/applyLightBright.dart';
import 'package:bleed_client/render/state/bakeMap.dart';
import 'package:bleed_client/state.dart';

void applyEnvironmentObjectsToBakeMapping(){
  for (EnvironmentObject env in compiledGame.environmentObjects){
    if (env.type == EnvironmentObjectType.Torch){
      compiledGame.torches.add(env);
      applyLightBright(bakeMap, env.x, env.y);
    }
    if (env.type == EnvironmentObjectType.House01){
      applyLightMedium(bakeMap, env.x, env.y);
    }
    if (env.type == EnvironmentObjectType.House02){
      applyLightMedium(bakeMap, env.x, env.y);
    }
  }
}
