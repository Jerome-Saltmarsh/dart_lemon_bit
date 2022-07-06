import 'package:bleed_server/firestoreClient/firestoreService.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../classes/library.dart';
import '../classes/position3.dart';
import '../common/library.dart';
import '../dark_age/game_dark_age.dart';
import '../engine.dart';
import '../functions/generateName.dart';
import '../functions/withinRadius.dart';
import '../io/save_directory.dart';
import '../io/write_scene_to_file.dart';
import '../utilities/is_valid_index.dart';

class Connection {
  final started = DateTime.now();
  late WebSocketChannel webSocket;
  late WebSocketSink sink;
  Player? _player;
  Account? _account;

  Function? onDone;

  Connection(this.webSocket){
    sink = webSocket.sink;

    sink.done.then((value){
      _player = null;
      _account = null;
      onDone?.call();
    });

    webSocket.stream.listen(onData, onError: onStreamError);
  }

  void onStreamError(Object error, StackTrace stackTrace){
    print("onStreamError()");
    print(error);
    print(stackTrace);
  }

  void reply(String response) {
    sink.add(response);
  }

  void sendBufferToClient(){
    final player = _player;
    if (player == null) return;
    sink.add(player.writeToSendBuffer());
  }

  void error(GameError error, {String message = ""}) {
    reply('${ServerResponse.Error} ${error.index} $message');
  }

  void onData(dynamic args) {
    if (args is List<int>) {
      return handleClientRequestUpdate(args);
    }
    if (args is String) {
      return onDataStringArray(args.split(" "));
    }
    throw Exception("Invalid arg type");
  }

