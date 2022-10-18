
import 'dart:async';

import 'package:gamestream_flutter/game_images.dart';
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
      GameImages.characters = await Engine.loadImageAsset('images/atlas-characters.png');
      GameImages.zombie = await Engine.loadImageAsset('images/atlas-zombie.png');
      GameImages.gameobjects = await Engine.loadImageAsset('images/atlas-gameobjects.png');
      GameImages.templateShadow = await Engine.loadImageAsset('images/template/template-shadow.png');
      GameImages.mapAtlas = await Engine.loadImageAsset('images/atlas-map.png');
      GameImages.blocks = await Engine.loadImageAsset('images/atlas-blocks.png');
      GameImages.template_head_plain = await Engine.loadImageAsset('images/template/head/template-head-plain.png');
      GameImages.template_head_rogue = await Engine.loadImageAsset('images/template/head/template-head-rogue.png');
      GameImages.template_head_steel = await Engine.loadImageAsset('images/template/head/template-head-steel.png');
      GameImages.template_head_swat = await Engine.loadImageAsset('images/template/head/template-head-swat.png');
      GameImages.template_head_wizard = await Engine.loadImageAsset('images/template/head/template-head-wizard.png');
      ImagesTemplateBody.cyan = await Engine.loadImageAsset('images/template/body/template-body-cyan.png');
      ImagesTemplateBody.blue = await Engine.loadImageAsset('images/template/body/template-body-blue.png');
      ImagesTemplateBody.tunic = await Engine.loadImageAsset('images/template/body/template-body-tunic.png');
      ImagesTemplateLegs.blue = await Engine.loadImageAsset('images/template/legs/template-legs-blue.png');
      ImagesTemplateLegs.white = await Engine.loadImageAsset('images/template/legs/template-legs-white.png');
      ImagesTemplateWeapons.bow = await Engine.loadImageAsset('images/template/weapons/template-weapons-bow.png');
      ImagesTemplateWeapons.handgun = await Engine.loadImageAsset('images/template/weapons/template-weapons-handgun.png');
      ImagesTemplateWeapons.shotgun = await Engine.loadImageAsset('images/template/weapons/template-weapons-shotgun.png');
      ImagesTemplateWeapons.staff = await Engine.loadImageAsset('images/template/weapons/template-weapons-staff-wooden.png');
      ImagesTemplateWeapons.sword_steel = await Engine.loadImageAsset('images/template/weapons/template-weapons-sword-steel.png');
      ImagesTemplateWeapons.axe = await Engine.loadImageAsset('images/template/weapons/template-weapons-axe.png');
      ImagesTemplateWeapons.pickaxe = await Engine.loadImageAsset('images/template/weapons/template-weapons-pickaxe.png');
      ImagesTemplateWeapons.hammer = await Engine.loadImageAsset('images/template/weapons/template-weapons-hammer.png');
      Engine.cursorType.value = CursorType.Basic;
      Engine.onDrawCanvas = Website.renderCanvas;
      webSocket.connection.onChanged(onChangedConnection);
    }

  static void onError(Object error, StackTrace stack){
    print(error.toString());
    print(stack);
    Website.error.value = error.toString();
  }

  static void onChangedConnection(Connection connection) {
    switch (connection) {
      case Connection.Connected:
        Engine.onDrawCanvas = Game.renderCanvas;
        Engine.onDrawForeground = modules.game.render.renderForeground;
        Engine.onUpdate = Game.update;
        Engine.drawCanvasAfterUpdate = true;
        Engine.zoomOnScroll = true;
        if (!Engine.isLocalHost) {
          Engine.fullScreenEnter();
        }
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
      case Connection.Failed_To_Connect:
        Website.error.value = "Failed to connect";
        break;
      case Connection.Invalid_Connection:
        Website.error.value = "Invalid Connection";
        break;
      case Connection.Error:
        Website.error.value = "Connection Error";
        break;
      default:
        break;
    }
  }

  static void disconnect() => webSocket.disconnect();
}