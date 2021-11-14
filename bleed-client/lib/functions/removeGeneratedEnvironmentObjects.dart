

import 'package:bleed_client/common/ObjectType.dart';
import 'package:bleed_client/state/game.dart';

void removeGeneratedEnvironmentObjects(){
  print("removeGeneratedEnvironmentObjects()");
  game.environmentObjects.removeWhere((env) => isGeneratedAtBuild(env.type));
}