  void onDataStringArray(List<String> arguments) {
    if (arguments.isEmpty) {
      error(GameError.ClientRequestArgumentsEmpty);
      return;
    }

    final clientRequestInt = int.tryParse(arguments[0]);

    if (clientRequestInt == null)
      return error(GameError.ClientRequestRequired);

    if (clientRequestInt < 0)
      return error(GameError.UnrecognizedClientRequest);

    if (clientRequestInt >= clientRequestsLength)
      return error(GameError.UnrecognizedClientRequest);

    final clientRequest = clientRequests[clientRequestInt];

    if (clientRequest == ClientRequest.Join)
      return handleClientRequestJoin(arguments);

    final player = _player;

    if (player == null) return errorPlayerNotFound();
    final game = player.game;

    switch (clientRequest) {

      case ClientRequest.Teleport:
        handleClientRequestTeleport(player);
        return;

      case ClientRequest.Skip_Hour:
        if (game is GameDarkAge){
          game.time = (game.time + secondsPerHour) % secondsPerDay;
        }
        break;

      case ClientRequest.Spawn_Zombie:
        if (arguments.length < 4) return errorInsufficientArgs(4, arguments);

        final z = int.tryParse(arguments[1]);
        if (z == null) return errorInvalidArg('z');
        final row = int.tryParse(arguments[2]);
        if (row == null) return errorInvalidArg('row');
        final column = int.tryParse(arguments[3]);
        if (column == null) return errorInvalidArg('column');

        game.spawnZombie(
            x: row * tileSize + tileSizeHalf,
            y: column * tileSize + tileSizeHalf,
            z: z * tileHeight,
            health: 10,
            team: 0,
            damage: 1
        );
        return;

      case ClientRequest.Reverse_Hour:
        if (game is GameDarkAge){
          game.time = (game.time - 3600) % secondsPerDay;
        }
        break;

      case ClientRequest.Set_Weapon:
        if (arguments.length < 2)  return errorArgsExpected(2, arguments);
        final weaponType = int.tryParse(arguments[1]);
        if (weaponType == null) return errorInvalidArg('weapon type');
        player.equippedWeapon = Weapon(type: weaponType, damage: 1);
        player.setStateChanging();
        break;

      case ClientRequest.Set_Armour:
        if (arguments.length < 2)  return errorArgsExpected(2, arguments);
        final armourType = int.tryParse(arguments[1]);
        if (armourType == null) return errorInvalidArg('armour type');
        player.equippedArmour = armourType;
        player.setStateChanging();
        break;

      case ClientRequest.Set_Head_Type:
        if (arguments.length < 2)  return errorArgsExpected(2, arguments);
        final type = int.tryParse(arguments[1]);
        if (type == null) return errorInvalidArg('invalid head type $type');
        player.equippedHead = type;
        player.setStateChanging();
        break;

      case ClientRequest.Set_Pants_Type:
        if (arguments.length < 2)  return errorArgsExpected(2, arguments);
        final type = int.tryParse(arguments[1]);
        if (type == null) return errorInvalidArg('invalid head type $type');
        player.equippedPants = type;
        player.setStateChanging();
        break;

      case ClientRequest.Upgrade_Weapon_Damage:
        player.equippedWeapon.damage++;
        break;

      case ClientRequest.Purchase_Weapon:
        final type = int.tryParse(arguments[1]);
        if (type == null) return errorInvalidArg('invalid weapon type $type');
        player.weapons.add(
            Weapon(
              type: type,
              damage: 1,
            )
        );
        player.writePlayerWeapons();
        player.writePlayerEvent(PlayerEvent.Item_Purchased);
        break;

      case ClientRequest.Store_Close:
        player.storeItems = [];
        player.writeStoreItems();
        break;

      case ClientRequest.Weather_Set_Rain:
        final rainIndex = int.tryParse(arguments[1]);
        if (rainIndex == null || !isValidIndex(rainIndex, rainValues))
           return errorInvalidArg('invalid rain index: $rainIndex');

        player.game.raining = rainValues[rainIndex];
        break;

      case ClientRequest.Weather_Toggle_Breeze:
        game.toggleBreeze();
        break;

      case ClientRequest.Weather_Set_Wind:
        final index = int.tryParse(arguments[1]);
        if (index == null || !isValidIndex(index, windValues))
          return errorInvalidArg('invalid rain index: $index');

        player.game.wind = index;
        break;

      case ClientRequest.Weather_Set_Lightning:
        final index = int.tryParse(arguments[1]);
        if (index == null || !isValidIndex(index, lightningValues))
          return errorInvalidArg('invalid lightning index: $index');
        player.game.lightning = lightningValues[index];
        break;

      case ClientRequest.Weather_Toggle_Time_Passing:
        game.toggleTimePassing();
        break;

      case ClientRequest.Equip_Weapon:
        if (player.deadOrBusy) return;
        final index = int.tryParse(arguments[1]);
        if (index == null || index < 0 || index >= player.weapons.length) {
          return errorInvalidArg('invalid weapon index $index');
        }
        player.equippedWeapon = player.weapons[index];
        player.setStateChanging();
        player.writeEquippedWeapon();
        break;

      case ClientRequest.Revive:
        if (player.alive) {
          error(GameError.PlayerStillAlive);
          return;
        }
        player.game.revive(player);
        return;

      case ClientRequest.Set_Block:

        if (game is GameDarkAge) {
          if (game.owner != _player) return;
        } else {
          return;
        }

        if (arguments.length < 5) return errorArgsExpected(3, arguments);
        final row = int.tryParse(arguments[1]);
        if (row == null){
          return errorInvalidArg('row');
        }
        final column = int.tryParse(arguments[2]);
        if (column == null){
          return errorInvalidArg('column');
        }
        final z = int.tryParse(arguments[3]);
        if (z == null){
          return errorInvalidArg('z');
        }
        final type = int.tryParse(arguments[4]);
        if (type == GridNodeType.Boundary) {
          throw Exception("Cannot set grid block boundary");
        }
        if (type == null){
          return errorInvalidArg('type');
        }
        player.setBlock(z, row, column, type);

        if (type == GridNodeType.Tree_Bottom){
          player.setBlock(z + 1, row, column, GridNodeType.Tree_Top);
        }

        break;

      case ClientRequest.Deck_Select_Card:
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

      case ClientRequest.Upgrade:
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
        player.writeTechTypes();
        break;

      case ClientRequest.Attack:
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
        // player.equippedWeapon = techType;
        // player.setStateChanging();
        return;

      case ClientRequest.Toggle_Debug:
        player.toggleDebug();
        break;

      case ClientRequest.Version:
        reply('${ServerResponse.Version} $version');
        break;

      case ClientRequest.Speak:
        player.text = arguments
            .sublist(1, arguments.length)
            .fold("", (previousValue, element) => '$previousValue $element');
        player.textDuration = 150;
        break;

      case ClientRequest.Custom_Game_Names:
          getSaveDirectoryFileNames().then((fileNames){
              player.writeByte(ServerResponse.Custom_Game_Names);
              player.writeInt(fileNames.length);
              for (final fileName in fileNames) {
                 player.writeString(fileName);
              }
          });
          break;

      case ClientRequest.Editor_Load_Game:
          joinGameEditor(name: arguments[1]);
          break;

      case ClientRequest.Time_Set_Hour:
          final hour = int.tryParse(arguments[1]);
          if (hour == null) return errorInvalidArg('hour required');
          player.game.setHourMinutes(hour, 0);
          break;

      case ClientRequest.Editor_Set_Scene_Name:
          if (!player.ownsGame) {
             throw Exception("Player must be owner to set name");
          }
          var name = "";
          for (var i = 1; i < arguments.length; i++){
             name += arguments[i];
          }
          final scene = player.game.scene;
          scene.name = name;
          writeSceneToFile(scene);
          player.writeSceneMetaData();
          break;

      default:
        break;
    }
  }

