import 'dart:async';

import 'package:gamestream_flutter/atlases.dart';
import 'package:gamestream_flutter/website/website.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/load_image.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future init(SharedPreferences sharedPreferences) async {
  Images.characters = await loadImage('images/atlas-characters.png');
  Images.zombie = await loadImage('images/atlas-zombie.png');
  Images.templateShadow = await loadImage('images/template/template-shadow.png');
  Images.mapAtlas = await loadImage('images/atlas-map.png');
  Images.blocks = await loadImage('images/atlas-blocks.png');
  ImagesTemplateHead.plain = await loadImage('images/template/head/template-head-plain.png');
  ImagesTemplateHead.rogue = await loadImage('images/template/head/template-head-rogue.png');
  ImagesTemplateHead.steel = await loadImage('images/template/head/template-head-steel.png');
  ImagesTemplateHead.swat = await loadImage('images/template/head/template-head-swat.png');
  ImagesTemplateHead.wizard = await loadImage('images/template/head/template-head-wizard.png');
  ImagesTemplateBody.blue = await loadImage('images/template/body/template-body-blue.png');
  ImagesTemplateBody.tunic = await loadImage('images/template/body/template-body-tunic.png');
  ImagesTemplateLegs.blue = await loadImage('images/template/legs/template-legs-blue.png');
  ImagesTemplateLegs.white = await loadImage('images/template/legs/template-legs-white.png');
  ImagesTemplateWeapons.bow = await loadImage('images/template/weapons/template-weapons-bow.png');
  ImagesTemplateWeapons.handgun = await loadImage('images/template/weapons/template-weapons-handgun.png');
  ImagesTemplateWeapons.shotgun = await loadImage('images/template/weapons/template-weapons-shotgun.png');
  Engine.cursorType.value = CursorType.Basic;
  print("environment: ${Engine.isLocalHost ? 'localhost' : 'production'}");
  Engine.onDrawCanvas = Website.renderCanvas;
}

