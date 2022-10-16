
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/audio_engine.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:gamestream_flutter/isometric_web/register_isometric_web_controls.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/network/classes/websocket.dart';
import 'package:lemon_engine/engine.dart';

import 'website/website.dart';

class SystemEvents {

  static void onError(Object error, StackTrace stack){
    print(error.toString());
    print(stack);
    Website.error.value = error.toString();
  }

  static void onGameEventWeaponTypeEquipped(int attackType, double x, double y, double z) {
    switch (attackType) {
      case AttackType.Shotgun:
        AudioEngine.audioSingleShotgunCock.playXYZ(x, y, z);
        break;
      default:
        break;
    }
  }

  static void onConnectionChanged(Connection connection) {
    switch (connection) {
      case Connection.Connected:
        Engine.onDrawCanvas = modules.game.render.renderGame;
        Engine.onDrawForeground = modules.game.render.renderForeground;
        Engine.onUpdate = modules.game.update.update;
        Engine.drawCanvasAfterUpdate = true;
        modules.game.events.register();
        Engine.zoomOnScroll = true;
        isometricWebControlsRegister();
        Engine.fullScreenEnter();
        break;

      case Connection.Done:
        isometricWebControlsDeregister();
        Engine.onUpdate = null;
        Engine.drawCanvasAfterUpdate = true;
        Engine.cursorType.value = CursorType.Basic;
        Game.gameType.value = null;
        Engine.drawCanvasAfterUpdate = true;
        Engine.onDrawCanvas = Website.renderCanvas;
        Engine.onUpdate = Website.update;
        Engine.fullScreenExit();
        Game.clear();
        sceneEditable.value = false;
        break;
      default:
        break;
    }
  }
}