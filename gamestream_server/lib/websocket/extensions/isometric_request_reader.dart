
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/games/isometric_editor/isometric_editor.dart';
import 'package:gamestream_server/games/survival/survival_player.dart';
import 'package:gamestream_server/isometric.dart';
import 'package:gamestream_server/utils.dart';
import 'package:gamestream_server/websocket/src.dart';

extension IsometricRequestReader on WebSocketConnection {

  void readIsometricRequest(List<String> arguments){
    final player = this.player;

    if (player is! IsometricPlayer) {
      errorInvalidPlayerType();
      return;
    }
    final game = player.game;
    final isometricClientRequestIndex = parseArg1(arguments);
    if (isometricClientRequestIndex == null)
      return;

    if (!isValidIndex(isometricClientRequestIndex, IsometricRequest.values)){
      errorInvalidClientRequest();
      return;
    }

    switch (IsometricRequest.values[isometricClientRequestIndex]){

      case IsometricRequest.Teleport:
        if (!isLocalMachine && game is! IsometricEditor) return;
        player.x = player.mouseGridX;
        player.y = player.mouseGridY;
        player.health = player.maxHealth;
        player.state = CharacterState.Idle;
        player.active = true;
        break;

      case IsometricRequest.Revive:
        if (player.aliveAndActive) {
          sendGameError(GameError.PlayerStillAlive);
          return;
        }
        game.revive(player);
        return;

      case IsometricRequest.Weather_Set_Rain:
        final rainType = parseArg2(arguments);
        if (rainType == null || !isValidIndex(rainType, RainType.values)) {
          sendGameError(GameError.Invalid_Client_Request);
          return;
        }
        game.environment.rainType = rainType;
        break;

      case IsometricRequest.Weather_Set_Wind:
        final index = parseArg2(arguments);
        if (index == null || !isValidIndex(index, WindType.values)) {
          sendGameError(GameError.Invalid_Client_Request);
          return;
        }
        game.environment.windType = index;
        break;

      case IsometricRequest.Weather_Set_Lightning:
        final index = parseArg2(arguments);
        if (index == null || !isValidIndex(index, LightningType.values)) {
          sendGameError(GameError.Invalid_Client_Request);
          return;
        }
        game.environment.lightningType = LightningType.values[index];
        if (game.environment.lightningType == LightningType.On){
          game.environment.nextLightningFlash = 1;
        }
        break;

      case IsometricRequest.Weather_Toggle_Breeze:
        game.environment.toggleBreeze();
        break;

      case IsometricRequest.Time_Set_Hour:
        final hour = parseArg2(arguments);
        if (hour == null) return;
        game.setHourMinutes(hour, 0);
        break;

      case IsometricRequest.Npc_Talk_Select_Option:
        if (player.dead) return errorPlayerDead();
        if (arguments.length != 2) return errorInvalidClientRequest();
        if (player is! SurvivalPlayer) return;
        final index = parseArg2(arguments);
        if (index == null) {
          return errorInvalidClientRequest();
        }
        if (index < 0 || index >= player.npcOptions.length){
          return errorInvalidClientRequest();
        }
        final action = player.npcOptions.values.toList()[index];
        action.call();
        break;

      case IsometricRequest.Editor_Load_Game:
      // _player = engine.joinGameEditor(name: arguments[2]);
        break;

      case IsometricRequest.Move_Selected_Collider_To_Mouse:
        final selectedCollider = player.selectedCollider;
        if (selectedCollider == null) return;
        final scene = player.game.scene;
        final index = scene.findEmptyIndex(player.mouseIndex);
        if (index == -1) return;

        selectedCollider.x = scene.getNodePositionX(index);
        selectedCollider.y = scene.getNodePositionY(index);
        selectedCollider.z = scene.getNodePositionZ(index);

        if (selectedCollider is IsometricCharacter){
          selectedCollider.clearTarget();
          selectedCollider.clearPath();
          selectedCollider.setDestinationToCurrentPosition();
        }
        break;

      case IsometricRequest.Debug_Character_Walk_To_Mouse:
        final debugCharacter = player.selectedCollider;
        if (debugCharacter is! IsometricCharacter) return;
        final scene = player.game.scene;
        final index = scene.findEmptyIndex(player.mouseIndex);
        if (index == -1) return;
        debugCharacter.clearTarget();
        debugCharacter.pathTargetIndex = index;
        break;

      case IsometricRequest.Debug_Character_Toggle_Auto_Attack_Nearby_Enemies:
        final debugCharacter = player.selectedCollider;
        if (debugCharacter is! IsometricCharacter) return;
        debugCharacter.autoTarget = !debugCharacter.autoTarget;
        break;

      case IsometricRequest.Debug_Character_Toggle_Path_Finding_Enabled:
        final debugCharacter = player.selectedCollider;
        if (debugCharacter is! IsometricCharacter) return;
        debugCharacter.pathFindingEnabled = !debugCharacter.pathFindingEnabled;
        debugCharacter.clearPath();
        break;

      case IsometricRequest.Debug_Character_Toggle_Run_To_Destination:
        final debugCharacter = player.selectedCollider;
        if (debugCharacter is! IsometricCharacter) return;
        debugCharacter.runToDestinationEnabled = !debugCharacter.runToDestinationEnabled;
        break;

      case IsometricRequest.Debug_Character_Debug_Update:
        final debugCharacter = player.selectedCollider;
        if (debugCharacter is! IsometricCharacter) return;
        player.game.updateCharacter(debugCharacter);
        break;

      case IsometricRequest.Debug_Character_Set_Character_Type:
        final debugCharacter = player.selectedCollider;
        if (debugCharacter is! IsometricCharacter)
          return;
        final characterType = parseArg2(arguments);
        if (characterType == null)
          return;
        debugCharacter.characterType = characterType;
        break;

      case IsometricRequest.Select_GameObject:
        final id = parseArg2(arguments);
        if (id == null) return;
        final gameObject = game.findGameObjectById(id);
        if (gameObject == null) {
          sendGameError(GameError.GameObject_Not_Found);
          return;
        }
        player.selectedCollider = gameObject;
        break;
    }
  }

}