import 'dart:async';
import 'dart:typed_data';

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/game_isometric.dart';
import 'package:bleed_server/src/classes/src/player.dart';
import 'package:bleed_server/src/classes/src/player_aeon.dart';
import 'package:bleed_server/src/classes/src/scene_writer.dart';
import 'package:bleed_server/src/games/game_editor.dart';
import 'package:bleed_server/src/games/game_fight2d.dart';
import 'package:bleed_server/src/games/game_mobile_aoen.dart';
import 'package:bleed_server/src/games/game_combat.dart';
import 'package:bleed_server/src/scene_generator.dart';
import 'package:bleed_server/src/system.dart';
import 'package:lemon_byte/byte_writer.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../functions/generateName.dart';
import '../../utilities/is_valid_index.dart';
import '../../network/handle_request_modify_canvas_size.dart';
import 'package:lemon_byte/byte_reader.dart';

class Connection with ByteReader {
  final started = DateTime.now();
  late WebSocketChannel webSocket;
  late WebSocketSink sink;
  late StreamSubscription subscription;
  Player? _player;
  final errorWriter = ByteWriter();

  Function? onDone;

  Connection(this.webSocket){
    sink = webSocket.sink;

    sink.done.then((value){
      _player = null;
      onDone?.call();
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

      case ClientRequest.Teleport:
        if (!isLocalMachine && game is! GameEditor) return;
        if (player is! IsometricPlayer) return;
        handleClientRequestTeleport(player);
        return;

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
        player.onWeaponChanged();
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
        player.onWeaponChanged();
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
        if (game is! GameIsometric) return;
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
          sendGameError(GameError.Client_Request_Failed_Invalid_Arguments);
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
        if (game is! GameIsometric) return;
        if (player is! IsometricPlayer) return;
        game.setCharacterStateDead(player);
        break;

      case ClientRequest.Weather_Set_Rain:
        if (!isLocalMachine && game is! GameEditor) return;
        final rainType = parse(arguments[1]);
        if (rainType == null || !isValidIndex(rainType, RainType.values)) {
          sendGameError(GameError.Client_Request_Failed_Invalid_Arguments);
          return;
        }

        if (game is! GameIsometric) return;
        game.environment.rainType = rainType;
        break;

      case ClientRequest.Weather_Toggle_Breeze:
        if (!isLocalMachine && game is! GameEditor) return;
        if (game is! GameIsometric) return;
        game.environment.toggleBreeze();
        break;

      case ClientRequest.Weather_Set_Wind:
        if (!isLocalMachine && game is! GameEditor) return;
        final index = parse(arguments[1]);
        if (index == null || !isValidIndex(index, WindType.values)) {
          sendGameError(GameError.Client_Request_Failed_Invalid_Arguments);
          return;
        }
        if (game is! GameIsometric) return;
        game.environment.windType = index;
        break;

      case ClientRequest.Weather_Set_Lightning:
        if (!isLocalMachine && game is! GameEditor) return;
        final index = parse(arguments[1]);
        if (index == null || !isValidIndex(index, LightningType.values)) {
          sendGameError(GameError.Client_Request_Failed_Invalid_Arguments);
          return;
        }
        if (game is! GameIsometric) return;
        game.environment.lightningType = LightningType.values[index];

        if (game.environment.lightningType == LightningType.On){
          game.environment.nextLightningFlash = 1;
        }

        break;

      case ClientRequest.Revive:
        if (player is! IsometricPlayer) return;
        if (player.aliveAndActive) {
          sendGameError(GameError.PlayerStillAlive);
          return;
        }
        if (player.respawnTimer > 0) {
          player.writeGameError(GameError.Respawn_Duration_Remaining);
          return;
        }
        if (game is! GameIsometric) return;
        game.revive(player);
        return;

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

      case ClientRequest.Speak:
        // player.text = arguments
        //     .sublist(1, arguments.length)
        //     .fold("", (previousValue, element) => '$previousValue $element');
        // player.textDuration = 150;
        break;

      case ClientRequest.Teleport_Scene:
        final sceneIndex = parse(arguments[1]);

        if (sceneIndex == null) {
          sendGameError(GameError.Client_Request_Failed_Invalid_Arguments);
          return;
        }

        if (!isValidIndex(sceneIndex, teleportScenes)) {
          sendGameError(GameError.Client_Request_Failed_Invalid_Arguments);
          return;
        }
        break;

      case ClientRequest.Editor_Load_Game:
          joinGameEditor(name: arguments[1]);
          break;

      case ClientRequest.Time_Set_Hour:
        if (!isLocalMachine && game is! GameEditor) return;
          final hour = parse(arguments[1]);
          if (hour == null) return errorInvalidArg('hour required');
          if (game is! GameIsometric) return;
          game.setHourMinutes(hour, 0);
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
       sendGameError(GameError.Client_Request_Failed_Invalid_Arguments);
       return true;
     }
     return false;
  }

  void handleRequestInventory(IsometricPlayer player, List<String> arguments){
    if (insufficientArgs(arguments, 2)) return;
    if (player.deadBusyOrWeaponStateBusy) return;
    final inventoryRequest = parse(arguments[1]);

    if (inventoryRequest == null) return errorInvalidArg('inventory request is null');

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
        if (indexFrom == null) return errorInvalidArg('index from is null');
        if (indexTo == null) return errorInvalidArg('index from is null');
        if (indexFrom < 0) return errorInvalidArg('invalid inventory from index');
        if (indexTo < 0) return errorInvalidArg('invalid inventory to index');
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
      return errorInvalidArg('insufficient args');
    }

    final editRequestIndex = parse(arguments[1]);
    if (editRequestIndex == null){
      return errorInvalidArg('editRequestIndex is null');
    }
    if (!isValidIndex(editRequestIndex, EditRequest.values)){
       return errorInvalidArg('invalid edit request $editRequestIndex');
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
        if (game is! GameIsometric) return;
        game.running = !game.running;
        break;

      case EditRequest.Scene_Reset:
        if (!isLocalMachine && game is! GameEditor) return;
        if (game is! GameIsometric) return;
        game.reset();
        break;

      case EditRequest.Generate_Scene:
        const min = 5;
        final rows = parseArg2(arguments);
        if (rows == null) return;
        if (rows < min) errorInvalidArg('rows < $min');
        final columns = parseArg3(arguments);
        if (columns == null) return;
        if (columns < min) errorInvalidArg('columns < $min');
        final height = parseArg4(arguments);
        if (height == null) return;
        if (height < min) errorInvalidArg('height < $min');
        final altitude = parseArg5(arguments);
        if (altitude == null) return;
        final frequency = parseArg6(arguments);
        if (frequency == null) return;
        if (game is! GameIsometric) return;
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
        if (player is! IsometricPlayer) return;
        player.z = Node_Height * altitude + 24;
        break;

      case EditRequest.Download:
        if (player is! IsometricPlayer) return;
        final compiled = SceneWriter.compileScene(player.scene, gameObjects: true);
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
        if (game is! GameIsometric) return;
        for (var i = 0; i < game.scene.gridArea; i++){
          game.scene.nodeTypes[i] = nodeType;
        }
        game.playersDownloadScene();
        break;
      case EditRequest.Clear_Spawned:
        if (game is! GameIsometric) return;
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
        if (game is! GameIsometric) return;
        game.clearSpawnedAI();
        game.scene.refreshSpawnPoints();
        game.triggerSpawnPoints();
        break;
      case EditRequest.Save:
        if (game is! GameIsometric) return;
        if (game.scene.name.isEmpty){
          player.writeGameError(GameError.Save_Scene_Failed);
          return;
        }
        game.saveSceneToFileBytes();
        break;

      case EditRequest.Modify_Canvas_Size:
        if (arguments.length < 3) {
          return errorInsufficientArgs(3, arguments);
        }
        final modifyCanvasSizeIndex = parse(arguments[2]);
        if (modifyCanvasSizeIndex == null) return;
        if (!isValidIndex(modifyCanvasSizeIndex, RequestModifyCanvasSize.values)){
          return errorInvalidArg('invalid modify canvas index $modifyCanvasSizeIndex');
        }
        final request = RequestModifyCanvasSize.values[modifyCanvasSizeIndex];
        if (player is! IsometricPlayer) return;
        handleRequestModifyCanvasSize(request, player);
        return;

      case EditRequest.Spawn_Zombie:
        if (arguments.length < 3) {
          return errorInsufficientArgs(3, arguments);
        }
        final spawnIndex = parse(arguments[2]);
        if (spawnIndex == null) {
          return errorInvalidArg('spawn index required');
        }
        if (game is! GameIsometric) return;
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

    if (arguments.length < 4) return errorInvalidArg('4 args expected');

    var nodeIndex = parse(arguments[1]);
    var nodeType = parse(arguments[2]);
    var nodeOrientation = parse(arguments[3]);
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
    if (game is! GameIsometric) return;
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
    if (arguments.length != 2) return errorArgsExpected(2, arguments);
    final index = parse(arguments[1]);
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

  void handleGameObjectRequest(List<String> arguments) {
    final player = _player;
    if (player == null) return;

    if (arguments.length <= 1)
      return errorInvalidArg('handleGameObjectRequest invalid args');

    final gameObjectRequestIndex = parse(arguments[1]);

    if (gameObjectRequestIndex == null)
      return errorInvalidArg("gameObjectRequestIndex is null");

    if (!isValidIndex(gameObjectRequestIndex, gameObjectRequests))
      return errorInvalidArg("gameObjectRequestIndex ($gameObjectRequestIndex) is invalid");

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
        if (index == null) return errorInvalidArg('index is null (2)');
        if (type == null) return errorInvalidArg('type is null (3)');
        if (index < 0) return errorInvalidArg('index cannot be negative');
        final scene = player.game.scene;
        if (index >= scene.gridVolume) {
          return errorInvalidArg('index must be lower than grid volume');
        }
        final instance = player.game.spawnGameObject(
          x: scene.convertNodeIndexToPositionX(index) + Node_Size_Half,
          y: scene.convertNodeIndexToPositionY(index) + Node_Size_Half,
          z: scene.convertNodeIndexToPositionZ(index),
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

    // if (player is! IsometricPlayer) return;

    player.game.onPlayerUpdateRequestReceived(
      player: player,
      direction: direction,
      mouseLeftDown: mouseDownLeft,
      mouseRightDown: mouseDownRight,
      keySpaceDown: keyDownSpace,
      inputTypeKeyboard: inputTypeDesktop,
    );
  }

  Future joinGameEditor({String? name}) async {
    joinGame(await engine.findGameEditorNew());
  }

  Future joinGameEditorScene(Scene scene) async {
    joinGame(GameEditor(scene: scene));
  }

  Future joinGameFight2D() async {
    for (final game in engine.games) {
      if (game is GameFight2D) {
        return joinGame(game);
      }
    }
    joinGame(GameFight2D());
  }

  Future joinGameCombat() async {
    for (final game in engine.games) {
      if (game is GameCombat) {
        if (game.players.length >= GameCombat.Max_Players) continue;
        return joinGame(game);
      }
    }
    joinGame(GameCombat(scene: engine.scenes.warehouse));
  }

  Future joinGameAeon() async {
    for (final game in engine.games) {
      if (game is GameMobileAeon) {
        if (game.players.length >= GameCombat.Max_Players) continue;
        return joinGame(game);
      }
    }
    joinGame(GameMobileAeon(scene: engine.scenes.town));
  }

  void joinGame(Game game){
    final player = game.createPlayer();
    game.players.add(player);
    _player = _player = player;
    player.writeGameType();
    player.sendBufferToClient = sendBufferToClient;

  }

  void errorInsufficientResources(){
    sendGameError(GameError.Insufficient_Resources);
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

  void errorParse(String source){
    errorInvalidArg('connection.parse($source)');
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
    if (arguments.length < 2) return errorInsufficientArgs(2, arguments);
    final gameType = parse(arguments[1]);
    switch (gameType) {
      case GameType.Editor:
        joinGameEditor();
        break;
      case GameType.Combat:
        joinGameCombat();
        break;
      case GameType.Mobile_Aeon:
        joinGameAeon();
        break;
      case GameType.Rock_Paper_Scissors:
        joinGame(engine.getGameRockPaperScissors());
        break;
      case GameType.Fight2D:
        joinGameFight2D();
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

  void handleClientRequestTeleport(IsometricPlayer player) {
      player.x = player.mouseGridX;
      player.y = player.mouseGridY;
      player.health = player.maxHealth;
      player.state = CharacterState.Idle;
      player.active = true;
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
       errorInsufficientArgs(index, arguments);
       return null;
     }
     final value = int.tryParse(arguments[index]);
     if (value == null) {
       errorInvalidArg('could not convert argument $index ($value) to int');
     }
     return value;
  }

  int? parse(String source, {int? radix}) {
    final value = int.tryParse(source);
    if (value == null){
        errorParse(source);
       return null;
    }
    return value;
  }

  void errorInvalidArg(String value){
    sendGameError(GameError.Client_Request_Failed_Invalid_Arguments);
  }
}
