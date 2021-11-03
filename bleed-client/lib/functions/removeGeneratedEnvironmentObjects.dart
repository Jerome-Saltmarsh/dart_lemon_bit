

import 'package:bleed_client/common/ObjectType.dart';
import 'package:bleed_client/state/environmentObjects.dart';

void removeGeneratedEnvironmentObjects(){
  print("removeGeneratedEnvironmentObjects()");
  environmentObjects.removeWhere((env) => isGeneratedAtBuild(env.type));
}