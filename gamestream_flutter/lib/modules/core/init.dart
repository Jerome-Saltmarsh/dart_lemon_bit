import 'dart:async';

import 'package:gamestream_flutter/atlases.dart';
import 'package:gamestream_flutter/website/website.dart';
import 'package:lemon_engine/engine.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future init(SharedPreferences sharedPreferences) async {
  Images.characters = await Engine.loadImageAsset('images/atlas-characters.png');
  Images.zombie = await Engine.loadImageAsset('images/atlas-zombie.png');
  Images.templateShadow = await Engine.loadImageAsset('images/template/template-shadow.png');
  Images.mapAtlas = await Engine.loadImageAsset('images/atlas-map.png');
  Images.blocks = await Engine.loadImageAsset('images/atlas-blocks.png');
  ImagesTemplateHead.plain = await Engine.loadImageAsset('images/template/head/template-head-plain.png');
  ImagesTemplateHead.rogue = await Engine.loadImageAsset('images/template/head/template-head-rogue.png');
  ImagesTemplateHead.steel = await Engine.loadImageAsset('images/template/head/template-head-steel.png');
  ImagesTemplateHead.swat = await Engine.loadImageAsset('images/template/head/template-head-swat.png');
  ImagesTemplateHead.wizard = await Engine.loadImageAsset('images/template/head/template-head-wizard.png');
  ImagesTemplateBody.blue = await Engine.loadImageAsset('images/template/body/template-body-blue.png');
  ImagesTemplateBody.tunic = await Engine.loadImageAsset('images/template/body/template-body-tunic.png');
  ImagesTemplateLegs.blue = await Engine.loadImageAsset('images/template/legs/template-legs-blue.png');
  ImagesTemplateLegs.white = await Engine.loadImageAsset('images/template/legs/template-legs-white.png');
  ImagesTemplateWeapons.bow = await Engine.loadImageAsset('images/template/weapons/template-weapons-bow.png');
  ImagesTemplateWeapons.handgun = await Engine.loadImageAsset('images/template/weapons/template-weapons-handgun.png');
  ImagesTemplateWeapons.shotgun = await Engine.loadImageAsset('images/template/weapons/template-weapons-shotgun.png');
  Engine.cursorType.value = CursorType.Basic;
  print("environment: ${Engine.isLocalHost ? 'localhost' : 'production'}");
  Engine.onDrawCanvas = Website.renderCanvas;
}

