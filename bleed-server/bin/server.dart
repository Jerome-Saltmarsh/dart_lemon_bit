import 'package:bleed_server/CubeGame.dart';
import 'package:bleed_server/system.dart';
import 'package:bleed_server/user-service-client/firestoreService.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'classes/Ability.dart';
import 'classes/Character.dart';
import 'classes/Game.dart';
import 'classes/Player.dart';
import 'classes/Weapon.dart';
import 'common/AbilityMode.dart';
import 'common/CharacterAction.dart';
import 'common/CharacterState.dart';
import 'common/CharacterType.dart';
import 'common/ClientRequest.dart';
import 'common/GameError.dart';
import 'common/GameType.dart';
import 'common/Modify_Game.dart';
import 'common/PlayerEvent.dart';
import 'common/ServerResponse.dart';
import 'common/SlotType.dart';
import 'common/SlotTypeCategory.dart';
import 'common/WeaponType.dart';
import 'common/enums/Direction.dart';
import 'common/version.dart';
import 'compile.dart';
import 'functions/generateName.dart';
import 'functions/loadScenes.dart';
import 'functions/withinRadius.dart';
import 'games/Moba.dart';
import 'games/Royal.dart';
import 'games/world.dart';
import 'engine.dart';
import 'settings.dart';
import 'utilities.dart';
import 'values/world.dart';

const String _space = " ";
final int errorIndex = ServerResponse.Error.index;
final StringBuffer _buffer = StringBuffer();

const List<ClientRequest> clientRequests = ClientRequest.values;
final int clientRequestsLength = clientRequests.length;

void write(dynamic value) {
  _buffer.write(value);
  _buffer.write(_space);
}

void main() {
  print('gamestream.online server starting');
  if (isLocalMachine){
    print("Environment Detected: Jerome's Computer");
  }else{
    print("Environment Detected: Google Cloud Machine");
  }
  engine.init();
  loadScenes();

  var handler = webSocketHandler(buildWebSocketHandler,);

  shelf_io.serve(handler, settings.host, settings.port).then((server) {
    print('Serving at wss://${server.address.host}:${server.port}');
  });
}

Player spawnPlayerInTown() {
  return Player(
      game: world.town,
      x: 0,
      y: 1750,
      team: teams.west,
      type: CharacterType.Template,
      health: 10,
      // ai: AI()
  );
}

void compileWholeGame(Game game) {
  compile.game(game);
  write(game.compiledTiles);
  write(game.compiledEnvironmentObjects);
  write(game.compiled);
}

int totalConnections = 0;

