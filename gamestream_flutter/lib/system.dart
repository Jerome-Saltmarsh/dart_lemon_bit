
import 'dart:async';

import 'package:gamestream_flutter/atlases.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:gamestream_flutter/isometric_web/register_isometric_web_controls.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/network/classes/websocket.dart';
import 'package:gamestream_flutter/network/instance/websocket.dart';
import 'package:lemon_engine/engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'website/website.dart';

class System {

    static Future init(SharedPreferences sharedPreferences) async {
      print("environment: ${Engine.isLocalHost ? 'localhost' : 'production'}");
      Images.characters = await Engine.loadImageAsset('images/atlas-characters.png');
      Images.zombie = await Engine.loadImageAsset('images/atlas-zombie.png');
      Images.gameobjects = await Engine.loadImageAsset('images/atlas-gameobjects.png');
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
      Engine.onDrawCanvas = Website.renderCanvas;
      webSocket.connection.onChanged(onConnectionChanged);
    }

  static void onError(Object error, StackTrace stack){
    print(error.toString());
    print(stack);
    Website.error.value = error.toString();
  }

  static void onConnectionChanged(Connection connection) {
    switch (connection) {
      case Connection.Connected:
        Engine.onDrawCanvas = modules.game.render.renderGame;
        Engine.onDrawForeground = modules.game.render.renderForeground;
        Engine.onUpdate = modules.game.update.update;
        Engine.drawCanvasAfterUpdate = true;
        Engine.zoomOnScroll = true;
        Engine.fullScreenEnter();
        isometricWebControlsRegister();
        break;

      case Connection.Done:
        Engine.onUpdate = null;
        Engine.drawCanvasAfterUpdate = true;
        Engine.cursorType.value = CursorType.Basic;
        Engine.drawCanvasAfterUpdate = true;
        Engine.onDrawCanvas = Website.renderCanvas;
        Engine.onUpdate = Website.update;
        Engine.fullScreenExit();
        Game.clear();
        Game.gameType.value = null;
        sceneEditable.value = false;
        isometricWebControlsDeregister();
        break;
      default:
        break;
    }
  }
}