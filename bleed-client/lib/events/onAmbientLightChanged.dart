

import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/render/functions/applyDynamicShadeToTileSrc.dart';
import 'package:bleed_client/render/functions/applyEnvironmentObjectsToBakeMapping.dart';
import 'package:bleed_client/render/functions/resetDynamicShadesToBakeMap.dart';
import 'package:bleed_client/render/functions/setBakeMapToAmbientLight.dart';

void onAmbientLightChanged(Shade value){
  print("onAmbientLightChanged($value)");
  setBakeMapToAmbientLight();
  resetDynamicShadesToBakeMap();
  applyDynamicShadeToTileSrc();
  applyEnvironmentObjectsToBakeMapping();
}