void buildWebSocketHandler(WebSocketChannel webSocket) {
    totalConnections++;
    print("New connection established. Total Connections $totalConnections");

    void reply(String response) {
      webSocket.sink.add(response);
    }

    void clearBuffer() {
      _buffer.clear();
    }

    void sendAndClearBuffer() {
      reply(_buffer.toString());
      clearBuffer();
    }

    void sendCompiledPlayerState(Game game, Player player) {
      clearBuffer();
      write(game.compiled);
      compilePlayer(_buffer, player);
      if (player.message.isNotEmpty) {
        compilePlayerMessage(_buffer, player.message);
        player.message = "";
      }

      if (game is GameMoba) {
        if (game.awaitingPlayers) {
          compilePlayersRemaining(
              _buffer, game.totalPlayersRequired - game.players.length);
          sendAndClearBuffer();
          return;
        } else {
          compilePlayersRemaining(_buffer, 0);
        }

        if (game.inProgress) {
          compileTeamLivesRemaining(_buffer, game);
        }
      }

      sendAndClearBuffer();
    }

    void joinGameMoba() {
      final GameMoba moba = engine.findPendingMobaGame();
      final Player player = moba.playerJoin();
      compileWholeGame(moba);
      compilePlayerJoined(_buffer, player);
      compileGameMeta(_buffer, moba);
      sendAndClearBuffer();
    }

    void joinBattleRoyal(String playerName) {
      print('$playerName joining battle royal');
      final GameRoyal royal = engine.findPendingRoyalGames();
      final Player player = royal.playerJoin();
      player.name = playerName;
      compileWholeGame(royal);
      compilePlayerJoined(_buffer, player);
      compilePlayerWeaponValues(_buffer, player);
      compilePlayerWeapons(_buffer, player);
      compileGameStatus(_buffer, royal.status);
      compileGameMeta(_buffer, royal);
      compileCrates(_buffer, royal.crates);
      sendAndClearBuffer();
    }

    void joinCube3D() {
      final CubePlayer cubePlayer =
      CubePlayer(position: Vector3(), rotation: Vector3());
      cubeGame.cubes.add(cubePlayer);
      reply('${ServerResponse.Cube_Joined.index} ${cubePlayer.uuid}');
    }

    void joinGameMMO({required String playerName}) {
      clearBuffer();
      final player = spawnPlayerInTown();
      player.name = playerName;
      player.orbs.emerald = 10;
      player.orbs.topaz = 10;
      player.orbs.ruby = 10;

      compilePlayer(_buffer, player);
      write(
          '${ServerResponse.Game_Joined.index} ${player.id} ${player.uuid} ${player.x.toInt()} ${player.y.toInt()} ${player.game.id} ${player.team}');
      write(player.game.compiledTiles);
      write(player.game.compiledEnvironmentObjects);
      write(player.game.compiled);
      compilePlayersRemaining(_buffer, 0);
      sendAndClearBuffer();
    }

    void error(GameError error, {String message = ""}) {
      reply('$errorIndex ${error.index} $message');
    }

    void errorInvalidArg(String message) {
      reply('$errorIndex ${GameError.InvalidArguments.index} $message');
    }

    void errorArgsExpected(int expected, List arguments) {
      errorInvalidArg(
          'Invalid number of arguments received. Expected $expected but got ${arguments.length}');
    }

    void errorIntegerExpected(int index, got) {
      errorInvalidArg(
          'Invalid type at index $index, expected integer but got $got');
    }

    void errorPlayerNotFound() {
      error(GameError.PlayerNotFound);
    }

    void errorPremiumAccountOnly() {
      error(GameError.Subscription_Required);
    }

    void errorCustomMapNotFound() {
      error(GameError.Custom_Map_Not_Found);
    }

    void errorAccountNotFound() {
      error(GameError.GameNotFound);
    }

    void errorPlayerDead() {
      error(GameError.PlayerDead);
    }

    void errorPlayerBusy() {
      error(GameError.PlayerBusy);
    }

    void errorInsufficientSkillPoints() {
      error(GameError.InsufficientSkillPoints);
    }

    void errorInsufficientOrbs() {
      error(GameError.InsufficientOrbs);
    }

    void errorInventoryFull() {
      error(GameError.Inventory_Full);
    }

    void onEvent(requestD) {
      final String requestString = requestD;
      final arguments = requestString.split(_space);

      if (arguments.isEmpty) {
        error(GameError.ClientRequestArgumentsEmpty);
        return;
      }

      int? clientRequestInt = int.tryParse(arguments[0]);
      if (clientRequestInt == null) {
        error(GameError.ClientRequestRequired);
        return;
      }

      if (clientRequestInt < 0) {
        error(GameError.UnrecognizedClientRequest);
        return;
      }

      if (clientRequestInt >= clientRequestsLength) {
        error(GameError.UnrecognizedClientRequest);
        return;
      }

      final clientRequest = clientRequests[clientRequestInt];
      switch (clientRequest) {
        case ClientRequest.Update:
          if (arguments.length < 2){
            errorInvalidArg("player uuid required");
            return;
          }

          final playerId = arguments[1];
          final player = engine.findPlayerByUuid(playerId);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          player.lastUpdateFrame = 0;
          final game = player.game;
          compileGameStatus(_buffer, game.status);

          if (game.awaitingPlayers) {
            compileLobby(_buffer, game);
            compileGameMeta(_buffer, game);
            sendAndClearBuffer();
            return;
          }

          if (game.countingDown){
            compileCountDownFramesRemaining(_buffer, game);
            sendAndClearBuffer();
            return;
          }

          if (game.finished) {
            if (game is GameMoba) {
              compileTeamLivesRemaining(_buffer, game);
            }
            reply(_buffer.toString());
            return;
          }

          // if game in progress

          if (player.sceneChanged) {
            player.sceneChanged = false;
            _buffer.clear();
            _buffer.write(
                '${ServerResponse.Scene_Changed.index} ${player.x.toInt()} ${player.y.toInt()} ');
            _buffer.write(game.compiledTiles);
            _buffer.write(game.compiledEnvironmentObjects);
            _buffer.write(game.compiled);
            reply(_buffer.toString());
            return;
          }

          if (player.deadOrBusy) {
            sendCompiledPlayerState(game, player);
            return;
          }

          final actionIndex = int.parse(arguments[2]);
          final action = characterActions[actionIndex];
          final mouseX = double.parse(arguments[4]);
          final mouseY = double.parse(arguments[5]);
          final ai = player.ai;

          if (!player.isSoldier) {
            final closestEnemy = game.getClosestEnemy(mouseX, mouseY, player.team);
            player.aimTarget = null;
            if (closestEnemy != null) {
              if (withinDistance(
                  closestEnemy, mouseX, mouseY, settings.radius.cursor)) {
                player.aimTarget = closestEnemy;
              }
            }
          }

          switch (action) {
            case CharacterAction.Idle:
              game.setCharacterState(player, CharacterState.Idle);
              break;
            case CharacterAction.Perform:
              if (player.type.isSoldier) {
                characterFace(player, mouseX, mouseY);
                if (player.weapon.type == WeaponType.Unarmed){
                  game.setCharacterState(player, CharacterState.Striking);
                } else {
                  game.setCharacterState(player, CharacterState.Firing);
                }
                break;
              }
              final ability = player.ability;
              final aimTarget = player.aimTarget;
              player.attackTarget = player.aimTarget;
              playerSetAbilityTarget(player, mouseX, mouseY);

              if (ability == null) {
                if (player.type.isSoldier ||
                    player.type.isHuman ||
                    player.type.isTemplate
                    // || player.attackTarget != null
                ) {
                  characterAimAt(player, mouseX, mouseY);

                  if (aimTarget != null) {
                    player.target = aimTarget;
                  } else {
                    player.target = Vector2(mouseX, mouseY);
                  }

                // if (ai != null) {
                //   if (aimTarget != null) {
                //     ai.target = aimTarget;
                //     game.npcSetPathTo(ai, aimTarget.x, aimTarget.y);
                //   } else {
                //     game.npcSetPathTo(ai, mouseX, mouseY);
                //   }
                // }
              }
              break;
              }

              if (player.magic < ability.cost) {
                error(GameError.InsufficientMana);
                break;
              }

              if (ability.cooldownRemaining > 0) {
                error(GameError.Cooldown_Remaining);
                break;
              }

              switch (ability.mode) {
                case AbilityMode.None:
                  return;
                case AbilityMode.Targeted:
                  if (player.attackTarget == null) {
                    return;
                  }
                  break;
                case AbilityMode.Activated:
                // TODO: Handle this case.
                  break;
                case AbilityMode.Area:
                // TODO: Handle this case.
                  break;
                case AbilityMode.Directed:
                // TODO: Handle this case.
                  break;
              }

              // @on player perform ability
              player.magic -= ability.cost;
              player.performing = ability;
              ability.cooldownRemaining = ability.cooldown;
              player.abilitiesDirty = true;
              player.ability = null;

              characterAimAt(player, mouseX, mouseY);
              game.setCharacterState(player, CharacterState.Performing);
              break;
            case CharacterAction.Run:
              final direction = directions[int.parse(arguments[3])];
              setDirection(player, direction);
              game.setCharacterStateRunning(player);
              player.target = null;
              break;
          }
          sendCompiledPlayerState(game, player);
          return;

        case ClientRequest.Join_Custom:
          if (arguments.length < 3) {
            errorArgsExpected(3, arguments);
            return;
          }
          final indexPlayerId = 1;
          final indexMapId = 2;


          final playerId = arguments[indexPlayerId];
          firestoreService.findUserById(playerId).then((account) async {
            if (account == null){
              return errorAccountNotFound();
            }
            if (!account.isPremium) {
              return errorPremiumAccountOnly();
            }

            final mapId = arguments[indexMapId];
            final customGame = await engine.findOrCreateCustomGame(mapId);
            final Player player = customGame.playerJoin();
            compileWholeGame(customGame);
            compilePlayerJoined(_buffer, player);
            compileGameMeta(_buffer, customGame);
            sendAndClearBuffer();
          });
          break;

        case ClientRequest.Join:
          if (arguments.length < 2) {
            errorArgsExpected(2, arguments);
            return;
          }
          final int? gameTypeIndex = int.tryParse(arguments[1]);

          if (gameTypeIndex == null) {
            errorInvalidArg('expected integer at args[1]');
            return;
          }
          if (gameTypeIndex >= gameTypes.length) {
            errorInvalidArg(
                'game type index cannot exceed ${gameTypes.length - 1}');
            return;
          }
          if (gameTypeIndex < 0) {
            errorInvalidArg('game type must be greater than 0');
            return;
          }

          final gameType = gameTypes[gameTypeIndex];

          if (!freeToPlay.contains(gameType)){
            if (arguments.length < 3) {
              return error(GameError.PlayerId_Required);
            }
          }

          switch (gameType) {
            case GameType.None:
              break;
            case GameType.MMO:
              if (arguments.length < 3) {
                return joinGameMMO(playerName: generateName());
              }
              final playerId = arguments[2];
              firestoreService.findUserById(playerId).then((account){
                if (account == null) {
                  return errorAccountNotFound();
                }
                joinGameMMO(playerName: account.publicName);
              });
              break;
            case GameType.Moba:
              joinGameMoba();
              break;
            case GameType.CUBE3D:
              joinCube3D();
              break;
            case GameType.BATTLE_ROYAL:
              if (arguments.length < 3) {
                return error(GameError.PlayerId_Required);
              }

              final playerId = arguments[2];
              firestoreService.findUserById(playerId).then((account){
                if (account == null){
                  return errorAccountNotFound();
                }
                if (!account.isPremium) {
                  return errorPremiumAccountOnly();
                }
                joinBattleRoyal(account.publicName);
              });

              break;
          }
          break;

        case ClientRequest.Ping:
          reply(ServerResponse.Pong.index.toString());
          break;

        case ClientRequest.Revive:
          final player = engine.findPlayerByUuid(arguments[1]);

          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (player.alive) {
            error(GameError.PlayerStillAlive);
            return;
          }
          player.game.revive(player);
          return;

        case ClientRequest.SelectCharacterType:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }

          Player? player = engine.findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (player.type != CharacterType.Human) {
            error(GameError.CharacterTypeAlreadySelected);
            break;
          }

          int? characterTypeIndex = int.tryParse(arguments[2]);
          if (characterTypeIndex == null) {
            errorIntegerExpected(1, arguments[2]);
            return;
          }

          selectCharacterType(player, characterTypes[characterTypeIndex]);
          break;

        case ClientRequest.Unequip_Slot:
          if (arguments.length != 3) {
            return errorArgsExpected(3, arguments);
          }

          Player? player = engine.findPlayerByUuid(arguments[1]);
          if (player == null) {
            return errorPlayerNotFound();
          }

          int? slotTypeCategoryIndex = int.tryParse(arguments[2]);
          if (slotTypeCategoryIndex == null){
            return errorIntegerExpected(2, arguments[2]);
          }
          if (slotTypeCategoryIndex < 0 || slotTypeCategoryIndex >= slotTypeCategories.length) {
            return errorInvalidArg('inventory index out of bounds: $slotTypeCategoryIndex');
          }

          final slotTypeCategory = slotTypeCategories[slotTypeCategoryIndex];
          player.unequip(slotTypeCategory);
          break;

        case ClientRequest.Equip_Slot:
          if (arguments.length != 3) {
            return errorArgsExpected(3, arguments);
          }

          Player? player = engine.findPlayerByUuid(arguments[1]);
          if (player == null) {
            return errorPlayerNotFound();
          }

          int? inventoryIndex = int.tryParse(arguments[2]);
          if (inventoryIndex == null){
            return errorIntegerExpected(2, arguments[2]);
          }
          if (inventoryIndex < 1 || inventoryIndex > 6) {
            return errorInvalidArg('inventory index out of bounds');
          }

          player.useSlot(inventoryIndex);
          break;

        case ClientRequest.Sell_Slot:
          if (arguments.length != 3) {
            return errorArgsExpected(3, arguments);
          }

          Player? player = engine.findPlayerByUuid(arguments[1]);
          if (player == null) {
            return errorPlayerNotFound();
          }

          int? inventoryIndex = int.tryParse(arguments[2]);
          if (inventoryIndex == null){
            return errorIntegerExpected(2, arguments[2]);
          }
          if (inventoryIndex < 1 || inventoryIndex > 6) {
            return errorInvalidArg('inventory index out of bounds');
          }
          // TODO move business logic to game
          player.slots.assignSlotAtIndex(inventoryIndex, SlotType.Empty);
          break;

        case ClientRequest.Modify_Game:

          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }

          Player? player =engine.findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          int? modifyGameIndex = int.tryParse(arguments[2]);
          if (modifyGameIndex == null){
            errorIntegerExpected(2, arguments[2]);
            return;
          }
          if (modifyGameIndex < 0){
            errorInvalidArg('gameModificationIndex: $modifyGameIndex cannot be negative');
            return;
          }
          if (modifyGameIndex >= gameModifications.length){
            errorInvalidArg('gameModificationIndex: $modifyGameIndex not a valid index');
            return;
          }

          final ModifyGame modifyGame = gameModifications[modifyGameIndex];
          switch(modifyGame){
            case ModifyGame.Spawn_Zombie:
              player.game.spawnRandomZombie(
                damage: 1,
                health: 5
              );
              break;
            case ModifyGame.Remove_Zombie:
            // TODO: Handle this case.
              break;
            case ModifyGame.Hour_Increase:
              worldTime += secondsPerHour;
              break;
            case ModifyGame.Hour_Decrease:
              worldTime -= secondsPerHour;
              break;
          }
          break;

        case ClientRequest.Leave_Lobby:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }

          final player = engine.findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          player.game.players
              .removeWhere((element) => element.uuid == player.uuid);
          break;

        case ClientRequest.Reset_Character_Type:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }

          Player? player =engine.findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          player.type = CharacterType.Human;
          final spawnPoint = player.game.getNextSpawnPoint() ?? Vector2(0, 200);
          player.x = spawnPoint.x;
          player.y = spawnPoint.y;
          break;

        case ClientRequest.Upgrade_Ability:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }

          Player? player =engine.findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          if (player.abilityPoints < 1) {
            error(GameError.SkillPointsRequired);
            return;
          }

          int? upgradeIndex = int.tryParse(arguments[2]);
          if (upgradeIndex == null) {
            errorInvalidArg('arg[2] expected int but got $upgradeIndex');
            return;
          }
          if (upgradeIndex < 0) {
            errorInvalidArg('arg[2] $upgradeIndex must be greater than 0');
            return;
          }
          if (upgradeIndex > 4) {
            errorInvalidArg('arg[2] $upgradeIndex must be less than 5');
            return;
          }

          Ability ability = player.getAbilityByIndex(upgradeIndex);
          ability.level++;
          player.abilityPoints--;
          print("player.abilitiesDirty = true;");
          player.abilitiesDirty = true;
          player.dispatch(PlayerEvent.Skill_Upgraded);
          break;

        case ClientRequest.DeselectAbility:
          if (arguments.length != 2) {
            errorArgsExpected(2, arguments);
            return;
          }

          Player? player =engine.findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          player.ability = null;
          break;

        case ClientRequest.SelectAbility:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }

          Player? player =engine.findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          if (player.busy) return;
          if (player.dead) return;

          int? abilityIndex = int.tryParse(arguments[2]);
          if (abilityIndex == null) {
            errorInvalidArg('arg[2] expected int but got $abilityIndex');
            return;
          }
          if (abilityIndex < 0) {
            errorInvalidArg('arg[2] $abilityIndex must be greater than 0');
            return;
          }
          if (abilityIndex > 4) {
            errorInvalidArg('arg[2] $abilityIndex must be less than 5');
            return;
          }

          Ability ability = player.getAbilityByIndex(abilityIndex);

          if (ability.level < 1) {
            player.ability = null;
            error(GameError.SkillLocked);
            return;
          }

          Ability? playerAbility = player.ability;

          if (playerAbility != null && playerAbility.type == ability.type) {
            player.ability = null;
            return;
          }

          if (ability.cost > player.magic) {
            error(GameError.InsufficientMana);
            return;
          }

          if (ability.cooldownRemaining > 0) {
            error(GameError.Cooldown_Remaining);
            return;
          }

          if (ability is Dash) {
            ability.cooldownRemaining = ability.cooldown;
            ability.durationRemaining = ability.duration;
            player.speedModifier += dashSpeed;
            player.dispatch(PlayerEvent.Dash_Activated);
            break;
          }

          if (ability is IronShield) {
            ability.cooldownRemaining = ability.cooldown;
            ability.durationRemaining = ability.duration;
            player.invincible = true;
            break;
          }

          player.ability = ability;
          break;

        case ClientRequest.AcquireAbility:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }
          Player? player =engine.findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (player.dead) {
            errorPlayerDead();
            return;
          }
          if (player.busy) {
            return;
          }
          if (player.abilityPoints <= 0) {
            errorInsufficientSkillPoints();
            return;
          }

          int? weaponTypeIndex = int.tryParse(arguments[2]);
          if (weaponTypeIndex == null) {
            errorIntegerExpected(2, arguments[2]);
            return;
          }

          if (weaponTypeIndex >= weaponTypes.length) {
            errorInvalidArg(
                "WeaponType $weaponTypeIndex cannot be greater than ${weaponTypes.length}");
            return;
          }

          if (weaponTypeIndex < 0) {
            errorInvalidArg("WeaponType $weaponTypeIndex cannot be negative");
            return;
          }

          WeaponType type = weaponTypes[int.parse(arguments[2])];

          switch (type) {
            case WeaponType.Shotgun:
              player.weapons.add(
                  Weapon(type: WeaponType.Shotgun, damage: 1, capacity: 5));
              player.weaponsDirty = true;
              player.abilityPoints--;
              break;

            case WeaponType.HandGun:
              player.weapons.add(
                  Weapon(type: WeaponType.HandGun, damage: 1, capacity: 5));
              player.weaponsDirty = true;
              player.abilityPoints--;
              break;
          }
          break;

        case ClientRequest.Teleport:
          Player? player =engine.findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          double x = double.parse(arguments[2]);
          double y = double.parse(arguments[3]);
          player.x = x;
          player.y = y;
          break;

        case ClientRequest.Equip:
          if (arguments.length < 3) {
            error(GameError.InvalidArguments,
                message:
                "ClientRequest.Equip Error: Expected 2 args but got ${arguments.length}");
            return;
          }

          Player? player =engine.findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          int? weaponIndex = int.tryParse(arguments[2]);
          if (weaponIndex == null) {
            error(GameError.InvalidArguments,
                message: "arg4, weapon-index: $weaponIndex integer expected");
            return;
          }
          changeWeapon(player, weaponIndex);
          return;

        case ClientRequest.Purchase:
          if (arguments.length < 3) {
            return error(GameError.InvalidArguments,
                message:
                "ClientRequest.Purchase Error: Expected 2 args but got ${arguments.length}");
          }

          final player =engine.findPlayerByUuid(arguments[1]);
          if (player == null) {
            return errorPlayerNotFound();
          }

          if (player.dead){
            return errorPlayerDead();
          }

          if (player.busy){
            return errorPlayerBusy();
          }

          final slotItemIndexString = arguments[2];
          final slotItemIndex = int.tryParse(slotItemIndexString);
          if (slotItemIndex == null){
            return error(GameError.InvalidArguments,
                message:
                "ClientRequest.Purchase Error: could not parse argument 2 to int");
          }

          if (slotItemIndex < 0 || slotItemIndex >= slotTypes.all.length){
            return error(GameError.InvalidArguments,
                message:
                "$slotItemIndex is not a valid slot type index");
          }

          final slotType = slotTypes.all[slotItemIndex];
          player.acquire(slotType);
          return;

        case ClientRequest.SetCompilePaths:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }

          final player =engine.findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          final value = int.parse(arguments[2]);
          player.game.debugMode = value == 1;
          print("game.compilePaths = ${player.game.debugMode}");
          break;

        case ClientRequest.Version:
          reply('${ServerResponse.Version.index} $version');
          break;

        case ClientRequest.SkipHour:
          worldTime = (worldTime + secondsPerHour) % secondsPerDay;
          break;

        case ClientRequest.ReverseHour:
          worldTime = (worldTime - secondsPerHour) % secondsPerDay;
          break;

        case ClientRequest.Speak:
          Player? player =engine.findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          player.text = arguments
              .sublist(2, arguments.length)
              .fold("", (previousValue, element) => '$previousValue $element');
          player.textDuration = 150;
          break;

        case ClientRequest.Interact:
          Player? player =engine.findPlayerByUuid(arguments[1]);

          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (player.dead) {
            errorPlayerDead();
            return;
          }

          playerInteract(player);
      }
    }

    webSocket.stream.listen(onEvent);
  }
