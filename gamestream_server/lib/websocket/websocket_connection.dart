import 'dart:async';
import 'dart:typed_data';

import 'package:gamestream_server/common/src.dart';
import 'package:gamestream_server/games/mmo/mmo_request_handler.dart';
import 'package:gamestream_server/games/src.dart';
import 'package:gamestream_server/isometric/isometric_scene_reader.dart';
import 'package:gamestream_server/isometric/src.dart';
import 'package:gamestream_server/gamestream.dart';
import 'package:gamestream_server/core/src.dart';
import 'package:gamestream_server/utils/src.dart';
import 'package:gamestream_server/websocket/src.dart';

import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_byte/byte_writer.dart';
import 'package:lemon_math/src.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class WebSocketConnection with ByteReader {
  final Gamestream engine;
  final started = DateTime.now();
  late WebSocketChannel webSocket;
  late WebSocketSink sink;
  late StreamSubscription subscription;
  Player? _player;
  final errorWriter = ByteWriter();

  Function? onDone;

  Player? get player => _player;

  WebSocketConnection(this.webSocket, this.engine){
    sink = webSocket.sink;

    sink.done.then((value){
      final player = _player;
      if (player != null) {
        player.game.players.remove(player);
        player.game.removePlayer(player);
      }
      _player = null;
      onDone?.call();
      subscription.cancel();
    });

    subscription = webSocket.stream.listen(onData, onError: onStreamError);
  }

  void onStreamError(Object error, StackTrace stackTrace){
    print("onStreamError()");
    print(error);
    print(stackTrace);
  }

  void sendBufferToClient(){
    final player = _player;
    if (player == null) return;
    sink.add(player.compile());
  }

  void sendGameError(GameError error) {
    errorWriter.writeByte(ServerResponse.Game_Error);
    errorWriter.writeByte(error.index);
    final compiled = errorWriter.compile();
    sink.add(compiled);
  }

  void onData(dynamic args) {
    if (args is Uint8List) {
      if (args.isEmpty) return;
      index = 0;
      values = args;
      switch (readByte()) {
        case ClientRequest.Update:
          handleClientRequestUpdate(args);
          return;
        default:
          break;
      }
    }
    if (args is String) {
      return onDataStringArray(args.split(" "));
    }
    throw Exception("Invalid arg type");
  }

  void onDataStringArray(List<String> arguments) {
    if (arguments.isEmpty) {
      sendGameError(GameError.ClientRequestArgumentsEmpty);
      return;
    }

    final clientRequestInt = parse(arguments[0]);

    if (clientRequestInt == null)
      return sendGameError(GameError.ClientRequestRequired);

    if (clientRequestInt < 0)
      return sendGameError(GameError.UnrecognizedClientRequest);

    final clientRequest = clientRequestInt;

    if (clientRequest == ClientRequest.Join)
      return handleClientRequestJoin(arguments);

    final player = _player;

    if (player == null)
      return errorPlayerNotFound();

    final game = player.game;

    switch (clientRequest) {

      case ClientRequest.Survival:
        if (player is! SurvivalPlayer) {
          errorInvalidPlayerType();
          return;
        }
        handleClientRequestSurvival(player, arguments);
        break;

      case ClientRequest.Combat:
        handleClientRequestCombat(player, arguments);
        break;

      case ClientRequest.Isometric_Editor:
        if (game is! IsometricGame)
          return errorInvalidPlayerType();

        final isometricEditorRequestIndex = parseArg1(arguments);

        if (isometricEditorRequestIndex == null) return;

        if (!isValidIndex(isometricEditorRequestIndex, IsometricEditorRequest.values)) {
          return errorInvalidClientRequest();
        }

        final isometricEditorRequest = IsometricEditorRequest.values[
          isometricEditorRequestIndex
        ];

        switch (isometricEditorRequest){
          case IsometricEditorRequest.GameObject:
            handleIsometricEditorRequestGameObject(arguments);
            break;
          case IsometricEditorRequest.Set_Node:
            handleIsometricEditorRequestSetNode(arguments);
            break;
          case IsometricEditorRequest.Load_Scene:
            try {
              final args = arguments.map(int.parse).toList(growable: false);
              final scene = SceneReader.readScene(
                Uint8List.fromList(args.sublist(2, args.length)),
              );
              joinGameEditorScene(scene);
            } catch (err) {
              sendGameError(GameError.Load_Scene_Failed);
            }
            return;
          case IsometricEditorRequest.Toggle_Game_Running:
            if (!isLocalMachine && game is! IsometricEditor) return;
            game.running = !game.running;
            break;

          case IsometricEditorRequest.Scene_Reset:
            if (!isLocalMachine && game is! IsometricEditor) return;
            game.reset();
            break;

          case IsometricEditorRequest.Generate_Scene:
            const min = 5;
            final rows = parseArg2(arguments);
            if (rows == null) return;
            if (rows < min) errorInvalidClientRequest();
            final columns = parseArg3(arguments);
            if (columns == null) return;
            if (columns < min) errorInvalidClientRequest();
            final height = parseArg4(arguments);
            if (height == null) return;
            if (height < min) errorInvalidClientRequest();
            final altitude = parseArg5(arguments);
            if (altitude == null) return;
            final frequency = parseArg6(arguments);
            if (frequency == null) return;
            final sceneName = game.scene.name;
            final scene = IsometricSceneGenerator.generate(
              height: height,
              rows: rows,
              columns: columns,
              altitude: altitude,
              frequency: frequency * 0.005,
            );
            scene.name = sceneName;
            game.scene = scene;
            game.playersDownloadScene();
            if (player is! IsometricPlayer) return;
            player.z = Node_Height * altitude + 24;
            break;

          case IsometricEditorRequest.Download:
            if (player is! IsometricPlayer) return;
            final compiled = IsometricSceneWriter.compileScene(player.scene, gameObjects: true);
            player.writeByte(ServerResponse.Download_Scene);

            if (player.scene.name.isEmpty){
              player.scene.name = generateRandomName();
            }

            player.writeString(player.scene.name);
            player.writeUInt16(compiled.length);
            player.writeBytes(compiled);
            break;

          case IsometricEditorRequest.Scene_Set_Floor_Type:
            final nodeType = parseArg2(arguments);
            if (nodeType == null) return;
            for (var i = 0; i < game.scene.area; i++){
              game.scene.types[i] = nodeType;
            }
            game.playersDownloadScene();
            break;
          case IsometricEditorRequest.Clear_Spawned:
            game.clearSpawnedAI();
            break;
          case IsometricEditorRequest.Scene_Toggle_Underground:
            break;
          case IsometricEditorRequest.Spawn_AI:
            game.clearSpawnedAI();
            game.scene.refreshSpawnPoints();
            game.triggerSpawnPoints();
            break;

          case IsometricEditorRequest.Save:
            if (game.scene.name.isEmpty){
              player.writeGameError(GameError.Save_Scene_Failed);
              return;
            }
            engine.isometricScenes.saveSceneToFile(game.scene);
            break;

          case IsometricEditorRequest.Modify_Canvas_Size:
            if (arguments.length < 3) {
              return errorInvalidClientRequest();
            }
            final modifyCanvasSizeIndex = parse(arguments[2]);
            if (modifyCanvasSizeIndex == null) return;
            if (!isValidIndex(modifyCanvasSizeIndex, RequestModifyCanvasSize.values)){
              return errorInvalidClientRequest();
            }
            final request = RequestModifyCanvasSize.values[modifyCanvasSizeIndex];
            if (player is! IsometricPlayer) return;
            handleRequestModifyCanvasSize(request, player);
            return;
        }
        break;

      case ClientRequest.Isometric:
        handleIsometricRequest(arguments);
        break;

      case ClientRequest.Capture_The_Flag:
        handleClientRequestCaptureTheFlag(arguments);
        break;

      case ClientRequest.MMO:
        handleClientRequestMMORequest(arguments);
        break;

      case ClientRequest.Fight2D:
        if (player is! GameFight2DPlayer) {
          errorInvalidPlayerType();
          return;
        }
        if (arguments.length < 2){
          errorInvalidClientRequest();
          return;
        }
        final gameFight2DClientRequest = parseArg1(arguments);
        if (gameFight2DClientRequest == null){
          errorInvalidClientRequest();
          return;
        }
        handleClientRequestFight2D(player, gameFight2DClientRequest, arguments);
        break;

      default:
        break;
    }
  }

  bool insufficientArgs1(List args) => insufficientArgs(args, 1);
  bool insufficientArgs2(List args) => insufficientArgs(args, 2);
  bool insufficientArgs3(List args) => insufficientArgs(args, 3);
  bool insufficientArgs4(List args) => insufficientArgs(args, 4);
  bool insufficientArgs5(List args) => insufficientArgs(args, 5);


  bool insufficientArgs(List args, int min){
     if (args.length < min) {
       // _player?.writeGameError(GameError.Invalid_Client_Request_Insufficient_Arguments);
       sendGameError(GameError.Invalid_Client_Request);
       return true;
     }
     return false;
  }

  void handleClientRequestFight2D(GameFight2DPlayer player, int gameFightClientRequest, List<String> arguments){
    switch (gameFightClientRequest) {
      case GameFight2DClientRequest.Toggle_Player_Edit:
        player.edit = !player.edit;
        break;
    }
  }

  void handleClientRequestSurvival(SurvivalPlayer player, List<String> arguments){
    final survivalRequestIndex = parseArg2(arguments);

    if (survivalRequestIndex == null)
      return;

    if (!isValidIndex(survivalRequestIndex, SurvivalRequest.values)){
       errorInvalidClientRequest();
       return;
    }

    final survivalRequest = SurvivalRequest.values[survivalRequestIndex];

    switch (survivalRequest) {

      case SurvivalRequest.Deposit:
        final index = parse(arguments[2]);
        if (index == null) return;
        player.inventoryDeposit(index);
        break;
      case SurvivalRequest.Unequip:
        final index = parse(arguments[2]);
        if (index == null) return;
        player.inventoryUnequip(index);
        break;
      case SurvivalRequest.Buy:
        if (insufficientArgs(arguments, 3)) return;
        final index = parse(arguments[2]);
        if (index == null) return;
        player.inventoryBuy(index);
        break;
      case SurvivalRequest.Sell:
        final index = parse(arguments[2]);
        if (index == null) return;
        player.inventorySell(index);
        break;
      case SurvivalRequest.Toggle:
        player.inventoryOpen = !player.inventoryOpen;
        if (player.inventoryOpen){
          player.interactMode = InteractMode.Inventory;
        } else {
          player.interactMode = InteractMode.None;
        }
        break;
      case SurvivalRequest.Drop:
        final index = parse(arguments[2]);
        if (index == null) return;
        // if (!player.isValidInventoryIndex(index)){
        //   player.writeErrorInvalidInventoryIndex(index);
        //   return;
        // }
        player.inventoryDrop(index);
        break;
      case SurvivalRequest.Move:
        if (insufficientArgs(arguments, 4)) return;
        final indexFrom = parse(arguments[2]);
        final indexTo = parse(arguments[3]);
        if (indexFrom == null) return errorInvalidClientRequest();
        if (indexTo == null) return errorInvalidClientRequest();
        if (indexFrom < 0) return errorInvalidClientRequest();
        if (indexTo < 0) return errorInvalidClientRequest();
        player.inventorySwapIndexes(indexFrom, indexTo);
        break;
      case SurvivalRequest.Equip:
        final index = parse(arguments[2]);
        if (index == null) return;
        if (index == player.equippedWeaponIndex){
          player.unequipWeapon();
          break;
        }
        player.inventoryEquip(index);
        break;
      default:
        sendGameError(GameError.Invalid_Inventory_Request_Index);
        return;
    }
  }

  void handleIsometricEditorRequestSetNode(List<String> arguments) {
    final player = _player;
    if (player == null) return;
    final game = player.game;
    if (game is! IsometricGame) return;
    if (!isLocalMachine && game is IsometricEditor == false) return;

    var nodeIndex = parseArg2(arguments);
    var nodeType = parseArg3(arguments);
    var nodeOrientation = parseArg4(arguments);

    if (nodeIndex == null) {
      return;
    }
    if (nodeType == null) {
      return;
    }
    if (nodeOrientation == null) {
      return;
    }
    if (!NodeType.supportsOrientation(nodeType, nodeOrientation)){
      nodeOrientation = NodeType.getDefaultOrientation(nodeType);
    }

    game.setNode(
        nodeIndex: nodeIndex,
        nodeType: nodeType,
        nodeOrientation: nodeOrientation,
    );
    if (nodeType == NodeType.Tree_Bottom){
      final topIndex = nodeIndex + game.scene.area;
      if (topIndex < game.scene.volume){
        game.setNode(
          nodeIndex: nodeIndex + game.scene.area,
          nodeType: NodeType.Tree_Top,
          nodeOrientation: nodeOrientation,
        );
      }
    }
  }

  void handleIsometricEditorRequestGameObject(List<String> arguments) {
    final player = _player;
    if (player == null) return;
    if (!isLocalMachine && player.game is! IsometricEditor) return;

    final gameObjectRequestIndex = parseArg2(arguments);

    if (gameObjectRequestIndex == null)
      return errorInvalidClientRequest();

    if (!isValidIndex(gameObjectRequestIndex, gameObjectRequests))
      return errorInvalidClientRequest();

    final gameObjectRequest = gameObjectRequests[gameObjectRequestIndex];
    if (player is! IsometricPlayer) return;
    final selectedGameObject = player.editorSelectedGameObject;

    switch (gameObjectRequest) {


      case IsometricEditorGameObjectRequest.Select:
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
        if (distance < 100){
          player.editorSelectedGameObject = closest;
        } else {
          player.game.playerDeselectEditorSelectedGameObject(player);
        }
        break;

      case IsometricEditorGameObjectRequest.Deselect:
        player.game.playerDeselectEditorSelectedGameObject(player);
        break;

      case IsometricEditorGameObjectRequest.Translate:
        final selectedGameObject = player.editorSelectedGameObject;
        if (selectedGameObject == null) return;
        final tx = double.tryParse(arguments[3]);
        final ty = double.tryParse(arguments[4]);
        final tz = double.tryParse(arguments[5]);
        if (tx == null) return;
        if (ty == null) return;
        if (tz == null) return;
        selectedGameObject.x += tx;
        selectedGameObject.y += ty;
        selectedGameObject.z += tz;
        selectedGameObject.saveStartAsCurrentPosition();
        break;

      case IsometricEditorGameObjectRequest.Add:
        final index = parseArg3(arguments);
        final type = parseArg4(arguments);
        if (index == null)
          return;
        if (type == null)
          return;
        if (index < 0)
          return errorInvalidClientRequest();

        final scene = player.game.scene;
        if (index >= scene.volume) {
          return errorInvalidClientRequest();
        }
        final instance = player.game.spawnGameObject(
          x: scene.getNodePositionX(index) + Node_Size_Half,
          y: scene.getNodePositionY(index) + Node_Size_Half,
          z: scene.getNodePositionZ(index),
          type: GameObjectType.Object,
          subType: type,
        );
        player.editorSelectedGameObject = instance;
        break;

      case IsometricEditorGameObjectRequest.Delete:
        player.game.playerDeleteEditorSelectedGameObject(player);
        break;

      case IsometricEditorGameObjectRequest.Move_To_Mouse:
        final selectedGameObject = player.editorSelectedGameObject;
        if (selectedGameObject == null) return;
        selectedGameObject.x = player.mouseGridX;
        selectedGameObject.y = player.mouseGridY;
        selectedGameObject.z = player.z;
        selectedGameObject.saveStartAsCurrentPosition();
        break;

      case IsometricEditorGameObjectRequest.Set_Type:
        // TODO: Handle this case.
        break;

      case IsometricEditorGameObjectRequest.Toggle_Strikable:
        if (selectedGameObject == null) return;
        selectedGameObject.hitable = !selectedGameObject.hitable;
        selectedGameObject.velocityZ = 0;
        player.writeEditorGameObjectSelected();
        break;

      case IsometricEditorGameObjectRequest.Toggle_Fixed:
        if (selectedGameObject == null) return;
        selectedGameObject.fixed = !selectedGameObject.fixed;
        player.writeEditorGameObjectSelected();
        break;

      case IsometricEditorGameObjectRequest.Toggle_Collectable:
        if (selectedGameObject == null) return;
        selectedGameObject.collectable = !selectedGameObject.collectable;
        player.writeEditorGameObjectSelected();
        break;

      case IsometricEditorGameObjectRequest.Toggle_Gravity:
        if (selectedGameObject == null) return;
        selectedGameObject.gravity = !selectedGameObject.gravity;
        player.writeEditorGameObjectSelected();
        break;

      case IsometricEditorGameObjectRequest.Duplicate:
        if (selectedGameObject == null) return;
        final duplicated = player.game.spawnGameObject(
            x: selectedGameObject.x,
            y: selectedGameObject.y,
            z: selectedGameObject.z,
            type: selectedGameObject.type,
            subType: selectedGameObject.subType,
        );
        player.editorSelectedGameObject = duplicated;
        break;

      case IsometricEditorGameObjectRequest.Toggle_Physical:
        if (selectedGameObject == null) return;
        selectedGameObject.physical = !selectedGameObject.physical;
        player.writeEditorGameObjectSelected();
        break;

      case IsometricEditorGameObjectRequest.Toggle_Persistable:
        if (selectedGameObject == null) return;
        selectedGameObject.persistable = !selectedGameObject.persistable;
        player.writeEditorGameObjectSelected();
        break;
    }
  }

  void handleClientRequestUpdate(Uint8List args) {
    final player = _player;

    if (player == null) return errorPlayerNotFound();


    final hex = readByte();

    final direction         = hex & 0xf;
    final mouseDownLeft     = hex & ByteHex.Hex_16 > 0;
    final mouseDownRight    = hex & ByteHex.Hex_32 > 0;
    final inputTypeDesktop  = hex & ByteHex.Hex_64 > 0;
    final keyDownSpace      = hex & ByteHex.Hex_128 > 0;

    player.framesSinceClientRequest = 0;

    player.mouse.x = readInt16().toDouble();
    player.mouse.y = readInt16().toDouble();
    player.screenLeft = readInt16().toDouble();
    player.screenTop = readInt16().toDouble();
    player.screenRight = readInt16().toDouble();
    player.screenBottom = readInt16().toDouble();

    player.inputMode = hex & ByteHex.Hex_64 > 0 ? 1 : 0;
    player.mouseLeftDown = mouseDownLeft;

    player.game.onPlayerUpdateRequestReceived(
      player: player,
      direction: direction,
      mouseLeftDown: mouseDownLeft,
      mouseRightDown: mouseDownRight,
      keySpaceDown: keyDownSpace,
      inputTypeKeyboard: inputTypeDesktop,
    );
  }

  Future joinGameEditorScene(IsometricScene scene) async {
    joinGame(IsometricEditor(scene: scene));
  }

  void joinGame(Game game){
    if (!engine.games.contains(game)){
       engine.games.add(game);
    }
    final player = game.createPlayer();
    game.players.add(player);
    _player = _player = player;
    player.writeGameType();
  }

  void errorInsufficientResources(){
    sendGameError(GameError.Insufficient_Resources);
  }

  void errorPlayerNotFound() {
    sendGameError(GameError.PlayerNotFound);
  }

  void errorAccountRequired() {
    sendGameError(GameError.Account_Required);
  }

  void errorPlayerDead() {
    sendGameError(GameError.PlayerDead);
  }

  void handleClientRequestJoin(List<String> arguments,) {
    if (arguments.length < 2) return errorInvalidClientRequest();
    final gameTypeIndex = parse(arguments[1]);
    if (gameTypeIndex == null || !isValidIndex(gameTypeIndex, GameType.values)){
      errorInvalidClientRequest();
      return;
    }
    final gameType = GameType.values[gameTypeIndex];
    _player = engine.joinGameByType(gameType);
  }

  void cancelSubscription() {
    subscription.cancel();
  }

  int? parseArg0(List<String> arguments,) => parseArg(arguments, 0);
  int? parseArg1(List<String> arguments,) => parseArg(arguments, 1);
  int? parseArg2(List<String> arguments,) => parseArg(arguments, 2);
  int? parseArg3(List<String> arguments,) => parseArg(arguments, 3);
  int? parseArg4(List<String> arguments,) => parseArg(arguments, 4);
  int? parseArg5(List<String> arguments,) => parseArg(arguments, 5);
  int? parseArg6(List<String> arguments,) => parseArg(arguments, 6);

  int? parseArg(List<String> arguments, int index){
     if (index >= arguments.length) {
       errorInvalidClientRequest();
       return null;
     }
     final value = int.tryParse(arguments[index]);
     if (value == null) {
       errorInvalidClientRequest();
     }
     return value;
  }

  int? parse(String source, {int? radix}) {
    final value = int.tryParse(source);
    if (value == null) {
        errorInvalidClientRequest();
       return null;
    }
    return value;
  }

  void errorInvalidClientRequest() {
    sendGameError(GameError.Invalid_Client_Request);
  }

  void errorInvalidPlayerType(){
   sendGameError(GameError.Invalid_Player_Type);
  }

  void handleIsometricRequest(List<String> arguments){
    final player = _player;

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

      case IsometricRequest.Debug_Character_Teleport_To_Mouse:
        final debugCharacter = player.selectedCollider;
        if (debugCharacter is! IsometricCharacter) return;
        final scene = player.game.scene;
        final index = scene.findEmptyIndex(player.mouseIndex);
        if (index == -1) return;

        debugCharacter.clearTarget();
        debugCharacter.clearPath();
        debugCharacter.x = scene.getNodePositionX(index);
        debugCharacter.y = scene.getNodePositionY(index);
        debugCharacter.z = scene.getNodePositionZ(index);
        debugCharacter.setDestinationToCurrentPosition();
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
    }
  }
}

// control_type
// - click
// - wasd

// character_behavior

// idle
// stand-ground
// defend-position
// aggressive
// wander
// wander-freely