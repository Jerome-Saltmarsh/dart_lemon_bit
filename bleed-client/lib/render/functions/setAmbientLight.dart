

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/render/functions/applyEnvironmentObjectsToBakeMapping.dart';
import 'package:bleed_client/render/functions/setBakeMapToAmbientLight.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/variables/ambientLight.dart';

void setAmbientLight(Shading value){
  if (ambientLight == value) return;
  ambientLight = value;
  setBakeMapToAmbientLight();
  applyEnvironmentObjectsToBakeMapping();

  if (value == Shading.Bright){
    for (EnvironmentObject torch in compiledGame.torches) {
      torch.image = images.torchOut;
    }
  }
}