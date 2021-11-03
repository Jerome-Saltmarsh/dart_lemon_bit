

import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/render/functions/applyEnvironmentObjectsToBakeMapping.dart';
import 'package:bleed_client/render/functions/setBakeMapToAmbientLight.dart';
import 'package:bleed_client/variables/ambientLight.dart';

void setAmbientLightBright(){
  setAmbientLight(Shading.Bright);
}

void setAmbientLightMedium(){
  setAmbientLight(Shading.Medium);
}

void setAmbientLightDark(){
  setAmbientLight(Shading.Dark);
}

void setAmbientLightVeryDark(){
  setAmbientLight(Shading.VeryDark);
}

void setAmbientLight(Shading value){
  if (ambientLight == value) return;
  ambientLight = value;
  setBakeMapToAmbientLight();
  applyEnvironmentObjectsToBakeMapping();

  if (value == Shading.Bright){
    images.torch = images.torchOut;
  }
}