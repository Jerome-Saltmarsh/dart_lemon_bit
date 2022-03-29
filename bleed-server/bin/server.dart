import 'package:bleed_server/firestoreClient/firestoreService.dart';
import 'package:bleed_server/system.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'byte_compiler.dart';
import 'classes/Game.dart';
import 'classes/Player.dart';
import 'common/AbilityMode.dart';
import 'common/CharacterAction.dart';
import 'common/CharacterState.dart';
import 'common/CharacterType.dart';
import 'common/ClientRequest.dart';
import 'common/GameError.dart';
import 'common/GameType.dart';
import 'common/Modify_Game.dart';
import 'common/RoyalCost.dart';
import 'common/ServerResponse.dart';
import 'common/SlotType.dart';
import 'common/SlotTypeCategory.dart';
import 'common/WeaponType.dart';
import 'common/compile_util.dart';
import 'common/enums/Direction.dart';
import 'common/version.dart';
import 'compile.dart';
import 'engine.dart';
import 'functions/generateName.dart';
import 'functions/withinRadius.dart';
import 'games/Moba.dart';
import 'games/world.dart';
import 'settings.dart';
import 'utilities.dart';

const _space = " ";
const _cursorRadius = 50.0;
final _errorIndex = ServerResponse.Error.index;
final _buffer = StringBuffer();
final _clientRequestsLength = clientRequests.length;

var totalConnections = 0;


void clearBuffer() {
  _buffer.clear();
}

void write(dynamic value) {
  _buffer.write(value);
  _buffer.write(_space);
}

Future main() async {
  print('gamestream.online server starting');
  print('v${version}');
  if (isLocalMachine){
    print("Environment Detected: Jerome's Computer");
  }else{
    print("Environment Detected: Google Cloud Machine");
  }
  await engine.init();
  startWebsocketServer();
}

void startWebsocketServer(){
  print("startWebsocketServer()");
  var handler = webSocketHandler(
      buildWebSocketHandler,
      protocols: ['gamestream.online'],
      // pingInterval: Duration(hours: 1),
  );

  shelf_io.serve(handler, settings.host, settings.port).then((server) {
    print('Serving at wss://${server.address.host}:${server.port}');
  }).catchError((error){
    print("Websocket error occurred");
    print(error);
  });
}

