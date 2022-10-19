
import 'dart:async';

import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/game_images.dart';
import 'package:gamestream_flutter/game_network.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:gamestream_flutter/isometric_web/register_isometric_web_controls.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'enums/connection_status.dart';
import 'website/website.dart';

class System {

    static Future init(SharedPreferences sharedPreferences) async {
      print("environment: ${Engine.isLocalHost ? 'localhost' : 'production'}");
      GameImages.characters = await Engine.loadImageAsset('images/atlas-characters.png');
      GameImages.zombie = await Engine.loadImageAsset('images/atlas-zombie.png');
      GameImages.gameobjects = await Engine.loadImageAsset('images/atlas-gameobjects.png');
      GameImages.particles = await Engine.loadImageAsset('images/atlas-particles.png');
      GameImages.projectiles = await Engine.loadImageAsset('images/atlas-projectiles.png');
      GameImages.templateShadow = await Engine.loadImageAsset('images/template/template-shadow.png');
      GameImages.mapAtlas = await Engine.loadImageAsset('images/atlas-map.png');
      GameImages.blocks = await Engine.loadImageAsset('images/atlas-blocks.png');

      GameImages.template_head_plain = await Engine.loadImageAsset('images/template/head/template-head-plain.png');
      GameImages.template_head_rogue = await Engine.loadImageAsset('images/template/head/template-head-rogue.png');
      GameImages.template_head_steel = await Engine.loadImageAsset('images/template/head/template-head-steel.png');
      GameImages.template_head_swat = await Engine.loadImageAsset('images/template/head/template-head-swat.png');
      GameImages.template_head_wizard = await Engine.loadImageAsset('images/template/head/template-head-wizard.png');
      GameImages.template_head_blonde = await Engine.loadImageAsset('images/template/head/template-head-blonde.png');

      GameImages.template_body_blue = await Engine.loadImageAsset('images/template/body/template-body-blue.png');
      GameImages.template_body_cyan = await Engine.loadImageAsset('images/template/body/template-body-cyan.png');
      GameImages.template_body_swat = await Engine.loadImageAsset('images/template/body/template-body-swat.png');
      GameImages.template_body_tunic = await Engine.loadImageAsset('images/template/body/template-body-tunic.png');

      GameImages.template_legs_blue = await Engine.loadImageAsset('images/template/legs/template-legs-blue.png');
      GameImages.template_legs_white = await Engine.loadImageAsset('images/template/legs/template-legs-white.png');
      GameImages.template_legs_green = await Engine.loadImageAsset('images/template/legs/template-legs-green.png');
      GameImages.template_legs_brown = await Engine.loadImageAsset('images/template/legs/template-legs-brown.png');
      GameImages.template_legs_red = await Engine.loadImageAsset('images/template/legs/template-legs-red.png');
      GameImages.template_legs_swat = await Engine.loadImageAsset('images/template/legs/template-legs-swat.png');

      GameImages.template_weapon_bow = await Engine.loadImageAsset('images/template/weapons/template-weapons-bow.png');
      GameImages.template_weapon_handgun = await Engine.loadImageAsset('images/template/weapons/template-weapons-handgun.png');
      GameImages.template_weapon_shotgun = await Engine.loadImageAsset('images/template/weapons/template-weapons-shotgun.png');
      GameImages.template_weapon_staff = await Engine.loadImageAsset('images/template/weapons/template-weapons-staff-wooden.png');
      GameImages.template_weapon_sword_steel = await Engine.loadImageAsset('images/template/weapons/template-weapons-sword-steel.png');
      GameImages.template_weapon_axe = await Engine.loadImageAsset('images/template/weapons/template-weapons-axe.png');
      GameImages.template_weapon_pickaxe = await Engine.loadImageAsset('images/template/weapons/template-weapons-pickaxe.png');
      GameImages.template_weapon_hammer = await Engine.loadImageAsset('images/template/weapons/template-weapons-hammer.png');

      Engine.cursorType.value = CursorType.Basic;
      Engine.onDrawCanvas = Website.renderCanvas;
      GameNetwork.connectionStatus.onChanged(onChangedConnection);
    }

  static void onError(Object error, StackTrace stack){
    print(error.toString());
    print(stack);
    Website.error.value = error.toString();
  }

  static void onChangedConnection(ConnectionStatus connection) {
    switch (connection) {
      case ConnectionStatus.Connected:
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

      case ConnectionStatus.Done:
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
      case ConnectionStatus.Failed_To_Connect:
        Website.error.value = "Failed to connect";
        break;
      case ConnectionStatus.Invalid_Connection:
        Website.error.value = "Invalid Connection";
        break;
      case ConnectionStatus.Error:
        Website.error.value = "Connection Error";
        break;
      default:
        break;
    }
  }

  static void disconnect() => GameNetwork.disconnect();
}