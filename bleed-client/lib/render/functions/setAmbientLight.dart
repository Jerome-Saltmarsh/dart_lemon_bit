

import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/render/functions/applyEnvironmentObjectsToBakeMapping.dart';
import 'package:bleed_client/render/functions/setBakeMapToAmbientLight.dart';
import 'package:bleed_client/watches/ambientLight.dart';

void setAmbientLightBright(){
  setAmbientLight(Shade.Bright);
}

void setAmbientLightMedium(){
  setAmbientLight(Shade.Medium);
}

void setAmbientLightDark(){
  setAmbientLight(Shade.Dark);
}

void setAmbientLightVeryDark(){
  setAmbientLight(Shade.VeryDark);
}

void setAmbientLight(Shade value){
  if (ambientLight == value) return;
  ambientLight = value;
  setBakeMapToAmbientLight();
  applyEnvironmentObjectsToBakeMapping();

  if (value == Shade.Bright){
    images.torch = images.torchOut;
  }
}