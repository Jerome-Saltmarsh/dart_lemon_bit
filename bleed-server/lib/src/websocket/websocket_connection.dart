import 'dart:async';
import 'dart:typed_data';

import 'package:bleed_server/common/src/byte_hex.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_character_class.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_request.dart';
import 'package:bleed_server/common/src/character_state.dart';
import 'package:bleed_server/common/src/character_type.dart';
import 'package:bleed_server/common/src/client_request.dart';
import 'package:bleed_server/common/src/compile_util.dart';
import 'package:bleed_server/common/src/edit_request.dart';
import 'package:bleed_server/common/src/enums/character_attribute.dart';
import 'package:bleed_server/common/src/enums/item_group.dart';
import 'package:bleed_server/common/src/enums/perk_type.dart';
import 'package:bleed_server/common/src/fight2d/game_fight2d_client_request.dart';
import 'package:bleed_server/common/src/game_error.dart';
import 'package:bleed_server/common/src/game_type.dart';
import 'package:bleed_server/common/src/gameobject_request.dart';
import 'package:bleed_server/common/src/interact_mode.dart';
import 'package:bleed_server/common/src/inventory_request.dart';
import 'package:bleed_server/common/src/isometric/isometric_request.dart';
import 'package:bleed_server/common/src/item_type.dart';
import 'package:bleed_server/common/src/lightning_type.dart';
import 'package:bleed_server/common/src/maths.dart';
import 'package:bleed_server/common/src/node_size.dart';
import 'package:bleed_server/common/src/node_type.dart';
import 'package:bleed_server/common/src/power_type.dart';
import 'package:bleed_server/common/src/rain_type.dart';
import 'package:bleed_server/common/src/request_modify_canvas_size.dart';
import 'package:bleed_server/common/src/server_response.dart';
import 'package:bleed_server/common/src/teleport_scenes.dart';
import 'package:bleed_server/common/src/wind_type.dart';
import 'package:bleed_server/src/engine.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_player.dart';
import 'package:bleed_server/src/utilities/generate_random_name.dart';
import 'package:bleed_server/src/game/game.dart';
import 'package:bleed_server/src/game/player.dart';
import 'package:bleed_server/src/games/aeon/aeon_player.dart';
import 'package:bleed_server/src/games/fight2d/game_fight2d_player.dart';
import 'package:bleed_server/src/games/game_editor.dart';
import 'package:bleed_server/src/games/game_mobile_aoen.dart';
import 'package:bleed_server/src/games/isometric/isometric_game.dart';
import 'package:bleed_server/src/games/isometric/isometric_player.dart';
import 'package:bleed_server/src/games/isometric/isometric_scene.dart';
import 'package:bleed_server/src/games/isometric/isometric_scene_writer.dart';
import 'package:bleed_server/src/utilities/system.dart';
import 'package:bleed_server/src/websocket/handle_request_modify_canvas_size.dart';
import 'package:bleed_server/src/games/isometric/isometric_scene_generator.dart';
import 'package:lemon_byte/byte_writer.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:lemon_byte/byte_reader.dart';


class WebSocketConnection with ByteReader {
  final Engine engine;
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

