import 'dart:async';
import 'dart:typed_data';

import 'package:gamestream_server/amulet.dart';
import 'package:gamestream_server/editor/isometric_editor.dart';
import 'package:gamestream_server/gamestream/functions/write_json_to_amulet_player.dart';
import 'package:gamestream_server/gamestream/src.dart';
import 'package:gamestream_server/isometric/isometric_request_reader.dart';
import 'package:gamestream_server/isometric/scene_reader.dart';
import 'package:gamestream_server/isometric/src.dart';
import 'package:gamestream_server/packages.dart';

import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_byte/byte_writer.dart';

import 'package:web_socket_channel/web_socket_channel.dart';


class Connection with ByteReader {

  final GamestreamServer server;
  final errorWriter = ByteWriter();
  final started = DateTime.now();

  late WebSocketChannel webSocket;
  late WebSocketSink sink;
  late StreamSubscription subscription;

  Player? _player;
  Function? onDone;

  int? arg0;
  int? arg1;
  int? arg2;
  int? arg3;
  int? arg4;

  Player? get player => _player;

  Connection(this.webSocket, this.server){
    sink = webSocket.sink;

    sink.done.then((value){
      final player = _player;
      if (player != null) {

        if (player is IsometricPlayer && player.persistOnDisconnect){
          server.userService.saveIsometricPlayer(player);
        }

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
    errorWriter.writeByte(NetworkResponse.Game_Error);
    errorWriter.writeByte(error.index);
    final compiled = errorWriter.compile();
    sink.add(compiled);
  }

  void onData(dynamic args) {
    if (args is Uint8List) {
      if (args.isEmpty) return;
      index = 0;
      values = args;
      handleClientRequestUpdate(args, debug: false);
      return;
    }
    if (args is String) {
      try {
        return onDataStringArray(args.split(" "));
      } catch(error){
        player?.handleRequestException(error);
      }
      return;
    }
    throw Exception("Invalid arg type");
  }

  void onDataStringArray(List<String> arguments) {
    if (arguments.isEmpty) {
      sendGameError(GameError.ClientRequestArgumentsEmpty);
      return;
    }

    arg0 = parseArg(arguments, 0, error: false);
    arg1 = parseArg(arguments, 1, error: false);
    arg2 = parseArg(arguments, 2, error: false);
    arg3 = parseArg(arguments, 3, error: false);
    arg4 = parseArg(arguments, 4, error: false);

    final clientRequestInt = parse(arguments[0]);

    if (clientRequestInt == null)
      return sendGameError(GameError.ClientRequestRequired);

    if (clientRequestInt < 0)
      return sendGameError(GameError.UnrecognizedClientRequest);

    final clientRequest = clientRequestInt;

    if (clientRequest == NetworkRequest.Join)
      return handleClientRequestJoin(arguments);

    final player = _player;

    if (player == null)
      return errorPlayerNotFound();

    final game = player.game;

    switch (clientRequest) {

      case NetworkRequest.Editor_Request:

        if (player is! IsometricPlayer){
          return;
        }

        if (game is! IsometricGame)
          return errorInvalidPlayerType();

        final isometricEditorRequestIndex = parseArg1(arguments);

        if (isometricEditorRequestIndex == null) return;

        if (!isValidIndex(isometricEditorRequestIndex, EditorRequest.values)) {
          return errorInvalidClientRequest();
        }

        final isometricEditorRequest = EditorRequest.values[
          isometricEditorRequestIndex
        ];


        final editor = player.editor;

        switch (isometricEditorRequest){
          case EditorRequest.GameObject:
            handleIsometricEditorRequestGameObject(arguments);
            break;
          case EditorRequest.Set_Node:
            handleIsometricEditorRequestSetNode(arguments);
            break;
          case EditorRequest.Load_Scene:
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
          case EditorRequest.Toggle_Game_Running:
            if (!isLocalMachine && game is! IsometricEditor) return;
            game.running = !game.running;
            break;

          case EditorRequest.Scene_Reset:
            if (!isLocalMachine && game is! IsometricEditor) return;
            game.reset();
            break;

          case EditorRequest.Mark_Select:
            if (!isLocalMachine && game is! IsometricEditor)
              return;

            final index = parseArg2(arguments);
            if (index == null)
              return;

            editor.selectedMarkListIndex = index;
            break;

          case EditorRequest.Mark_Add:
            final markIndex = parseArg2(arguments);
            if (markIndex == null)
              return;

            editor.addMark(markIndex);
            break;

          case EditorRequest.Mark_Delete:
            editor.deleteMark();
            break;

          case EditorRequest.Mark_Set_Type:
            final markType = parseArg2(arguments);
            if (markType == null)
              return;

            player.editor.setSelectedMarkType(markType);
            break;

          case EditorRequest.Generate_Scene:
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
            final scene = SceneGenerator.generate(
              height: height,
              rows: rows,
              columns: columns,
              altitude: altitude,
              frequency: frequency * 0.005,
            );
            scene.name = sceneName;
            game.scene = scene;
            game.playersDownloadScene();
            player.z = Node_Height * altitude + 24;
            break;

          case EditorRequest.Download:
            final compiled = SceneWriter.compileScene(player.scene, gameObjects: true);
            player.writeByte(NetworkResponse.Scene);
            player.writeByte(NetworkResponseScene.Download_Scene);

            if (player.scene.name.isEmpty){
              player.scene.name = generateRandomName();
            }

            player.writeString(player.scene.name);
            player.writeUInt16(compiled.length);
            player.writeBytes(compiled);
            break;

          case EditorRequest.Scene_Set_Floor_Type:
            final nodeType = parseArg2(arguments);
            if (nodeType == null) return;
            for (var i = 0; i < game.scene.area; i++){
              game.scene.types[i] = nodeType;
            }
            game.playersDownloadScene();
            break;
          case EditorRequest.Clear_Spawned:
            game.clearSpawnedAI();
            break;
          case EditorRequest.Spawn_AI:
            game.clearSpawnedAI();
            break;

          case EditorRequest.Save:
            if (game.scene.name.isEmpty){
              player.writeGameError(GameError.Save_Scene_Failed);
              return;
            }
            server.isometricScenes.saveSceneToFile(game.scene);
            break;

          case EditorRequest.Modify_Canvas_Size:
            if (arguments.length < 3) {
              return errorInvalidClientRequest();
            }
            final modifyCanvasSizeIndex = parse(arguments[2]);
            if (modifyCanvasSizeIndex == null) return;
            if (!isValidIndex(modifyCanvasSizeIndex, NetworkRequestModifyCanvasSize.values)){
              return errorInvalidClientRequest();
            }
            final request = NetworkRequestModifyCanvasSize.values[modifyCanvasSizeIndex];
            handleRequestModifyCanvasSize(request, player);
            return;
        }
        break;

      case NetworkRequest.Isometric:
        readIsometricRequest(arguments);
        break;

      case NetworkRequest.Scene:
        readSceneRequest(arguments);
        break;

      case NetworkRequest.Amulet:
        handleNetworkRequestAmulet(arguments);
        break;

      case NetworkRequest.Debug:
        handleNetworkRequestDebug();
        break;

      case NetworkRequest.Player:
        handlePlayerRequest(arguments);
        break;

      case NetworkRequest.Inventory_Request:
        if (player is! AmuletPlayer)
          return;

        handleInventoryRequest(player, arguments.map(int.parse).toList(growable: false));
        break;

      case NetworkRequest.Set_FPS:
        final value = parseArg1(arguments);
        if (value == null) return;
        break;

      case NetworkRequest.Environment_Request:
        readEnvironmentRequest(arguments);
        break;

      default:
        player.writeGameError(GameError.Invalid_Client_Request);
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
        final mouseX = player.mouseX;
        final mouseY = player.mouseY;
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
          x: scene.getIndexX(index) + Node_Size_Half,
          y: scene.getIndexY(index) + Node_Size_Half,
          z: scene.getIndexZ(index),
          type: ItemType.Object,
          subType: type,
          team: 0, // TODO
        );
        player.editorSelectedGameObject = instance;
        break;

      case IsometricEditorGameObjectRequest.Delete:
        player.game.playerDeleteEditorSelectedGameObject(player);
        break;

      case IsometricEditorGameObjectRequest.Move_To_Mouse:
        final selectedGameObject = player.editorSelectedGameObject;
        if (selectedGameObject == null) return;
        selectedGameObject.x = player.mouseSceneX;
        selectedGameObject.y = player.mouseSceneY;
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
            team: selectedGameObject.team,
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

  void handleClientRequestUpdate(Uint8List args, {required bool debug}) {
    final player = _player;

    if (player == null) return errorPlayerNotFound();

    player.framesSinceClientRequest = 0;

    final hex = readByte();
    final direction         = hex & 0xf;
    final mouseDownLeft     = hex & ByteHex.Hex_16 > 0;
    final mouseDownRight    = hex & ByteHex.Hex_32 > 0;
    final keyDownShift      = hex & ByteHex.Hex_64 > 0;
    final keyDownSpace      = hex & ByteHex.Hex_128 > 0;
    player.inputMode = hex & ByteHex.Hex_64 > 0 ? 1 : 0;
    player.mouseLeftDown = mouseDownLeft;

    final compress1 = readByte();
    final compress2 = readByte();

    final changeMouseWorldX = compress1 & Hex00000011;
    final changeMouseWorldY = (compress1 & Hex00001100) >> 2;
    final changeScreenLeft = compress2 & Hex00000011;
    final changeScreenTop = (compress2 & Hex00001100) >> 2;
    final changeScreenRight = (compress2 & Hex00110000) >> 4;
    final changeScreenBottom = (compress2 & Hex11000000) >> 6;

    if (changeMouseWorldX == ChangeType.One) {
      player.mouseX++;
    } else if (changeMouseWorldX == ChangeType.Delta){
      player.mouseX += readInt8();
    } else if (changeMouseWorldX == ChangeType.Absolute){
      player.mouseX = readInt16().toDouble();
    }

    if (changeMouseWorldY == ChangeType.One) {
      player.mouseY++;
    } else if (changeMouseWorldY == ChangeType.Delta){
      player.mouseY += readInt8();
    } else if (changeMouseWorldY == ChangeType.Absolute){
      player.mouseY = readInt16().toDouble();
    }

    if (changeScreenLeft == ChangeType.One) {
      player.screenLeft++;
    } else if (changeScreenLeft == ChangeType.Delta){
      player.screenLeft += readInt8();
    } else if (changeScreenLeft == ChangeType.Absolute){
      player.screenLeft = readInt16().toDouble();
    }

    if (changeScreenTop == ChangeType.One) {
      player.screenTop++;
    } else if (changeScreenTop == ChangeType.Delta){
      player.screenTop += readInt8();
    } else if (changeScreenTop == ChangeType.Absolute){
      player.screenTop = readInt16().toDouble();
    }

    if (changeScreenRight == ChangeType.One) {
      player.screenRight++;
    } else if (changeScreenRight == ChangeType.Delta){
      player.screenRight += readInt8();
    } else if (changeScreenRight == ChangeType.Absolute){
      player.screenRight = readInt16().toDouble();
    }

    if (changeScreenBottom == ChangeType.One) {
      player.screenBottom++;
    } else if (changeScreenBottom == ChangeType.Delta){
      player.screenBottom += readInt8();
    } else if (changeScreenBottom == ChangeType.Absolute){
      player.screenBottom = readInt16().toDouble();
    }

    if (debug) return;
    player.game.onPlayerUpdateRequestReceived(
      player: player,
      direction: direction,
      mouseLeftDown: mouseDownLeft,
      mouseRightDown: mouseDownRight,
      keySpaceDown: keyDownSpace,
      keyDownShift: keyDownShift,
    );
  }

  Future joinGameEditorScene(Scene scene) async {
    joinGame(IsometricEditor(scene: scene));
  }

  void joinGame(Game game){
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

  void handleClientRequestJoin(List<String> arguments) {

    if (arguments.length < 2) {
      errorInvalidClientRequest();
      return;
    }

    final gameTypeIndex = parse(arguments[1]);
    if (gameTypeIndex == null || !isValidIndex(gameTypeIndex, GameType.values)){
      errorInvalidClientRequest();
      return;
    }

    final gameType = GameType.values[gameTypeIndex];
    _player = server.joinGameByType(gameType);

    if (arguments.length > 2){
      final player = _player;

      if (player is! AmuletPlayer) {
        throw Exception('player is not AmuletPlayer');
      }

      final idIndex = arguments.indexOf('--id');

      if (idIndex != -1){

        if (idIndex + 1 >= arguments.length){
          throw Exception('id required');
        }

        final characterId = arguments[idIndex + 1];
        player.characterCreated = true;
        player.active = false;
        server.userService.findCharacterById(characterId)
            .then((json) => writeJsonToAmuletPlayer(json, player))
            .catchError((error){
          player.writeAmuletError(error.toString());
        });
        return;
      }
    }
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

  int? parseArg(List<String> arguments, int index, {bool error = true}){

     if (index >= arguments.length) {
       if (error){
         errorInvalidClientRequest();
       }
       return null;
     }
     final value = int.tryParse(arguments[index]);
     if (value == null) {
       if (error){
         errorInvalidClientRequest();
       }
     }
     return value;
  }

  int? parse(String source) {
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

  void readSceneRequest(List<String> arguments) {
    final player = this.player;

    if (player is! IsometricPlayer) {
      errorInvalidPlayerType();
      return;
    }
    final sceneRequestIndex = parseArg1(arguments);
    if (sceneRequestIndex == null)
      return;

    if (!isValidIndex(sceneRequestIndex, NetworkRequestScene.values)){
      errorInvalidClientRequest();
      return;
    }

    final sceneRequest = NetworkRequestScene.values[sceneRequestIndex];

    switch (sceneRequest){
      case NetworkRequestScene.Add_Mark:
        final index = parseArg2(arguments);
        final markType = parseArg3(arguments);

        if (index == null || markType == null){
          return;
        }

        player.scene.addMark(index: index, markType: markType);
        player.game.sortMarksAndDispatch();
        break;
    }
  }

  void readEnvironmentRequest(List<String> arguments) {
    final player = this.player;
    if (player is! IsometricPlayer) {
      errorInvalidPlayerType();
      return;
    }
    if (!isLocalMachine && player.game is! IsometricEditor) return;

    final environmentRequest = parseArg1(arguments);

    switch (environmentRequest) {
      case NetworkRequestEnvironment.Set_Myst:
        final mystType = parseArg2(arguments);
        if (mystType == null)
          return;

        if (!isValidIndex(mystType, MystType.values)){
          return;
        }
        player.game.environment.mystType = mystType;
        break;

      case NetworkRequestEnvironment.Set_Lightning:
        final type = parseArg2(arguments);
        if (type == null)
          return;

        if (!isValidIndex(type, LightningType.values)){
          return;
        }
        player.game.environment.lightningType = type;
        break;

      case NetworkRequestEnvironment.Lightning_Flash:
        player.game.environment.lightningFlash();
        break;
    }
  }

  void handleNetworkRequestDebug() {

    final player = _player;

    if (player is! AmuletPlayer) {
      return;
    }
    final debugRequest = arg1;
    if (debugRequest == null){
      return;
    }


     switch (debugRequest) {
       case NetworkRequestDebug.Set_Complexion:
         final complexion = arg2;
         if (complexion == null || complexion < 0 || complexion >= 64){
           return;
         }
         final selectedCollider = player.selectedCollider;
         if (selectedCollider is! Character) {
           return;
         }
         final selectedCharacter = selectedCollider;
         selectedCharacter.complexion = complexion;
         break;
     }

  }

  void handlePlayerRequest(List<String> arguments) {
    if (_player is! IsometricPlayer) {
      return;
    }
    final playerRequestIndex = arg1;
    if (playerRequestIndex == null){
      return;
    }

    if (!isValidIndex(playerRequestIndex, NetworkRequestPlayer.values)){
      return;
    }
    final playerRequest = NetworkRequestPlayer.values[playerRequestIndex];

    final player = _player as IsometricPlayer;

    switch (playerRequest) {
      case NetworkRequestPlayer.toggleGender:
        player.toggleGender();
        break;

      case NetworkRequestPlayer.setGender:
        final gender = arg2;
        if (gender == null) {
          return;
        }
        player.gender = gender;
        break;

      case NetworkRequestPlayer.setHeadType:
        final headType = arg2;
        if (headType == null) {
          return;
        }
        player.headType = headType;
        break;

      case NetworkRequestPlayer.setHairColor:
        final value = arg2;
        if (value == null) {
          return;
        }
        player.hairColor = value;
        break;

      case NetworkRequestPlayer.setHairType:
        final value = arg2;
        if (value == null) {
          return;
        }
        player.hairType = value;
        break;

      case NetworkRequestPlayer.setComplexion:
        final value = arg2;
        if (value == null) {
          return;
        }
        player.complexion = value;
        break;
      case NetworkRequestPlayer.setName:
        if (arguments.length <= 2){
          return;
        }
        player.name = arguments[2];
        break;
    }
  }
}