  void handleClientRequestUpdate(List<int> args) {
    final player = _player;

    if (player == null) {
      return;
    }
    if (player.lastUpdateFrame == 0){
      return;
    }
    player.lastUpdateFrame = 0;

    final game = player.game;

    if (player.sceneChanged) {
      player.sceneChanged = false;
      player.sceneDownloaded = false;
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

    player.aimTarget = game.getClosestCollider(mouseX, mouseY, player, minDistance: 35);
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

        if (aimTarget is Npc){
          if (withinRadius(player, aimTarget, 100)){
            if (!aimTarget.deadOrBusy){
              aimTarget.face(player);
            }
            player.face(aimTarget);
            aimTarget.onInteractedWith?.call(player);
            break;
          }
          player.runToMouse();
          player.closeStore();
        } else {
          player.closeStore();
        }

        if (ability == null) {
          if (aimTarget != null) {
            player.target = aimTarget;
            if (withinRadius(player, aimTarget, player.equippedRange)){
              player.face(aimTarget);
              game.setCharacterStatePerforming(player);
            }
          } else {
            player.runToMouse();
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
              player.runToMouse();
              return;
            }
          case AbilityMode.Activated:
            ability.cooldownRemaining = ability.cooldown;
            break;
          case AbilityMode.Area:
            player.target = Position3().set(x: mouseX, y: mouseY, z: player.z);
            break;
          case AbilityMode.Directed:
            ability.cooldownRemaining = ability.cooldown;
            player.face(player.mouse);
            game.setCharacterState(player, CharacterState.Performing);
            break;
        }

        break;
      case CharacterAction.Run:
        player.direction = args[6];
        game.setCharacterStateRunning(player);
        player.target = null;
        player.closeStore();
        break;
    }

    return;
  }

  void onGameJoined(){
    final player = _player;
    if (player == null) throw Exception("onGameJoinedException: player is null");
    player.sendBufferToClient = sendBufferToClient;
    player.dispatchError = error;
    final account = _account;
    final game = player.game;
    if (account != null) {
      player.name = account.publicName;
    } else {
      while (true) {
        final randomName = generateRandomName();
        if (game.containsPlayerWithName(randomName)) continue;
        player.name = randomName;
        break;
      }
    }
    game.onPlayerJoined(player);
    player.writeGameStatus();
  }

  Future joinGameDarkAge() async {
    joinGame(engine.findGameDarkAgeVillage());
  }

  Future joinGameEditor({String? name}) async {
    final game = name == null
        ? await engine.findGameEditorNew()
        : await engine.findGameEditorByName(name);
    joinGame(game);
    game.owner = _player;
  }

  void joinGame(Game game){
    final current = _player;
    if (current != null) {
      current.game.removePlayer(current);
    }
    _player = game.spawnPlayer();
    onGameJoined();
  }

  void errorInvalidArg(String message) {
    reply('${ServerResponse.Error} ${GameError.InvalidArguments.index} $message');
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

  void handleClientRequestJoin(List<String> arguments,) {
    if (arguments.length < 2) return errorInsufficientArgs(2, arguments);

    final gameTypeIndex = int.tryParse(arguments[1]);

    if (!isValidIndex(gameTypeIndex, gameTypes)) return errorInvalidArg('invalid game type index $gameTypeIndex');

    final gameType = gameTypes[gameTypeIndex!];

    switch (gameType) {
      case GameType.Editor:
        joinGameEditor();
        break;
      case GameType.Dark_Age:
        joinGameDarkAge();
        break;
      default:
        throw Exception("Invalid Game Type: $gameType");
    }

  }

  void handleClientRequestTeleport(Player player) {
    player.x = player.mouse.x;
    player.y = player.mouse.y;
  }
}
