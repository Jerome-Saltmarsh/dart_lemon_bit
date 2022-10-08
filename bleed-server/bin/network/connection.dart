import 'dart:typed_data';

import 'package:bleed_server/firestoreClient/firestoreService.dart';
import 'package:bleed_server/system.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../common/gameobject_request.dart';
import '../common/library.dart';
import '../common/maths.dart';
import '../common/spawn_type.dart';
import '../common/teleport_scenes.dart';
import '../dark_age/dark_age_scenes.dart';
import '../dark_age/game_dark_age.dart';
import '../dark_age/game_dark_age_editor.dart';
import '../engine.dart';
import '../functions/generateName.dart';
import '../functions/move_player_to_crystal.dart';
import '../game_types/game_skirmish.dart';
import '../game_types/game_waves.dart';
import '../io/convert_json_to_scene.dart';
import '../io/convert_scene_to_json.dart';
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
    reply('Server Error ${error.name}: $message');
  }

  void onData(dynamic args) {
    if (args is Uint8List) {
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

      case ClientRequest.Set_Weapon:
        if (arguments.length < 2)  return errorArgsExpected(2, arguments);
        final weaponType = int.tryParse(arguments[1]);
        if (weaponType == null) return errorInvalidArg('weapon type');
        player.weapon = Weapon(type: weaponType, damage: 1, duration: 10, range: 50);
        player.game.setCharacterStateChanging(player);
        break;

      case ClientRequest.Set_Armour:
        if (arguments.length < 2)  return errorArgsExpected(2, arguments);
        final armourType = int.tryParse(arguments[1]);
        if (armourType == null) return errorInvalidArg('armour type');
        player.equippedArmour = armourType;
        player.game.setCharacterStateChanging(player);
        break;

      case ClientRequest.Set_Head_Type:
        if (arguments.length < 2)  return errorArgsExpected(2, arguments);
        final type = int.tryParse(arguments[1]);
        if (type == null) return errorInvalidArg('invalid head type $type');
        player.equippedHead = type;
        player.game.setCharacterStateChanging(player);
        break;

      case ClientRequest.Set_Pants_Type:
        if (arguments.length < 2)  return errorArgsExpected(2, arguments);
        final type = int.tryParse(arguments[1]);
        if (type == null) return errorInvalidArg('invalid head type $type');
        player.equippedPants = type;
        player.game.setCharacterStateChanging(player);
        break;

      case ClientRequest.Purchase_Weapon:
        if (arguments.length < 2) return errorArgsExpected(2, arguments);
        final type = int.tryParse(arguments[1]);
        if (type == null) return errorInvalidArg('invalid weapon type $type');
        player.game.customOnPlayerRequestPurchaseWeapon(player, type);
        break;

      case ClientRequest.Store_Close:
        player.storeItems = [];
        player.writeStoreItems();
        break;

      case ClientRequest.Weather_Set_Rain:
        if (game is GameDarkAge == false) return;
        final universe = (game as GameDarkAge).environment;
        final rainIndex = int.tryParse(arguments[1]);
        if (rainIndex == null || !isValidIndex(rainIndex, rainValues))
           return errorInvalidArg('invalid rain index: $rainIndex');

        universe.raining = rainValues[rainIndex];
        break;

      case ClientRequest.Weather_Toggle_Breeze:
        if (game is GameDarkAge == false) return;
        final universe = (game as GameDarkAge).environment;
        universe.toggleBreeze();
        break;

      case ClientRequest.Weather_Set_Wind:
        if (game is GameDarkAge == false) return;
        final universe = (game as GameDarkAge).environment;
        final index = int.tryParse(arguments[1]);
        if (index == null || !isValidIndex(index, windValues))
          return errorInvalidArg('invalid rain index: $index');

        universe.wind = index;
        break;

      case ClientRequest.Weather_Set_Lightning:
        if (game is GameDarkAge == false) return;
        final universe = (game as GameDarkAge).environment;

        final index = int.tryParse(arguments[1]);
        if (index == null || !isValidIndex(index, lightningValues))
          return errorInvalidArg('invalid lightning index: $index');
        universe.lightning = lightningValues[index];
        break;

      case ClientRequest.Weather_Toggle_Time_Passing:
        if (game is GameDarkAge == false) return;
        final environment = (game as GameDarkAge).environment;

        if (arguments.length > 0){
           final val = arguments[1];
           environment.timePassing = val == 'true';
           return;
        }
        environment.toggleTimePassing();
        break;

      case ClientRequest.Equip_Weapon:
        if (player.deadOrBusy) return;
        final index = int.tryParse(arguments[1]);
        if (index == null || index < 0 || index >= player.weapons.length) {
          return errorInvalidArg('invalid weapon index $index');
        }
        player.weapon = player.weapons[index];
        player.game.setCharacterStateChanging(player);
        // player.writeEquippedWeapon();
        break;

      case ClientRequest.Revive:
        if (player.alive) {
          error(GameError.PlayerStillAlive);
          return;
        }
        player.game.revive(player);
        return;

      case ClientRequest.Editor_Set_Canvas_Size:
        /// TODO
        // game.scene.grid.add(generateGridZ(game.scene.gridRows, game.scene.gridColumns));
        game.onGridChanged();
        break;

      case ClientRequest.GameObject:
        return handleGameObjectRequest(arguments);

      case ClientRequest.Node:
        return handleNodeRequestSetBlock(arguments);

      case ClientRequest.Canvas_Modify_Size:
        return handleCanvasModifySize(arguments);

      case ClientRequest.Npc_Talk_Select_Option:
        return handleNpcTalkSelectOption(player, arguments);

      case ClientRequest.Toggle_Debug:
        player.toggleDebug();
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

      case ClientRequest.Save_Scene:
        final scene = convertSceneToString(player.scene);
        reply('scene: $scene');
        break;

      case ClientRequest.Spawn_Node_Data:
        if (arguments.length < 4){
          return errorInvalidArg('expected 4 args');
        }
        final z = int.tryParse(arguments[1]);
        final row = int.tryParse(arguments[2]);
        final column = int.tryParse(arguments[3]);

        if (z == null) return errorInvalidArg('z is null');
        if (row == null) return errorInvalidArg('row is null');
        if (column == null) return errorInvalidArg('column is null');
        /// TODO
        // final node = player.game.scene.getNode(z, row, column);
        //
        // if (node is NodeSpawn)
        //   return player.writeNodeData(node);
        // return errorInvalidArg('node.type is not spawn');
        break;

      case ClientRequest.Spawn_Node_Data_Modify:
        if (arguments.length < 6){
          return errorInvalidArg('expected 6 args');
        }
        final z = int.tryParse(arguments[1]);
        final row = int.tryParse(arguments[2]);
        final column = int.tryParse(arguments[3]);
        final spawnType = int.tryParse(arguments[4]);
        final spawnAmount = int.tryParse(arguments[5]);
        final spawnRadius = double.tryParse(arguments[6]);

        if (z == null) return errorInvalidArg('z is null');
        if (row == null) return errorInvalidArg('row is null');
        if (column == null) return errorInvalidArg('column is null');
        if (spawnType == null) return errorInvalidArg('spawnType is null');
        if (spawnAmount == null) return errorInvalidArg('spawnAmount is null');
        if (spawnRadius == null) return errorInvalidArg('spawnRadius is null');

        if (spawnAmount < 0)
          return errorInvalidArg('spawn amount must be greater than 0');
        if (spawnAmount > 100)
          return errorInvalidArg('spawn cannot be greater than 100');
        if (spawnRadius < 0)
          return errorInvalidArg('spawn radius must be greater than 0');

        if (!SpawnType.values.contains(spawnType))
          return errorInvalidArg('invalid spawn type: $spawnType');


        /// TODO

        // final node = player.scene.getNode(z, row, column);

        // if (node is NodeSpawn) {
        //   node.spawnType = spawnType;
        //   node.spawnAmount = spawnAmount;
        //   node.spawnRadius = spawnRadius;
        //   player.writeNodeData(node);
        //   game.nodeSpawnInstancesClear(node);
        //   game.nodeSpawnInstancesCreate(node);
        //   player.scene.dirty = true;
        // } else {
        //   return errorInvalidArg('ClientRequest.Spawn_Node_Data_Modify. Selected node must be of type spawn');
        // }
        break;

      case ClientRequest.Teleport_Scene:
        final sceneIndex = int.tryParse(arguments[1]);

        if (sceneIndex == null)
          return errorInvalidArg('scene index is null');

        if (!isValidIndex(sceneIndex, teleportScenes))
          return errorInvalidArg("invalid scene index $sceneIndex");

        final scene = teleportScenes[sceneIndex];

        switch (scene) {
          case TeleportScenes.Village:
            game.changeGame(player, engine.findGameDarkAgeFarm());
            movePlayerToCrystal(player);
            break;
          case TeleportScenes.Dungeon_1:
            game.changeGame(player, engine.findGameDarkAgeDungeon1());
            movePlayerToCrystal(player);
            break;
          default:
            break;
        }

        break;

      case ClientRequest.Editor_Load_Scene:
        if (arguments.length < 3) {
          errorInvalidArg('3 args expected');
        }

        final sceneString = arguments[2];
        try {
          final scene = convertStringToScene(sceneString, "editor");
          joinGameEditorScene(scene);
        } catch (error){
          errorInvalidArg('Failed to load scene');
        }
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
          if (game is GameDarkAgeEditor == false) {
             return errorInvalidArg('game type must be GameDarkAgeEditor');
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

      case ClientRequest.Game_Waves:
        if (game is GameWaves == false) return;
        final gameWaves = game as GameWaves;
        if (gameWaves.timer <= 1) return;
        gameWaves.timer = 1;
        break;

      default:
        break;
    }
  }

  void handleNodeRequestSetBlock(List<String> arguments) {
    final player = _player;
    if (player == null) return;
    if (!isLocalMachine && player.game is GameDarkAgeEditor == false) return;

    if (arguments.length < 4) return errorInvalidArg('4 args expected');

    var nodeIndex = int.tryParse(arguments[1]);
    var nodeType = int.tryParse(arguments[2]);
    var nodeOrientation = int.tryParse(arguments[3]);
    if (nodeIndex == null) {
      return errorInvalidArg('orientation is null');
    }
    if (nodeType == null) {
      return errorInvalidArg('nodeType is null');
    }
    if (nodeOrientation == null) {
      return errorInvalidArg('nodeOrientation is null');
    }
    if (!NodeType.supportsOrientation(nodeType, nodeOrientation)){
      nodeOrientation = NodeType.getDefaultOrientation(nodeType);
    }
    final game = player.game;
    game.setNode(
        nodeIndex: nodeIndex,
        nodeType: nodeType,
        nodeOrientation: nodeOrientation,
    );
  }

  void handleNpcTalkSelectOption(Player player, List<String> arguments) {
    if (player.deadOrDying) return errorPlayerDead();
    if (arguments.length != 2) return errorArgsExpected(2, arguments);
    final index = int.tryParse(arguments[1]);
    if (index == null) {
      return errorInvalidArg('int required: got ${arguments[1]}');
    }
    if (index < 0 || index >= player.options.length){
      return errorInvalidArg('invalid player option');
    }
    final action = player.options.values.toList()[index];
    action.call();
    return;
  }

  void handleCanvasModifySize(List<String> arguments) {
    final player = _player;
    if (player == null) return;

    if (arguments.length < 4)
      return errorInvalidArg('handleCanvasModifySize insufficient args');

    final dimension = int.tryParse(arguments[1]);
    final add = int.tryParse(arguments[1]);
    final start = int.tryParse(arguments[1]);

    if (dimension == null)
      return errorInvalidArg('handleCanvasModifySize dimension is null');

    if (add == null)
      return errorInvalidArg('handleCanvasModifySize add is null');

    if (start == null)
      return errorInvalidArg('handleCanvasModifySize start is null');

    switch (dimension){
      NodeAxis.Z:
        break;
    }
  }

  void handleGameObjectRequest(List<String> arguments) {
    final player = _player;
    if (player == null) return;

    if (arguments.length <= 1)
      return errorInvalidArg('handleGameObjectRequest invalid args');

    final gameObjectRequestIndex = int.tryParse(arguments[1]);

    if (gameObjectRequestIndex == null)
      return errorInvalidArg("gameObjectRequestIndex is null");

    if (!isValidIndex(gameObjectRequestIndex, gameObjectRequests))
      return errorInvalidArg("gameObjectRequestIndex ($gameObjectRequestIndex) is invalid");

    final gameObjectRequest = gameObjectRequests[gameObjectRequestIndex];

    switch (gameObjectRequest) {

      case GameObjectRequest.Select:
        final gameObjects = player.scene.gameObjects;
        if (gameObjects.isEmpty) return;
        final mouseX = player.mouse.x;
        final mouseY = player.mouse.y;
        var closest = gameObjects.first;
        var distance = getDistanceXY(mouseX, mouseY, closest.renderX, closest.renderY);

        for (final gameObject in gameObjects){
          var nextDistance = getDistanceXY(mouseX, mouseY, gameObject.renderX, gameObject.renderY);
          if (nextDistance >= distance) continue;
          closest = gameObject;
          distance = nextDistance;
        }
        player.editorSelectedGameObject = closest;
        break;

      case GameObjectRequest.Deselect:
        player.game.playerDeselectEditorSelectedGameObject(player);
        break;

      case GameObjectRequest.Translate:
        final selectedGameObject = player.editorSelectedGameObject;
        if (selectedGameObject == null) return;
        final tx = double.tryParse(arguments[2]);
        final ty = double.tryParse(arguments[3]);
        final tz = double.tryParse(arguments[4]);
        if (tx == null) return;
        if (ty == null) return;
        if (tz == null) return;
        selectedGameObject.x += tx;
        selectedGameObject.y += ty;
        selectedGameObject.z += tz;
        break;

      case GameObjectRequest.Add:
        final x = double.tryParse(arguments[2]);
        final y = double.tryParse(arguments[3]);
        final z = double.tryParse(arguments[4]);
        final type = int.tryParse(arguments[5]);
        if (x == null) return errorInvalidArg('x is null (2)');
        if (y == null) return errorInvalidArg('y is null (3)');
        if (z == null) return errorInvalidArg('z is null (4)');
        if (type == null) return errorInvalidArg('type is null (5)');

        player.game.scene.gameObjects.add(
          GameObject(x: x, y: y, z: z, type: type)
        );

        player.editorSelectedGameObject = player.game.scene.gameObjects.last;
        player.scene.dirty = true;
        break;

      case GameObjectRequest.Delete:
        player.game.playerDeleteEditorSelectedGameObject(player);
        break;

      case GameObjectRequest.Move_To_Mouse:
        final selectedGameObject = player.editorSelectedGameObject;
        if (selectedGameObject == null) return;
        selectedGameObject.x = player.mouseGridX;
        selectedGameObject.y = player.mouseGridY;
        selectedGameObject.z = player.z;
        break;
    }
  }

  void handleClientRequestUpdate(Uint8List args) {
    final player = _player;

    if (player == null) return errorPlayerNotFound();

    player.game.onPlayerUpdateRequestedReceived(
      player: player,
      direction: args[1],
      perform1: args[2] == 1,
      perform2: args[3] == 1,
      perform3: args[4] == 1,
      mouseX: readNumberFromByteArray(args, index: 5).toDouble(),
      mouseY: readNumberFromByteArray(args, index: 7).toDouble(),
      screenLeft: readNumberFromByteArray(args, index: 9).toDouble(),
      screenTop: readNumberFromByteArray(args, index: 11).toDouble(),
      screenRight: readNumberFromByteArray(args, index: 13).toDouble(),
      screenBottom: readNumberFromByteArray(args, index: 15).toDouble(),
    );
  }

  Future joinGameDarkAge() async {
    joinGame(engine.findGameDarkAgeFarm());
  }

  Future joinGameEditor({String? name}) async {
    final game = name == null
        ? await engine.findGameEditorNew()
        : await engine.findGameEditorByName(name);
    joinGame(game);
  }

  Future joinGameEditorScene(Scene scene) async {
    joinGame(GameDarkAgeEditor(scene: scene));
  }

  Future joinGameWaves() async {
    joinGame(GameWaves(scene: darkAgeScenes.dungeon_1));
  }

  Future joinGameSkirmish() async {
    for (final game in engine.games){
       if (game is GameSkirmish){
          if (game.players.length < game.configMaxPlayers)
            return joinGame(game);
       }
    }
    joinGame(GameSkirmish(scene: darkAgeScenes.skirmish_1));
  }

  void joinGame(Game game){
    if (_player != null) {
      _player!.game.removePlayer(_player!);
    }
    final player = game.spawnPlayer();
    _player = _player = player;
    player.sendBufferToClient = sendBufferToClient;
    player.sceneDownloaded = false;

    final account = _account;
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

  void errorInvalidArg(String message) {
    error(GameError.InvalidArguments, message: message);
  }

  void errorPlayerNotFound() {
    error(GameError.PlayerNotFound);
  }

  void errorAccountRequired() {
    error(GameError.Account_Required);
  }

  void errorPlayerDead() {
    error(GameError.PlayerDead);
  }

  void handleClientRequestJoin(List<String> arguments,) {
    if (arguments.length < 2) return errorInsufficientArgs(2, arguments);
    final gameType = int.tryParse(arguments[1]);
    switch (gameType) {
      case GameType.Editor:
        joinGameEditor();
        break;
      case GameType.Dark_Age:
        joinGameDarkAge();
        break;
      case GameType.Waves:
        joinGameWaves();
        break;
      case GameType.Skirmish:
        joinGameSkirmish();
        break;
      default:
        return errorInvalidArg('invalid game type index $gameType');
    }
  }

  void handleClientRequestTeleport(Player player) {
    player.x = player.mouseGridX;
    player.y = player.mouseGridY;
    player.health = player.maxHealth;
    player.state = CharacterState.Idle;
  }
}
