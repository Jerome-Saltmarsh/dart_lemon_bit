

import 'package:bleed_client/common/ObjectType.dart';
import 'package:bleed_client/state.dart';

void removeGeneratedEnvironmentObjects(){
  print("removeGeneratedEnvironmentObjects()");
  compiledGame.environmentObjects.removeWhere((env) => isGeneratedAtBuild(env.type));
}