void buildWebSocketHandler(WebSocketChannel webSocket) {
    totalConnections++;
    print("New connection established. Total Connections $totalConnections");
    final sink = webSocket.sink;
    final started = DateTime.now();
    Player? _player;
    Account? _account;

    sink.done.then((value){
      totalConnections--;
      print("Connection Lost. Total Connections $totalConnections");
      final duration = started.difference(DateTime.now());
      print("Duration ${duration.inMinutes} minutes ${duration.inSeconds % 60} seconds");
      final closeReason = webSocket.closeReason;
      final closeCode = webSocket.closeCode;
      print("Close Reason: $closeReason");
      print("Close Code: $closeCode");
      _player = null;
      _account = null;
    });

    void reply(String response) {
      sink.add(response);
    }

    void sendAndClearBuffer() {
      reply(_buffer.toString());
      clearBuffer();
    }

    void compileAndSendPlayerGame(Player player){
      byteCompiler.writePlayerGame(player);
      final bytes = byteCompiler.writeToSendBuffer();
      sink.add(bytes);
    }

    void onGameJoined(){
      final player = _player;
      if (player == null) return;
      final account = _account;
      if (account != null) {
        player.name = account.publicName;
      }

      final game = player.game;
      compileAndSendPlayerGame(player);
      write(game.compiledTiles);
      write(game.compiledEnvironmentObjects);
      write(ServerResponse.Scene_Shade_Max.index);
      write(game.shadeMax);
      write(ServerResponse.Game_Status.index);
      write(game.status.index);
      compilePlayersRemaining(_buffer, 0);
      write('${ServerResponse.Game_Joined.index} ${player.id} ${player.uuid} ${game.id} ${player.team}');
      sendAndClearBuffer();
    }

    void joinGameSkirmish() {
      final game = engine.findGameSkirmish();
      _player = game.playerJoin();
      onGameJoined();
    }

    void joinGameMoba() {
      final moba = engine.findPendingMobaGame();
      _player = moba.playerJoin();
      onGameJoined();
    }

    void joinBattleRoyal() {
      final royal = engine.findPendingRoyalGames();
      _player = royal.playerJoin();
      onGameJoined();
    }

    void joinGameMMO() {
      clearBuffer();
      final account = _account;
      final player = engine.spawnPlayerInTown();
      _player = player;
      final orbs = player.orbs;
      player.name = account != null ? account.publicName : generateName();
      orbs.emerald = 100;
      orbs.topaz = 100;
      orbs.ruby = 100;
      onGameJoined();
    }

    void error(GameError error, {String message = ""}) {
      reply('$_errorIndex ${error.index} $message');
    }

    void errorInvalidArg(String message) {
      reply('$_errorIndex ${GameError.InvalidArguments.index} $message');
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

    void errorAccountNotFound() {
      error(GameError.Account_Not_Found);
    }

    void errorAccountRequired() {
      error(GameError.Account_Required);
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

    void onEvent(requestD) {

      final player = _player;


      if (requestD is List<int>){
        final List<int> args = requestD;

        final clientRequestInt = args[0];

        if (clientRequestInt >= _clientRequestsLength) {
          error(GameError.UnrecognizedClientRequest);
          return;
        }

        switch(clientRequests[clientRequestInt]){
          case ClientRequest.Update:

            if (player == null) {
              // errorPlayerNotFound();
              return;
            }

            player.lastUpdateFrame = 0;
            final game = player.game;

            if (game.awaitingPlayers) {
              compileGameStatus(_buffer, game.status);
              compileLobby(_buffer, game);
              compileGameMeta(_buffer, game);
              sendAndClearBuffer();
              return;
            }

            if (game.countingDown){
              compileGameStatus(_buffer, game.status);
              compileCountDownFramesRemaining(_buffer, game);
              sendAndClearBuffer();
              return;
            }

            if (game.finished) {
              compileGameStatus(_buffer, game.status);
              if (game is GameMoba) {
                compileTeamLivesRemaining(_buffer, game);
              }
              reply(_buffer.toString());
              return;
            }

            if (player.sceneChanged) {
              player.sceneChanged = false;
              _buffer.clear();
              _buffer.write(
                  '${ServerResponse.Scene_Changed.index} ${player.x.toInt()} ${player.y.toInt()} ');
              _buffer.write(game.compiledTiles);
              _buffer.write(game.compiledEnvironmentObjects);
              reply(_buffer.toString());
              return;
            }

            if (player.deadOrBusy) {
              compileAndSendPlayerGame(player);
              return;
            }

            final actionIndex = args[1];
            final mouseX = readNumberFromByteArray(args, index: 2).toDouble();
            final mouseY = readNumberFromByteArray(args, index: 4).toDouble();
            player.mouseX = mouseX;
            player.mouseY = mouseY;
            player.screenLeft = readNumberFromByteArray(args, index: 7).toDouble();
            player.screenTop = readNumberFromByteArray(args, index: 9).toDouble();
            player.screenRight = readNumberFromByteArray(args, index: 11).toDouble();
            player.screenBottom = readNumberFromByteArray(args, index: 13).toDouble();

            final action = characterActions[actionIndex];

            player.aimTarget = null;
            final closestEnemy = game.getClosestEnemy(mouseX, mouseY, player);
            if (closestEnemy != null) {
              if (withinDistance(
                  closestEnemy,
                  mouseX,
                  mouseY,
                  _cursorRadius
              )) {
                player.aimTarget = closestEnemy;
              }
            }

            switch (action) {
              case CharacterAction.Idle:
                if (player.target == null){
                  game.setCharacterState(player, CharacterState.Idle);
                }
                break;
              case CharacterAction.Perform:
                final ability = player.ability;
                final aimTarget = player.aimTarget;
                player.attackTarget = aimTarget;
                playerSetAbilityTarget(player, mouseX, mouseY);
                if (ability == null) {
                  if (aimTarget != null) {
                    player.target = aimTarget;
                    if (withinRadius(player, aimTarget, player.weapon.range)){
                      characterFaceV2(player, aimTarget);
                      game.setCharacterStatePerforming(player);
                    }
                  } else {
                    player.runTarget.x = mouseX;
                    player.runTarget.y = mouseY;
                    player.target = player.runTarget;
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
                    if (aimTarget != null) {
                      player.target = aimTarget;
                      player.attackTarget = aimTarget;
                      return;
                    } else {
                      player.runTarget.x = mouseX;
                      player.runTarget.y = mouseY;
                      player.target = player.runTarget;
                      return;
                    }
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

                player.magic -= ability.cost;
                player.performing = ability;
                ability.cooldownRemaining = ability.cooldown;
                player.ability = null;

                characterAimAt(player, mouseX, mouseY);
                game.setCharacterState(player, CharacterState.Performing);
                break;
              case CharacterAction.Run:
                final direction = directions[args[6]];
                player.angle = convertDirectionToAngle(direction);
                game.setCharacterStateRunning(player);
                player.target = null;
                break;
            }

            compileAndSendPlayerGame(player);
            return;

          default:
            throw Exception("Cannot parse ${clientRequests[clientRequestInt]}");
        }
      }

      if (requestD is String == false){
        throw Exception();
      }

      final String requestString = requestD;
      final arguments = requestString.split(_space);


      if (arguments.isEmpty) {
        error(GameError.ClientRequestArgumentsEmpty);
        return;
      }

      final clientRequestInt = int.tryParse(arguments[0]);
      if (clientRequestInt == null) {
        error(GameError.ClientRequestRequired);
        return;
      }

      if (clientRequestInt < 0) {
        error(GameError.UnrecognizedClientRequest);
        return;
      }

      if (clientRequestInt >= _clientRequestsLength) {
        error(GameError.UnrecognizedClientRequest);
        return;
      }

      final clientRequest = clientRequests[clientRequestInt];
      switch (clientRequest) {

        case ClientRequest.Join:
          if (arguments.length < 2) {
            errorArgsExpected(2, arguments);
            return;
          }
          final gameTypeIndex = int.parse(arguments[1]);

          if (gameTypeIndex >= gameTypes.length) {
            errorInvalidArg('game type index cannot exceed ${gameTypes.length - 1}');
            return;
          }
          if (gameTypeIndex < 0) {
            errorInvalidArg('game type must be greater than 0');
            return;
          }

          if (arguments.length > 2) {
            final userId = arguments[2];

            firestoreService.findUserById(userId).then((account){
               if (account == null) {
                 return errorAccountNotFound();
               }
               _account = account;
               final gameType = gameTypes[gameTypeIndex];

               switch (gameType) {
                 case GameType.None:
                   throw Exception("Join Game - GameType.None invalid");
                 case GameType.MMO:
                   return joinGameMMO();
                 case GameType.Moba:
                   return joinGameMoba();
                 case GameType.BATTLE_ROYAL:
                   return joinBattleRoyal();
                 case GameType.SKIRMISH:
                   return joinGameSkirmish();
               }
            });
            return;
          }

          final gameType = gameTypes[gameTypeIndex];

          switch (gameType) {
            case GameType.None:
              throw Exception("Join Game - GameType.None invalid");
            case GameType.MMO:
              return joinGameMMO();
            case GameType.Moba:
              return joinGameMoba();
            case GameType.BATTLE_ROYAL:
              return joinBattleRoyal();
            case GameType.SKIRMISH:
              return joinGameSkirmish();
            default:
              throw Exception("Cannot join ${gameType}");
          }

        case ClientRequest.Teleport:
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          player.x = double.parse(arguments[1]);
          player.y = double.parse(arguments[2]);
          return;

        case ClientRequest.Join_Custom:
          if (arguments.length < 3) {
            errorArgsExpected(3, arguments);
            return;
          }
          final mapId = arguments[1];
          engine.findOrCreateCustomGame(mapId).then((value){
            _player = value.playerJoin();
            onGameJoined();
          });
          break;

        case ClientRequest.Ping:
          reply(ServerResponse.Pong.index.toString());
          break;

        case ClientRequest.Character_Load:
          final account = _account;
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (account == null) {
            errorAccountRequired();
            return;
          }
          firestoreService.loadCharacter(account).then((response){
            player.x = double.parse(response['x']);
            player.y = double.parse(response['y']);
          });

          break;

        case ClientRequest.Character_Save:
          final account = _account;
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (account == null) {
            errorAccountRequired();
            return;
          }

          firestoreService.saveCharacter(
            account: account,
            x: player.x,
            y: player.y,
          );
          break;

        case ClientRequest.Revive:
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

          final player = _player;
          if (player == null) {
            return errorPlayerNotFound();
          }

          final slotTypeCategoryIndex = int.tryParse(arguments[1]);
          if (slotTypeCategoryIndex == null){
            return errorIntegerExpected(1, arguments[1]);
          }
          if (slotTypeCategoryIndex < 0 || slotTypeCategoryIndex >= slotTypeCategories.length) {
            return errorInvalidArg('inventory index out of bounds: $slotTypeCategoryIndex');
          }

          final slotTypeCategory = slotTypeCategories[slotTypeCategoryIndex];
          player.unequip(slotTypeCategory);
          break;

        case ClientRequest.Equip_Slot:
          if (arguments.length != 2) {
            return errorArgsExpected(2, arguments);
          }

          if (player == null) {
            return errorPlayerNotFound();
          }

          final inventoryIndex = int.tryParse(arguments[1]);
          if (inventoryIndex == null){
            return errorIntegerExpected(1, arguments[1]);
          }
          if (inventoryIndex < 1 || inventoryIndex > 6) {
            return errorInvalidArg('inventory index out of bounds');
          }

          player.useSlot(inventoryIndex);
          break;

        case ClientRequest.Sell_Slot:
          final player = _player;
          if (player == null) {
            return errorPlayerNotFound();
          }

          final inventoryIndex = int.tryParse(arguments[1]);
          if (inventoryIndex == null){
            return errorIntegerExpected(1, arguments[1]);
          }
          if (inventoryIndex < 1 || inventoryIndex > 6) {
            return errorInvalidArg('inventory index out of bounds');
          }
          player.sellSlot(inventoryIndex);
          break;

        case ClientRequest.Modify_Game:

          if (arguments.length != 2) {
            errorArgsExpected(2, arguments);
            return;
          }

          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          final modifyGameIndex = int.tryParse(arguments[1]);
          if (modifyGameIndex == null){
            errorIntegerExpected(1, arguments[1]);
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

          final modifyGame = gameModifications[modifyGameIndex];
          switch(modifyGame){
            case ModifyGame.Spawn_Zombie:
              player.game.spawnZombie(
                x: player.mouseX,
                y: player.mouseY,
                damage: 1,
                health: 5,
                team: 100,
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

          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          player.type = CharacterType.Human;
          final spawnPoint = player.game.getNextSpawnPoint();
          player.x = spawnPoint.x;
          player.y = spawnPoint.y;
          break;

        case ClientRequest.Upgrade_Ability:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }

          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          if (player.abilityPoints < 1) {
            error(GameError.SkillPointsRequired);
            return;
          }

          final upgradeIndex = int.tryParse(arguments[2]);
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

          break;

        case ClientRequest.DeselectAbility:
          if (arguments.length != 2) {
            errorArgsExpected(2, arguments);
            return;
          }

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
          break;

        case ClientRequest.AcquireAbility:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }
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

          final type = weaponTypes[int.parse(arguments[2])];

          switch (type) {
            case WeaponType.Shotgun:
              // player.weapons.add(
              //     Weapon(type: WeaponType.Shotgun, damage: 1, capacity: 5));
              // player.weaponsDirty = true;
              // player.abilityPoints--;
              break;

            case WeaponType.HandGun:
              // player.weapons.add(
              //     Weapon(type: WeaponType.HandGun, damage: 1, capacity: 5));
              // player.weaponsDirty = true;
              // player.abilityPoints--;
              break;
          }
          break;

        case ClientRequest.Equip:
          if (arguments.length < 3) {
            error(GameError.InvalidArguments,
                message:
                "ClientRequest.Equip Error: Expected 2 args but got ${arguments.length}");
            return;
          }

          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          final weaponIndex = int.tryParse(arguments[2]);
          if (weaponIndex == null) {
            error(GameError.InvalidArguments,
                message: "arg4, weapon-index: $weaponIndex integer expected");
            return;
          }
          // changeWeapon(player, weaponIndex);
          return;

        case ClientRequest.Purchase:
          if (arguments.length < 2) {
            return error(GameError.InvalidArguments,
                message:
                "ClientRequest.Purchase Error: Expected 2 args but got ${arguments.length}");
          }

          if (player == null) {
            return errorPlayerNotFound();
          }

          if (player.dead){
            return errorPlayerDead();
          }

          if (player.busy){
            return errorPlayerBusy();
          }

          final slotItemIndexString = arguments[1];
          final slotItemIndex = int.tryParse(slotItemIndexString);
          if (slotItemIndex == null){
            return error(GameError.InvalidArguments,
                message:
                "ClientRequest.Purchase Error: could not parse argument 2 to int");
          }

          if (slotItemIndex < 0 || slotItemIndex >= slotTypes.length){
            return error(GameError.InvalidArguments,
                message:
                "$slotItemIndex is not a valid slot type index");
          }
          if (!player.slots.emptySlotAvailable) return;
          final slotType = slotTypes[slotItemIndex];
          final cost = slotTypeCosts[slotType];
          if (cost != null) {
              if (cost.topaz > player.orbs.topaz) return;
              if (cost.rubies > player.orbs.ruby) return;
              if (cost.emeralds > player.orbs.emerald) return;
              player.orbs.topaz -= cost.topaz;
              player.orbs.ruby -= cost.rubies;
              player.orbs.emerald -= cost.emeralds;
          }
          player.acquire(slotType);
          return;

        case ClientRequest.SetCompilePaths:

          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          final game = player.game;
          game.debugMode = !game.debugMode;
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
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          player.text = arguments
              .sublist(1, arguments.length)
              .fold("", (previousValue, element) => '$previousValue $element');
          player.textDuration = 150;
          break;

        case ClientRequest.Interact:
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

    webSocket.stream.listen(onEvent, onError: (Object error, StackTrace stackTrace){
      print("connection error");
      print(error);
      print(stackTrace);
    });
}

