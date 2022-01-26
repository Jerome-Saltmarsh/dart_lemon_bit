

import 'package:bleed_client/common/ObjectType.dart';
import 'package:bleed_client/modules/modules.dart';

void removeGeneratedEnvironmentObjects(){
  print("removeGeneratedEnvironmentObjects()");
  modules.isometric.state.environmentObjects.removeWhere((env) => isGeneratedAtBuild(env.type));
}