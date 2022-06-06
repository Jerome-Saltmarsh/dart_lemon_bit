import 'package:bleed_server/firestoreClient/firestoreService.dart';
import 'package:bleed_server/system.dart';
import 'package:lemon_math/functions/vector2.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'classes/library.dart';
import 'common/card_type.dart';
import 'common/library.dart';
import 'compile.dart';
import 'engine.dart';
import 'functions/generateName.dart';
import 'functions/withinRadius.dart';
import 'games/game_random.dart';
import 'physics.dart';

const _space = " ";
const _errorIndex = ServerResponse.Error;
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

  shelf_io.serve(handler, '0.0.0.0', 8080).then((server) {
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

    void sendBufferToClient(){
     final player = _player;
     if (player == null) return;
     sink.add(player.writeToSendBuffer());
    }

    void error(GameError error, {String message = ""}) {
      reply('${ServerResponse.Error} ${error.index} $message');
    }

    void onGameJoined(){
      final player = _player;
      if (player == null) return;
      player.sendBufferToClient = sendBufferToClient;
      player.dispatchError = error;
      final account = _account;
      final game = player.game;
      if (account != null) {
        player.name = account.publicName;
      } else {
        while(true){
          final randomName = generateRandomName();
          if (game.containsPlayerWithName(randomName)) continue;
          player.name = randomName;
          break;
        }
      }
      game.onPlayerJoined(player);
      player.writeGameStatus();
    }

    void joinGameRandom(CharacterSelection characterClass) {
      final game = engine.findRandomGame();
      _player = game.playerJoin(characterClass);
      onGameJoined();
    }

    void errorInvalidArg(String message) {
      reply('$_errorIndex ${GameError.InvalidArguments.index} $message');
    }

    void errorInsufficientResources(){
      error(GameError.Insufficient_Resources);
    }

    void errorArgsExpected(int expected, List arguments) {
      errorInvalidArg(
          'Invalid number of arguments received. Expected $expected but got ${arguments.length}');
    }

    void errorInsufficientArgs(int expected, List arguments){
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

    // void errorAccountNotFound() {
    //   error(GameError.Account_Not_Found);
    // }

    void errorAccountRequired() {
      error(GameError.Account_Required);
    }

    void errorPlayerDead() {
      error(GameError.PlayerDead);
    }

    void onEvent(dynamic requestD) {

      final player = _player;

      if (requestD is List<int>) {
        final List<int> args = requestD;

        final clientRequestInt = args[0];

        if (clientRequestInt >= _clientRequestsLength) {
          error(GameError.UnrecognizedClientRequest);
          return;
        }

        if (clientRequestInt == 0) { // ClientRequest.Update.index
          if (player == null) {
            return;
          }

          if (player.lastUpdateFrame == 0){
            return;
          }
          player.lastUpdateFrame = 0;

          final game = player.game;

          if (game.awaitingPlayers) {
            compileGameStatus(_buffer, game.status);
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
            reply(_buffer.toString());
            return;
          }

          if (player.sceneChanged) {
            player.sceneChanged = false;
            _buffer.clear();
            _buffer.write(
                '${ServerResponse.Scene_Changed} ${player.x.toInt()} ${player.y.toInt()} ');
            // _buffer.write(game.compiledTiles);
            // _buffer.write(game.compiledEnvironmentObjects);
            player.sceneDownloaded = false;
            reply(_buffer.toString());
            return;
          }

          final mouseX = readNumberFromByteArray(args, index: 2).toDouble();
          final mouseY = readNumberFromByteArray(args, index: 4).toDouble();
          player.mouse.x = mouseX;
          player.mouse.y = mouseY;
          player.screenLeft = readNumberFromByteArray(args, index: 7).toDouble();
          player.screenTop = readNumberFromByteArray(args, index: 9).toDouble();
          player.screenRight = readNumberFromByteArray(args, index: 11).toDouble();
          player.screenBottom = readNumberFromByteArray(args, index: 13).toDouble();

          if (player.deadOrBusy) {
            return;
          }

          player.aimTarget = null;
          final closestCollider = game.getClosestCollider(mouseX, mouseY, player);
          if (closestCollider != null) {
            if (withinDistance(
                closestCollider,
                mouseX,
                mouseY,
                35.0, // cursor radius
            )) {
              player.aimTarget = closestCollider;
            }
          }
          switch (args[1]) {
            case CharacterAction.Idle:
              if (player.target == null){
                game.setCharacterState(player, CharacterState.Idle);
              }
              break;
            case CharacterAction.Perform:
              final ability = player.ability;
              final aimTarget = player.aimTarget;
              player.target = aimTarget;

              if (aimTarget is GameObject) {
                 if (aimTarget.isRock && player.equippedWeapon != TechType.Pickaxe) {
                    if (player.techTree.pickaxe > 0){
                      player.equipPickaxe();
                    } else if (!player.unarmed) {
                      player.equipUnarmed();
                    }
                 } else
                 if (aimTarget.isTree && player.equippedWeapon != TechType.Axe) {
                   if (player.techTree.axe > 0){
                     player.equipAxe();
                   } else if (!player.unarmed) {
                     player.equipUnarmed();
                   }
                 }
              }

              if (ability == null) {
                if (aimTarget != null) {
                  player.target = aimTarget;
                  if (withinRadius(player, aimTarget, player.equippedRange)){
                    player.face(aimTarget);
                    game.setCharacterStatePerforming(player);
                  }
                } else {
                  player.runTarget.x = mouseX;
                  player.runTarget.y = mouseY;
                  player.target = player.runTarget;
                }
                break;
              }

              if (ability.cooldownRemaining > 0) {
                return error(GameError.Cooldown_Remaining);
              }

              switch (ability.mode) {
                case AbilityMode.Targeted:
                  if (aimTarget != null) {
                    player.target = aimTarget;
                    return;
                  } else {
                    player.runTarget.x = mouseX;
                    player.runTarget.y = mouseY;
                    player.target = player.runTarget;
                    return;
                  }
                case AbilityMode.Activated:
                  ability.cooldownRemaining = ability.cooldown;
                  break;
                case AbilityMode.Area:
                  player.target = Vector2(mouseX, mouseY);
                  break;
                case AbilityMode.Directed:
                  ability.cooldownRemaining = ability.cooldown;
                  player.face(player.mouse);
                  game.setCharacterState(player, CharacterState.Performing);
                  break;
              }

              break;
            case CharacterAction.Run:
              player.angle =  args[6] * 0.78539816339; // 0.78539816339 == pi / 4
              game.setCharacterStateRunning(player);
              player.target = null;
              break;
          }

          return;
        }
        throw Exception("Cannot parse ${clientRequests[clientRequestInt]}");
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
          if (arguments.length < 2) return errorInsufficientArgs(2, arguments);

          final gameTypeIndex = int.tryParse(arguments[1]);

          if (!isValidIndex(gameTypeIndex, gameTypes)) return errorInvalidArg('');

          final gameType = gameTypes[gameTypeIndex!];

          switch(gameType){
            case GameType.RANDOM:
              if (arguments.length < 3) return errorInsufficientArgs(3, arguments);

              final characterClassIndex = int.tryParse(arguments[2]);
              if (characterClassIndex == null){
                return errorInvalidArg('index required');
              }
              if (!isValidIndex(characterClassIndex, characterSelections)){
                return errorInvalidArg('characterClassIndex');
              }
              final characterClass = characterSelections[characterClassIndex];
              return joinGameRandom(characterClass);
            case GameType.FRONTLINE:
              // TODO: Handle this case.
              break;
          }

          break;

          // if (characterClassIndex >= gameTypes.length) {
          //   errorInvalidArg('game type index cannot exceed ${gameTypes.length - 1}');
          //   return;
          // }
          // if (characterClassIndex < 0) {
          //   errorInvalidArg('game type must be greater than 0');
          //   return;
          // }

          // if (arguments.length > 2) {
          //   final userId = arguments[2];
          //
          //   firestoreService.findUserById(userId).then((account){
          //      if (account == null) {
          //        return errorAccountNotFound();
          //      }
          //      _account = account;
          //      final gameType = gameTypes[characterClassIndex];
          //
          //      switch (gameType) {
          //        case GameType.RANDOM:
          //          return joinGameRandom();
          //        case GameType.SURVIVORS:
          //          return joinGameSurvivors();
          //        default:
          //          break;
          //      }
          //   });
          //   return;
          // }
          // switch (characterClass) {
          //   case GameType.RANDOM:
          //     return joinGameRandom();
          //   case GameType.SURVIVORS:
          //     return joinGameSurvivors();
          //   default:
          //     throw Exception("Cannot join ${characterClass}");
          // }

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
          // final mapId = arguments[1];
          // engine.findOrCreateCustomGame(mapId).then((value){
          //   _player = value.playerJoin();
          //   onGameJoined();
          // });
          break;

        case ClientRequest.Construct:
          if (player == null) {
            return errorPlayerNotFound();
          }
          if (arguments.length < 2) {
            return errorArgsExpected(2, arguments);
          }
          final structureType = int.tryParse(arguments[1]);
          if (structureType == null) {
            return errorInvalidArg('arg int required');
          }
          if (!StructureType.isValid(structureType)){
            return errorInvalidArg('Invalid StructureType $structureType');
          }
          final cost = StructureType.getCost(structureType);

          if (
            cost.wood > player.wood ||
            cost.gold > player.gold ||
            cost.stone > player.stone
          ) {
            return error(GameError.Construct_Insufficient_Resources);
          }
          final mouse = player.mouse;
          if (!Tile.isBuildable(player.game.scene.getTileAtXY(mouse.x, mouse.y))) {
            return error(GameError.Construct_Invalid_Tile);
          }
          final mouseSnapX = snapX(mouse.x, mouse.y);
          final mouseSnapY = snapY(mouse.x, mouse.y);

          if (sphereCaste(
              colliders: player.game.gameObjects,
              x: mouseSnapX,
              y: mouseSnapY,
              radius: tileSizeHalf
          ) != null) {
            return error(GameError.Construct_Area_Not_Available);
          }

          if (sphereCaste(
              colliders: player.game.zombies,
              x: mouseSnapX,
              y: mouseSnapY,
              radius: tileSizeHalf
          ) != null) {
            return error(GameError.Construct_Area_Not_Available);
          }

          if (sphereCaste(
              colliders: player.game.players,
              x: mouseSnapX,
              y: mouseSnapY,
              radius: tileSizeHalf
          ) != null) {
            return error(GameError.Construct_Area_Not_Available);
          }

          if (sphereCaste(
              colliders: player.game.gameObjects,
              x: mouseSnapX,
              y: mouseSnapY,
              radius: tileSizeHalf
          ) != null) {
            return error(GameError.Construct_Area_Not_Available);
          }

          // TODO Shift game logic to game class
          player.game.structures.add(
              Structure(
                type: structureType,
                x: mouseSnapX,
                y: mouseSnapY,
                team: player.team,
                attackRate: 200,
                attackDamage: 3,
                owner: player,
                health: 20,
              )
          );
          player.stone -= cost.stone;
          player.wood -= cost.wood;
          player.gold -= cost.gold;

          if (structureType == StructureType.Torch) {
            player.game.scene.getNodeByPosition(player.mouse).obstructed = true;
          } else {
            player.game.scene.getNodeByPosition(player.mouse).open = false;
          }
          break;

        case ClientRequest.Character_Load:
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          final account = _account;
          if (account == null) {
            errorAccountRequired();
            return;
          }
          firestoreService.loadCharacter(account).then((response){
            player.x = double.parse(response['x']);
            player.y = double.parse(response['y']);
          });

          break;

        case ClientRequest.Toggle_Objects_Destroyable:
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          final game = player.game;
          game.playersCanAttackDynamicObjects = !game.playersCanAttackDynamicObjects;
          break;

        case ClientRequest.Skip_Hour:
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          final game = player.game;
          if (game is GameRandom){
            game.time += 3600;
          }
          break;

        case ClientRequest.Reverse_Hour:
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          final game = player.game;
          if (game is GameRandom){
            game.time -= 3600;
          }
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

        case ClientRequest.Unequip_Slot:

          // final player = _player;
          // if (player == null) {
          //   return errorPlayerNotFound();
          // }
          //
          // final slotTypeCategoryIndex = int.tryParse(arguments[1]);
          // if (slotTypeCategoryIndex == null){
          //   return errorIntegerExpected(1, arguments[1]);
          // }
          // if (slotTypeCategoryIndex < 0 || slotTypeCategoryIndex >= slotTypeCategories.length) {
          //   return errorInvalidArg('inventory index out of bounds: $slotTypeCategoryIndex');
          // }
          //
          // final slotTypeCategory = slotTypeCategories[slotTypeCategoryIndex];
          // player.unequip(slotTypeCategory);
          break;

        case ClientRequest.Equip_Slot:
          // if (arguments.length != 2) {
          //   return errorArgsExpected(2, arguments);
          // }
          //
          // if (player == null) {
          //   return errorPlayerNotFound();
          // }
          //
          // final inventoryIndex = int.tryParse(arguments[1]);
          // if (inventoryIndex == null){
          //   return errorIntegerExpected(1, arguments[1]);
          // }
          // if (inventoryIndex < 1 || inventoryIndex > 6) {
          //   return errorInvalidArg('inventory index out of bounds');
          // }
          //
          // player.useSlot(inventoryIndex);
          break;

        case ClientRequest.Sell_Slot:
          // final player = _player;
          // if (player == null) {
          //   return errorPlayerNotFound();
          // }
          //
          // final inventoryIndex = int.tryParse(arguments[1]);
          // if (inventoryIndex == null){
          //   return errorIntegerExpected(1, arguments[1]);
          // }
          // if (inventoryIndex < 1 || inventoryIndex > 6) {
          //   return errorInvalidArg('inventory index out of bounds');
          // }
          // player.sellSlot(inventoryIndex);
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
                x: player.mouse.x,
                y: player.mouse.y,
                damage: 1,
                health: 5,
                team: 100,
              );
              break;
            case ModifyGame.Remove_Zombie:
            // TODO: Handle this case.
              break;
            case ModifyGame.Hour_Increase:
              // worldTime += secondsPerHour;
              break;
            case ModifyGame.Hour_Decrease:
              // worldTime -= secondsPerHour;
              break;
          }
          break;

        case ClientRequest.Scene:
          // onGameJoined();
          // player?.writeTiles();
          // compileAndSendPlayer();
          break;

        case ClientRequest.Deck_Select_Card:
          if (player == null) return errorPlayerNotFound();
          if (player.dead) return errorPlayerDead();
          if (arguments.length != 2) return errorArgsExpected(2, arguments);
          final deckIndex = int.tryParse(arguments[1]);
          if (deckIndex == null) {
            return errorInvalidArg('card choice index required: got ${arguments[1]}');
          }
          if (!isValidIndex(deckIndex, player.deck)){
            return errorInvalidArg('Invalid deck index $deckIndex');
          }
          final card = player.deck[deckIndex];

          if (player.ability == card){
             player.clearCardAbility();
             return;
          }

          if (card is CardAbility && card.cooldownRemaining <= 0) {
            player.setCardAbility(card);
          }
          break;

        case ClientRequest.Deck_Add_Card:
          if (player == null) {
            return errorPlayerNotFound();
          }
          if (player.cardChoices.isEmpty){
            return error(GameError.Choose_Card, message: "card choices empty");
          }
          if (arguments.length != 2) {
            return errorArgsExpected(2, arguments);
          }
          final cardTypeIndex = int.tryParse(arguments[1]);
          if (cardTypeIndex == null) {
            return errorInvalidArg('card choice index required: got ${arguments[1]}');
          }
          if (!isValidIndex(cardTypeIndex, cardTypes)){
            return errorInvalidArg('invalid card type index: $cardTypeIndex');
          }
          final cardType = cardTypes[cardTypeIndex];
          if (!player.cardChoices.contains(cardType)){
            return error(GameError.Choose_Card, message: 'selected card is not a choice');
          }
          player.game.onPlayerAddCardToDeck(player, cardType);
          break;

        case ClientRequest.Select_Character_Type:
          if (player == null) {
            return errorPlayerNotFound();
          }
          // if (!player.characterSelectRequired){
          //   return error(GameError.Character_Select_Not_Required);
          // }
          if (arguments.length != 2) {
            return errorArgsExpected(2, arguments);
          }
          final characterSelectIndex = int.tryParse(arguments[1]);
          if (characterSelectIndex == null){
            return errorInvalidArg('character select integer required: got ${arguments[1]}');
          }
          if (!isValidIndex(characterSelectIndex, characterSelections)){
            return errorInvalidArg('invalid character selection index');
          }
          final selection = characterSelections[characterSelectIndex];
          player.game.onPlayerSelectCharacterType(player, selection);
          player.game.revive(player);
          break;

        case ClientRequest.Upgrade:
          if (player == null) {
            return errorPlayerNotFound();
          }
          if (player.deadOrBusy) return;
          if (arguments.length != 2) {
            return errorArgsExpected(2, arguments);
          }
          final techType = int.tryParse(arguments[1]);
          if (techType == null) {
            return errorInvalidArg('tech type integer required: got ${arguments[1]}');
          }
          if (!TechType.isValid(techType)) {
            return errorInvalidArg('invalid tech type index $techType');
          }
          final cost = TechType.getCost(
              techType,
              player.getTechTypeLevel(techType)
          );
          if (cost == null) return;
          if (cost.wood > player.wood) return errorInsufficientResources();
          if (cost.gold > player.gold) return errorInsufficientResources();
          if (cost.stone > player.stone) return errorInsufficientResources();

          player.wood -= cost.wood;
          player.gold -= cost.gold;
          player.stone -= cost.stone;

          switch (techType) {
            case TechType.Pickaxe:
              player.techTree.pickaxe++;
              if (player.techTree.pickaxe == 1) {
                 player.equippedWeapon = TechType.Pickaxe;
                 player.setStateChanging();
              }
              player.writePlayerEvent(PlayerEvent.Item_Purchased);
              break;
            case TechType.Bow:
              player.techTree.bow++;
              if (player.techTree.bow == 1) {
                player.equippedWeapon = TechType.Bow;
                player.setStateChanging();
              }
              player.writePlayerEvent(PlayerEvent.Item_Purchased);
              break;
            case TechType.Sword:
              player.techTree.sword++;
              if (player.techTree.sword == 1) {
                player.equippedWeapon = TechType.Sword;
                player.setStateChanging();
              }
              player.writePlayerEvent(PlayerEvent.Item_Purchased);
              break;
            case TechType.Axe:
              player.techTree.axe++;
              if (player.techTree.axe == 1) {
                player.equippedWeapon = TechType.Axe;
                player.setStateChanging();
              }
              player.writePlayerEvent(PlayerEvent.Item_Purchased);
              break;
            case TechType.Hammer:
              player.techTree.hammer++;
              if (player.techTree.hammer == 1) {
                player.equippedWeapon = TechType.Hammer;
                player.setStateChanging();
              }
              player.writePlayerEvent(PlayerEvent.Item_Purchased);
              break;
          }
          player.writeTechTypes();
          break;

        case ClientRequest.Attack:
          if (player == null) return;
          if (player.deadOrBusy) return;
          player.target = null;
          player.angle = player.mouseAngle;
          player.game.setCharacterStatePerforming(player);
          break;

        case ClientRequest.Attack_Secondary:
          if (player == null) return;
          if (player.deadOrBusy) return;

          if (player.ability != null) {
            player.clearCardAbility();
            return;
          }
          player.target = null;
          player.angle = player.mouseAngle;
          player.game.setCharacterStatePerforming(player);
          break;

        case ClientRequest.Equip:
          if (player == null) {
            return errorPlayerNotFound();
          }
          if (player.deadOrBusy) return;
          if (arguments.length != 2) {
            return errorArgsExpected(2, arguments);
          }
          final techType = int.tryParse(arguments[1]);
          if (techType == null){
            return errorInvalidArg('tech type integer required: got $techType');
          }
          if (!TechType.isValid(techType)){
            return errorInvalidArg('Invalid tech type: got $techType');
          }
          player.equippedWeapon = techType;
          player.setStateChanging();
          return;

        case ClientRequest.Purchase:
          // if (arguments.length < 2) {
          //   return error(GameError.InvalidArguments,
          //       message:
          //       "ClientRequest.Purchase Error: Expected 2 args but got ${arguments.length}");
          // }
          //
          // if (player == null) {
          //   return errorPlayerNotFound();
          // }
          //
          // if (player.dead){
          //   return errorPlayerDead();
          // }
          //
          // if (player.busy){
          //   return errorPlayerBusy();
          // }
          //
          // final slotItemIndexString = arguments[1];
          // final slotItemIndex = int.tryParse(slotItemIndexString);
          // if (slotItemIndex == null){
          //   return error(GameError.InvalidArguments,
          //       message:
          //       "ClientRequest.Purchase Error: could not parse argument 2 to int");
          // }
          //
          // if (slotItemIndex < 0){
          //   return error(GameError.InvalidArguments,
          //       message:
          //       "$slotItemIndex is not a valid slot type index");
          // }
          // if (!player.slots.emptySlotAvailable) return;
          // final slotType = slotItemIndex;
          // player.acquire(slotType);
          return;

        case ClientRequest.Toggle_Debug:
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          player.toggleDebug();
          break;

        case ClientRequest.Version:
          reply('${ServerResponse.Version} $version');
          break;

        case ClientRequest.Skip_Hour:
          // worldTime = (worldTime + secondsPerHour) % secondsPerDay;
          break;

        case ClientRequest.Reverse_Hour:
          // worldTime = (worldTime - secondsPerHour) % secondsPerDay;
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

        default:
          break;
      }
    }

    webSocket.stream.listen(onEvent, onError: (Object error, StackTrace stackTrace){
      print("connection error");
      print(error);
      print(stackTrace);
    });
}

bool isValidIndex(int? index, List values){
    if (index == null) return false;
   if (values.isEmpty) return false;
   if (index < 0) return false;
   return index < values.length;
}