  void reply(String response) {
    sink.add(response);
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
      values = args;
      switch (values[0]) {
        case ClientRequest.Update:
          handleClientRequestUpdate(args);
          return;
        case ClientRequest.Editor_Load_Scene:
          try {
            final scene = SceneReader.readScene(
              Uint8List.fromList(args.sublist(1, args.length)),
            );
            joinGameEditorScene(scene);
          } catch (err){
            sendGameError(GameError.Save_Scene_Failed);
          }
          return;
        case ClientRequest.Unequip:
          // _player?.unequipWeapon();
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

    if (player == null) return errorPlayerNotFound();
    final game = player.game;

    switch (clientRequest) {

      case ClientRequest.Inventory:
        if (player is! IsometricPlayer) return;
        handleRequestInventory(player, arguments);
        break;

      case ClientRequest.Reload:
        // final game = player.game;
        // game.playerReload(player);
        return;

      case ClientRequest.Select_PerkType:
        final value = parseArg1(arguments);
        if (value == null) return;
        if (!PerkType.values.contains(value)) {
          // player.writeError('invalid perk type');
          return;
        }
        // player.perkType = value;
        return;

      case ClientRequest.Equip:
        final itemType = parseArg1(arguments);
        if (itemType == null) return;
        // player.game.characterEquipItemType(player, itemType);
        return;

      case ClientRequest.Equip_Next:
        final itemGroupIndex = parseArg1(arguments);
        if (itemGroupIndex == null) return;
        if (!isValidIndex(itemGroupIndex, ItemGroup.values)){
          return;
        }
        // game.playerEquipNextItemGroup(player, ItemGroup.values[itemGroupIndex]);
        return;

      case ClientRequest.Swap_Weapons:
        // player.swapWeapons();
        break;

      case ClientRequest.Player_Throw_Grenade:
        // game.playerThrowGrenade(player);
        break;

      case ClientRequest.Select_Weapon_Primary:
        if (player is! IsometricPlayer) return;
        final value = parseArg1(arguments);
        if (value == null) return;
        if (!ItemType.isTypeWeapon(value)) {
          player.writeGameError(GameError.Invalid_Weapon_Type);
          return;
        }
        player.weaponPrimary = value;
        player.weaponType = value;
        player.onWeaponTypeChanged();
        break;

      case ClientRequest.Select_Weapon_Secondary:
        if (player is! IsometricPlayer) return;
        final value = parseArg1(arguments);
        if (value == null) return;
        if (!ItemType.isTypeWeapon(value)) {
          player.writeGameError(GameError.Invalid_Weapon_Type);
          return;
        }
        player.weaponSecondary = value;
        player.weaponType = value;
        player.onWeaponTypeChanged();
        break;

      case ClientRequest.Select_Power:
        if (player is! IsometricPlayer) return;
        final value = parseArg1(arguments);
        if (value == null) return;
        if (!PowerType.values.contains(value)) {
          player.writeGameError(GameError.Invalid_Power_Type);
          return;
        }
        player.powerType = value;
        break;

      case ClientRequest.Attack:
        if (game is! IsometricGame) return;
        if (player is! IsometricPlayer) return;
        game.playerAutoAim(player);
        game.characterAttackMelee(player);
        // game.characterUseOrEquipWeapon(
        //   character: player,
        //   weaponType: player.weaponPrimary,
        //   characterStateChange: false,
        // );
        break;

      case ClientRequest.Select_Attribute:
        if (game is! GameMobileAeon) return;
        if (player is! PlayerAeon) return;
        final attributeId = parseArg1(arguments);
        if (attributeId == null) {
          sendGameError(GameError.Invalid_Client_Request);
          return;
        }

        switch (attributeId) {
          case CharacterAttribute.Magic:
            game.playerAttributesAddMagic(player);
            break;
          case CharacterAttribute.Damage:
            game.playerAttributesAddDamage(player);
            break;
          case CharacterAttribute.Health:
            game.playerAttributesAddHealth(player);
            break;
        }

        break;

      case ClientRequest.Suicide:
        if (game is! IsometricGame) return;
        if (player is! IsometricPlayer) return;
        game.setCharacterStateDead(player);
        break;

      case ClientRequest.Weather_Toggle_Breeze:
        if (!isLocalMachine && game is! GameEditor) return;
        if (game is! IsometricGame) return;
        game.environment.toggleBreeze();
        break;

      case ClientRequest.GameObject:
        if (!isLocalMachine && game is! GameEditor) return;
        return handleGameObjectRequest(arguments);

      case ClientRequest.Node:
        if (!isLocalMachine && game is! GameEditor) return;
        return handleNodeRequestSetBlock(arguments);

      case ClientRequest.Edit:
        if (!isLocalMachine && game is! GameEditor) return;
        return handleRequestEdit(arguments);

      case ClientRequest.Npc_Talk_Select_Option:
        if (player is! IsometricPlayer) return;
        return handleNpcTalkSelectOption(player, arguments);

      case ClientRequest.Teleport_Scene:
        final sceneIndex = parse(arguments[1]);

        if (sceneIndex == null) {
          sendGameError(GameError.Invalid_Client_Request);
          return;
        }

        if (!isValidIndex(sceneIndex, teleportScenes)) {
          sendGameError(GameError.Invalid_Client_Request);
          return;
        }
        break;

      case ClientRequest.Editor_Load_Game:
          _player = engine.joinGameEditor(name: arguments[1]);
          break;

      case ClientRequest.Time_Set_Hour:
        if (!isLocalMachine && game is! GameEditor) return;
          final hour = parse(arguments[1]);
          if (hour == null) return errorInvalidClientRequest();
          if (game is! IsometricGame) return;
          game.setHourMinutes(hour, 0);
          break;

      case ClientRequest.Isometric:
        handleIsometricRequest(arguments);
        break;

      case ClientRequest.Capture_The_Flag:
        if (player is! CaptureTheFlagPlayer) {
          errorInvalidPlayerType();
          return;
        }
        final captureTheFlagRequestIndex = parseArg1(arguments);
        if (captureTheFlagRequestIndex == null) return;
        if (!isValidIndex(captureTheFlagRequestIndex, CaptureTheFlagRequest.values)){
          errorInvalidClientRequest();
          return;
        }
        final captureTheFlagClientRequest = CaptureTheFlagRequest.values[captureTheFlagRequestIndex];

        switch (captureTheFlagClientRequest){
          case CaptureTheFlagRequest.selectClass:
            final characterClassIndex = parseArg2(arguments);
            if (characterClassIndex == null) return;
            if (!isValidIndex(characterClassIndex, CaptureTheFlagCharacterClass.values)){
              return errorInvalidClientRequest();
            }
            final characterClass = CaptureTheFlagCharacterClass.values[characterClassIndex];
            player.game.playerSelectCharacterClass(player, characterClass);
            break;
          case CaptureTheFlagRequest.toggleDebug:
            player.toggleDebugMode();
            break;
        }

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

  void handleRequestInventory(IsometricPlayer player, List<String> arguments){
    if (insufficientArgs(arguments, 2)) return;
    if (player.deadBusyOrWeaponStateBusy) return;
    final inventoryRequest = parse(arguments[1]);

    if (inventoryRequest == null) return errorInvalidClientRequest();

    switch (inventoryRequest) {

      case InventoryRequest.Deposit:
        final index = parse(arguments[2]);
        if (index == null) return;
        player.inventoryDeposit(index);
        break;
      case InventoryRequest.Unequip:
        final index = parse(arguments[2]);
        if (index == null) return;
        player.inventoryUnequip(index);
        break;
      case InventoryRequest.Buy:
        if (insufficientArgs(arguments, 3)) return;
        final index = parse(arguments[2]);
        if (index == null) return;
        player.inventoryBuy(index);
        break;
      case InventoryRequest.Sell:
        final index = parse(arguments[2]);
        if (index == null) return;
        player.inventorySell(index);
        break;
      case InventoryRequest.Toggle:
        player.inventoryOpen = !player.inventoryOpen;
        if (player.inventoryOpen){
          player.interactMode = InteractMode.Inventory;
        } else {
          player.interactMode = InteractMode.None;
        }
        break;
      case InventoryRequest.Drop:
        final index = parse(arguments[2]);
        if (index == null) return;
        if (!player.isValidInventoryIndex(index)){
          player.writeErrorInvalidInventoryIndex(index);
          return;
        }
        player.inventoryDrop(index);
        break;
      case InventoryRequest.Move:
        if (insufficientArgs(arguments, 4)) return;
        final indexFrom = parse(arguments[2]);
        final indexTo = parse(arguments[3]);
        if (indexFrom == null) return errorInvalidClientRequest();
        if (indexTo == null) return errorInvalidClientRequest();
        if (indexFrom < 0) return errorInvalidClientRequest();
        if (indexTo < 0) return errorInvalidClientRequest();
        player.inventorySwapIndexes(indexFrom, indexTo);
        break;
      case InventoryRequest.Equip:
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

  void handleRequestEdit(List<String> arguments) {
    final player = _player;
    if (player == null) return;
    final game = player.game;

    if (arguments.length < 2){
      return errorInvalidClientRequest();
    }

    final editRequestIndex = parse(arguments[1]);
    if (editRequestIndex == null){
      return errorInvalidClientRequest();
    }
    if (!isValidIndex(editRequestIndex, EditRequest.values)){
       return errorInvalidClientRequest();
    }
    final editRequest = EditRequest.values[editRequestIndex];

    if (editRequest != EditRequest.Download
        && !isLocalMachine
        && game is GameEditor == false
    ) {
      player.writeGameError(GameError.Cannot_Edit_Scene);
      return;
    }

    switch (editRequest) {
      case EditRequest.Toggle_Game_Running:
        if (!isLocalMachine && game is! GameEditor) return;
        if (game is! IsometricGame) return;
        game.running = !game.running;
        break;

      case EditRequest.Scene_Reset:
        if (!isLocalMachine && game is! GameEditor) return;
        if (game is! IsometricGame) return;
        game.reset();
        break;

      case EditRequest.Generate_Scene:
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
        if (game is! IsometricGame) return;
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

      case EditRequest.Download:
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

      case EditRequest.Scene_Set_Floor_Type:
        final nodeType = parseArg2(arguments);
        if (nodeType == null) return;
        if (game is! IsometricGame) return;
        for (var i = 0; i < game.scene.gridArea; i++){
          game.scene.nodeTypes[i] = nodeType;
        }
        game.playersDownloadScene();
        break;
      case EditRequest.Clear_Spawned:
        if (game is! IsometricGame) return;
        game.clearSpawnedAI();
        break;
      case EditRequest.Scene_Toggle_Underground:
        // if (player.game is! GameDarkAge) {
        //   errorInvalidArg('game is not GameDarkAge');
        //   return;
        // }
        // final gameDarkAge = player.game as GameDarkAge;
        // gameDarkAge.underground = !gameDarkAge.underground;
        break;
      case EditRequest.Spawn_AI:
        if (game is! IsometricGame) return;
        game.clearSpawnedAI();
        game.scene.refreshSpawnPoints();
        game.triggerSpawnPoints();
        break;
      case EditRequest.Save:
        if (game is! IsometricGame) return;
        if (game.scene.name.isEmpty){
          player.writeGameError(GameError.Save_Scene_Failed);
          return;
        }
        // game.saveSceneToFileBytes();
        engine.isometricScenes.saveSceneToFileBytes(game.scene);
        break;

      case EditRequest.Modify_Canvas_Size:
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

      case EditRequest.Spawn_Zombie:
        if (arguments.length < 3) {
          return errorInvalidClientRequest();
        }
        final spawnIndex = parse(arguments[2]);
        if (spawnIndex == null) {
          return errorInvalidClientRequest();
        }
        if (game is! IsometricGame) return;
        game.spawnAI(
            nodeIndex: spawnIndex,
            characterType: CharacterType.Zombie,
        );
        break;
    }

  }

  void handleNodeRequestSetBlock(List<String> arguments) {
    final player = _player;
    if (player == null) return;
    if (!isLocalMachine && player.game is GameEditor == false) return;

    if (arguments.length < 4) return errorInvalidClientRequest();

    var nodeIndex = parse(arguments[1]);
    var nodeType = parse(arguments[2]);
    var nodeOrientation = parse(arguments[3]);
    if (nodeIndex == null) {
      return errorInvalidClientRequest();
    }
    if (nodeType == null) {
      return errorInvalidClientRequest();
    }
    if (nodeOrientation == null) {
      return errorInvalidClientRequest();
    }
    if (!NodeType.supportsOrientation(nodeType, nodeOrientation)){
      nodeOrientation = NodeType.getDefaultOrientation(nodeType);
    }
    final game = player.game;
    if (game is! IsometricGame) return;
    game.setNode(
        nodeIndex: nodeIndex,
        nodeType: nodeType,
        nodeOrientation: nodeOrientation,
    );
    if (nodeType == NodeType.Tree_Bottom){
      final topIndex = nodeIndex + game.scene.gridArea;
      if (topIndex < game.scene.gridVolume){
        game.setNode(
          nodeIndex: nodeIndex + game.scene.gridArea,
          nodeType: NodeType.Tree_Top,
          nodeOrientation: nodeOrientation,
        );
      }
    }

  }

  void handleNpcTalkSelectOption(IsometricPlayer player, List<String> arguments) {
    if (player.dead) return errorPlayerDead();
    if (arguments.length != 2) return errorInvalidClientRequest();
    final index = parse(arguments[1]);
    if (index == null) {
      return errorInvalidClientRequest();
    }
    if (index < 0 || index >= player.options.length){
      return errorInvalidClientRequest();
    }
    final action = player.options.values.toList()[index];
    action.call();
    return;
  }

  void handleGameObjectRequest(List<String> arguments) {
    final player = _player;
    if (player == null) return;

    if (arguments.length <= 1)
      return errorInvalidClientRequest();

    final gameObjectRequestIndex = parse(arguments[1]);

    if (gameObjectRequestIndex == null)
      return errorInvalidClientRequest();

    if (!isValidIndex(gameObjectRequestIndex, gameObjectRequests))
      return errorInvalidClientRequest();

    final gameObjectRequest = gameObjectRequests[gameObjectRequestIndex];
    if (player is! IsometricPlayer) return;
    final selectedGameObject = player.editorSelectedGameObject;

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
        if (distance < 100){
          player.editorSelectedGameObject = closest;
        } else {
          player.game.playerDeselectEditorSelectedGameObject(player);
        }
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
        selectedGameObject.saveStartAsCurrentPosition();
        break;

      case GameObjectRequest.Add:
        final index = parse(arguments[2]);
        final type = parse(arguments[3]);
        if (index == null) return errorInvalidClientRequest();
        if (type == null) return errorInvalidClientRequest();
        if (index < 0) return errorInvalidClientRequest();
        final scene = player.game.scene;
        if (index >= scene.gridVolume) {
          return errorInvalidClientRequest();
        }
        final instance = player.game.spawnGameObject(
          x: scene.getNodePositionX(index) + Node_Size_Half,
          y: scene.getNodePositionY(index) + Node_Size_Half,
          z: scene.getNodePositionZ(index),
          type: type,
        );
        player.editorSelectedGameObject = instance;
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
        selectedGameObject.saveStartAsCurrentPosition();
        break;

      case GameObjectRequest.Set_Type:
        // TODO: Handle this case.
        break;

      case GameObjectRequest.Toggle_Strikable:
        if (selectedGameObject == null) return;
        selectedGameObject.hitable = !selectedGameObject.hitable;
        selectedGameObject.velocityZ = 0;
        player.writeEditorGameObjectSelected();
        break;

      case GameObjectRequest.Toggle_Fixed:
        if (selectedGameObject == null) return;
        selectedGameObject.fixed = !selectedGameObject.fixed;
        player.writeEditorGameObjectSelected();
        break;

      case GameObjectRequest.Toggle_Collectable:
        if (selectedGameObject == null) return;
        selectedGameObject.collectable = !selectedGameObject.collectable;
        player.writeEditorGameObjectSelected();
        break;

      case GameObjectRequest.Toggle_Gravity:
        if (selectedGameObject == null) return;
        selectedGameObject.gravity = !selectedGameObject.gravity;
        player.writeEditorGameObjectSelected();
        break;

      case GameObjectRequest.Duplicate:
        if (selectedGameObject == null) return;
        final duplicated = player.game.spawnGameObject(
            x: selectedGameObject.x,
            y: selectedGameObject.y,
            z: selectedGameObject.z,
            type: selectedGameObject.type
        );
        player.editorSelectedGameObject = duplicated;
        break;

      case GameObjectRequest.Toggle_Physical:
        if (selectedGameObject == null) return;
        selectedGameObject.physical = !selectedGameObject.physical;
        player.writeEditorGameObjectSelected();
        break;

      case GameObjectRequest.Toggle_Persistable:
        if (selectedGameObject == null) return;
        selectedGameObject.persistable = !selectedGameObject.persistable;
        player.writeEditorGameObjectSelected();
        break;
    }
  }

  void handleClientRequestUpdate(Uint8List args) {
    final player = _player;

    if (player == null) return errorPlayerNotFound();

    final hex = args[1];

    final direction         = hex & 0xf;
    final mouseDownLeft     = hex & ByteHex.Hex_16 > 0;
    final mouseDownRight    = hex & ByteHex.Hex_32 > 0;
    final inputTypeDesktop  = hex & ByteHex.Hex_64 > 0;
    final keyDownSpace      = hex & ByteHex.Hex_128 > 0;

    player.framesSinceClientRequest = 0;
    player.mouse.x = readNumberFromByteArray(args, index: 2).toDouble();
    player.mouse.y = readNumberFromByteArray(args, index: 4).toDouble();
    player.screenLeft = readNumberFromByteArray(args, index: 6).toDouble();
    player.screenTop = readNumberFromByteArray(args, index: 8).toDouble();
    player.screenRight = readNumberFromByteArray(args, index: 10).toDouble();
    player.screenBottom = readNumberFromByteArray(args, index: 12).toDouble();
    player.inputMode = hex & ByteHex.Hex_64 > 0 ? 1 : 0;

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
    joinGame(GameEditor(scene: scene));
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

    switch (gameType) {
      case GameType.Editor:
        _player = engine.joinGameEditor();
        break;
      case GameType.Combat:
        _player = engine.joinGameCombat();
        break;
      case GameType.Aeon:
        _player = engine.joinGameAeon();
        break;
      case GameType.Capture_The_Flag:
        _player = engine.joinGameCaptureTheFlag();
        break;
      case GameType.Mobile_Aeon:
        _player = engine.joinGameAeonMobile();
        break;
      case GameType.Rock_Paper_Scissors:
        joinGame(engine.getGameRockPaperScissors());
        break;
      case GameType.Fight2D:
        _player = engine.joinGameFight2D();
        break;
      default:
        sendGameError(GameError.Unable_To_Join_Game);
        cancelSubscription();
        return;
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

  static bool isValidIndex(int? index, List values){
    if (index == null) return false;
    if (values.isEmpty) return false;
    if (index < 0) return false;
    return index < values.length;
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
      case IsometricRequest.Spawn_Zombie:
        game.spawnAIXYZ(
          x: player.mouseGridX,
          y: player.mouseGridY,
          z: player.game.scene.gridHeightLength - 50,
          characterType: CharacterType.Zombie,
        );
        break;

      case IsometricRequest.Teleport:
        if (!isLocalMachine && game is! GameEditor) return;
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
        if (player.respawnTimer > 0) {
          player.writeGameError(GameError.Respawn_Duration_Remaining);
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
    }
  }
}
