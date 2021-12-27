
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/editor/functions/registerEditorKeyboardListener.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/functions/cameraCenterPlayer.dart';
import 'package:bleed_client/functions/removeGeneratedEnvironmentObjects.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/logic.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/watches/time.dart';
import 'package:lemon_engine/functions/fullscreen_enter.dart';
import 'package:lemon_engine/functions/fullscreen_exit.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/state/camera.dart';
import 'package:lemon_engine/state/zoom.dart';

import 'common/GameType.dart';
import 'enums/Region.dart';

class Events {

  Events() {
    print("Events()");
    webSocket.connection.onChanged(_onConnectionChanged);
    game.type.onChanged(_onGameTypeChanged);
    game.region.onChanged(_onServerTypeChanged);
    game.player.uuid.onChanged(_onPlayerUuidChanged);
    game.player.alive.onChanged(_onPlayerAliveChanged);
    game.status.onChanged(_onGameStatusChanged);
    game.mode.onChanged(_onGameModeChanged);
  }

  void _onGameTypeChanged(GameType type) {
    print('events.onGameTypeChanged($type)');
    logic.clearSession();
    camera.x = 0;
    camera.y = 0;
    zoom = 1;
    switch (type) {
      case GameType.None:
        break;
      // case GameType.CUBE3D:
      //   if (game.type.value == GameType.CUBE3D){
      //     requestPointerLock();
      //     overrideBuilder.value = (BuildContext context){
      //       return buildCube3D();
      //     };
      //     Timer.periodic(Duration(milliseconds: 50), (timer) {
      //       cubeFrame.value++;
      //     });
      //   }
      //   break;
      default:
        connectToWebSocketServer(game.region.value, type);
        break;
    }
  }

  void _onServerTypeChanged(Region serverType) {
    print('events.onServerTypeChanged($serverType)');
    storage.saveServerType(serverType);
  }

  void _onConnectionChanged(Connection connection) {
    print("events.onConnectionChanged($connection)");

    switch(connection){
      case Connection.Connected:
        sendRequestJoinGame(game.type.value);
        fullScreenEnter();
        // if (game.type.value == GameType.CUBE3D){
        //   requestPointerLock();
        //   overrideBuilder.value = (BuildContext context){
        //     return buildCube3D();
        //   };
        //   // Future.
        // }
        break;
      case Connection.Done:
        fullScreenExit();
        logic.clearSession();
        break;
      case Connection.Failed_To_Connect:
        fullScreenExit();
        break;
      default:
        break;
    }
  }

  void _onPlayerUuidChanged(String uuid) {
    print("events.onPlayerUuidChanged($uuid)");
    if (uuid.isNotEmpty) {
      cameraCenterPlayer();
    }
  }

  void _onPlayerAliveChanged(bool value) {
    print("events.onPlayerAliveChanged($value)");
    if (value) {
      cameraCenterPlayer();
    }
  }

  void _onGameStatusChanged(GameStatus value){
    print('events.onGameStatusChanged($value)');
  }

  void _onGameModeChanged(Mode mode){
    print("_onGameModeChanged($mode)");
    if (mode == Mode.Edit) {
      removeGeneratedEnvironmentObjects();
      deregisterPlayKeyboardHandler();
      registerEditorKeyboardListener();
      game.totalZombies.value = 0;
      game.totalProjectiles = 0;
      game.totalNpcs = 0;
      game.totalHumans = 0;
      game.zombies.clear();
      game.projectiles.clear();
      game.interactableNpcs.clear();
      game.humans.clear();
      game.particles.clear();
      timeInSeconds.value = 60 * 60 * 10;
    }
    redrawCanvas();
  }
}
