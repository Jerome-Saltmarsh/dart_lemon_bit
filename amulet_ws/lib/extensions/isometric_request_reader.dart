import 'package:amulet_ws/classes/connection.dart';

import '../packages/src.dart';

extension IsometricRequestReader on Connection {

  void readIsometricRequest(List<String> arguments){
    final player = this.player;
    final game = player.game;
    final isometricClientRequestIndex = parseArg1(arguments);
    if (isometricClientRequestIndex == null)
      return;

    if (!isValidIndex(isometricClientRequestIndex, NetworkRequestIsometric.values)){
      errorInvalidClientRequest();
      return;
    }

    switch (NetworkRequestIsometric.values[isometricClientRequestIndex]){

      case NetworkRequestIsometric.Teleport:
        if (!isLocalMachine && game is! IsometricEditor) return;
        player.x = player.mouseSceneX;
        player.y = player.mouseSceneY;
        player.health = player.maxHealth;
        player.characterState = CharacterState.Idle;
        player.active = true;
        break;

      case NetworkRequestIsometric.Revive:
        if (player.aliveAndActive) {
          sendGameError(GameError.PlayerStillAlive);
          return;
        }
        game.revive(player);
        return;

      case NetworkRequestIsometric.Weather_Set_Rain:
        final rainType = parseArg2(arguments);
        if (rainType == null || !isValidIndex(rainType, RainType.values)) {
          sendGameError(GameError.Invalid_Client_Request);
          return;
        }
        game.environment.rainType = rainType;
        break;

      case NetworkRequestIsometric.Weather_Set_Wind:
        final index = parseArg2(arguments);
        if (index == null || !isValidIndex(index, WindType.values)) {
          sendGameError(GameError.Invalid_Client_Request);
          return;
        }
        game.environment.windType = index;
        break;

      case NetworkRequestIsometric.Weather_Set_Lightning:
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

      case NetworkRequestIsometric.Weather_Toggle_Breeze:
        game.environment.toggleBreeze();
        break;

      case NetworkRequestIsometric.Time_Set_Hour:
        final hour = parseArg2(arguments);
        if (hour == null) return;
        game.setHourMinutes(hour, 0);
        break;

      case NetworkRequestIsometric.Editor_Load_Game:
      // _player = engine.joinGameEditor(name: arguments[2]);
        break;

      case NetworkRequestIsometric.Move_Selected_Collider_To_Mouse:
        final selectedCollider = player.selectedCollider;
        if (selectedCollider == null) return;
        final scene = player.game.scene;
        final index = scene.findEmptyIndex(player.mouseIndex);
        if (index == -1) return;

        selectedCollider.x = scene.getIndexX(index);
        selectedCollider.y = scene.getIndexY(index);
        selectedCollider.z = scene.getIndexZ(index);

        if (selectedCollider is Character){
          selectedCollider.clearTarget();
          selectedCollider.clearPath();
          selectedCollider.setDestinationToCurrentPosition();
        }
        break;

      case NetworkRequestIsometric.Debug_Character_Walk_To_Mouse:
        final debugCharacter = player.selectedCollider;
        if (debugCharacter is! Character) return;
        final scene = player.game.scene;
        final index = scene.findEmptyIndex(player.mouseIndex);
        if (index == -1) return;
        debugCharacter.clearTarget();
        debugCharacter.pathTargetIndex = index;
        break;

      case NetworkRequestIsometric.Debug_Character_Toggle_Auto_Attack_Nearby_Enemies:
        final debugCharacter = player.selectedCollider;
        if (debugCharacter is! Character) return;
        debugCharacter.autoTarget = !debugCharacter.autoTarget;
        break;

      case NetworkRequestIsometric.Debug_Character_Toggle_Path_Finding_Enabled:
        final debugCharacter = player.selectedCollider;
        if (debugCharacter is! Character) return;
        debugCharacter.pathFindingEnabled = !debugCharacter.pathFindingEnabled;
        debugCharacter.clearPath();
        break;

      case NetworkRequestIsometric.Debug_Character_Toggle_Run_To_Destination:
        final debugCharacter = player.selectedCollider;
        if (debugCharacter is! Character) return;
        debugCharacter.runToDestinationEnabled = !debugCharacter.runToDestinationEnabled;
        break;

      case NetworkRequestIsometric.Debug_Character_Debug_Update:
        final debugCharacter = player.selectedCollider;
        if (debugCharacter is! Character) return;
        player.game.updateCharacter(debugCharacter);
        break;

      case NetworkRequestIsometric.Debug_Character_Set_Character_Type:
        final debugCharacter = player.selectedCollider;
        if (debugCharacter is! Character)
          return;
        final characterType = parseArg2(arguments);
        if (characterType == null)
          return;
        debugCharacter.characterType = characterType;
        break;

      case NetworkRequestIsometric.Debug_Character_Set_Weapon_Type:
        final debugCharacter = player.selectedCollider;
        if (debugCharacter is! Character)
          return;
        final weaponType = parseArg2(arguments);
        if (weaponType == null)
          return;
        debugCharacter.weaponType = weaponType;
        break;

      case NetworkRequestIsometric.Select_GameObject:
        final id = parseArg2(arguments);
        if (id == null) return;
        final gameObject = game.findGameObjectById(id);
        if (gameObject == null) {
          sendGameError(GameError.GameObject_Not_Found);
          return;
        }
        player.selectedCollider = gameObject;
        break;

      case NetworkRequestIsometric.Debug_Select:
        player.selectNearestColliderToMouse();
        break;

      case NetworkRequestIsometric.Debug_Command:
        player.debugCommand();
        break;

      case NetworkRequestIsometric.Debug_Attack:
        player.attack();
        break;

      case NetworkRequestIsometric.Toggle_Debugging:
        player.toggleDebugging();
        break;

      case NetworkRequestIsometric.Toggle_Controls_Can_Target_Enemies:
        player.toggleControlsCanTargetEnemies();
        break;
    }
  }
}