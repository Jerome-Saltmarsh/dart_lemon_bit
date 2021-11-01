

import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/render/functions/applyEnvironmentObjectsToBakeMapping.dart';
import 'package:bleed_client/render/functions/setBakeMapToAmbientLight.dart';
import 'package:bleed_client/variables/ambientLight.dart';

void setAmbientLight(Shading value){
  if (ambientLight == value) return;
  ambientLight = value;
  setBakeMapToAmbientLight();
  applyEnvironmentObjectsToBakeMapping();
}