
import 'dart:typed_data';


import '../editor/randomize_scene.dart';
import '../packages/isometric_engine/packages/common/src/amulet/quests/quest_tutorials.dart';
import 'amulet.dart';
import 'amulet_game.dart';
import 'amulet_player.dart';
import '../packages/src.dart';
import '../utils/src.dart';

class AmuletController {
  final parser = ByteReader();
  final errorWriter = ByteWriter();
  final AmuletPlayer player;
  final bool isAdmin;
  final Sink sink;
  final void Function(List<String> arguments) handleClientRequestJoin;

  Amulet get amulet => player.amulet;

  bool get isLocalMachine => amulet.isLocalMachine;

  AmuletController({
    required this.player,
    required this.isAdmin,
    required this.sink,
    required this.handleClientRequestJoin,
  });

  void onData(dynamic args) {

    if (args is Uint8List) {
      if (args.isEmpty) return;
      parser.index = 0;
      parser.values = args;
      handleClientRequestUpdate(
        parser: parser,
        debug: false,
        player: player,
      );
      return;
    }

    if (args is String) {
      try {
        return onDataStringArray(args.split(" "));
      } catch (error){
        player.reportException(error);
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


    final clientRequestInt = parse(arguments[0]);

    if (clientRequestInt == null) {
      return sendGameError(GameError.ClientRequestRequired);
    }

    if (clientRequestInt < 0) {
      return sendGameError(GameError.UnrecognizedClientRequest);
    }

    final clientRequest = clientRequestInt;

    if (clientRequest == NetworkRequest.Join) {
      return handleClientRequestJoin(arguments);
    }

    final game = player.game;

    switch (clientRequest) {

      case NetworkRequest.Edit:
        final networkRequestEditIndex = parseArg1(arguments);

        if (networkRequestEditIndex == null) return;

        if (!isValidIndex(networkRequestEditIndex, NetworkRequestEdit.values)) {
          return errorInvalidClientRequest();
        }

        final networkRequestEdit = NetworkRequestEdit.values[
        networkRequestEditIndex
        ];


        final editor = player.editor;

        switch (networkRequestEdit){
          case NetworkRequestEdit.Add_Key:
            handleNetworkRequestEditAddKey(arguments);
            break;
          case NetworkRequestEdit.Delete_Key:
            handleNetworkRequestEditDeleteKey(arguments);
            break;
          case NetworkRequestEdit.Move_Key:
            handleNetworkRequestEditMoveKey(arguments);
            break;
          case NetworkRequestEdit.Rename_Key:
            handleNetworkRequestEditRenameKey(arguments);
            break;
          case NetworkRequestEdit.Set_Node:
            handleNetworkRequestEditSetNode(arguments);
            break;
          case NetworkRequestEdit.Clear_Scene:
            handleNetworkRequestEditClearScene(arguments);
            break;
          case NetworkRequestEdit.GameObject:
            handleIsometricNetworkRequestEditGameObject(arguments);
            break;
          case NetworkRequestEdit.Load_Scene:
            try {
              final args = arguments.map(int.parse).toList(growable: false);
              final scene = SceneReader.readScene(
                Uint8List.fromList(args.sublist(2, args.length)),
              );
              // joinGameEditorScene(scene);
            } catch (err) {
              sendGameError(GameError.Load_Scene_Failed);
            }
            return;
          case NetworkRequestEdit.Toggle_Game_Running:
            if (!isLocalMachine && game is! IsometricEditor) return;
            game.running = !game.running;
            break;

          case NetworkRequestEdit.Scene_Reset:
            if (!isLocalMachine && game is! IsometricEditor) return;
            game.reset();
            break;
          case NetworkRequestEdit.Mark_Deselect_Index:
            editor.selectedMarkListIndex = -1;
            break;
          case NetworkRequestEdit.Mark_Select:
            if (!isLocalMachine && game is! IsometricEditor) {
              return;
            }

            final index = parseArg2(arguments);
            if (index == null) {
              return;
            }

            editor.selectedMarkListIndex = index;
            break;

          case NetworkRequestEdit.Mark_Add:
            final markIndex = parseArg2(arguments);
            if (markIndex == null) {
              return;
            }

            editor.addMark(markIndex);
            break;

          case NetworkRequestEdit.Mark_Delete:
            editor.deleteMark();
            break;

          case NetworkRequestEdit.Mark_Set_Type:
            final markType = parseArg2(arguments);
            if (markType == null) {
              return;
            }

            player.editor.setSelectedMarkType(markType);
            break;

          case NetworkRequestEdit.Mark_Set_Sub_Type:
            final markSubType = parseArg2(arguments);
            if (markSubType == null) {
              return;
            }

            player.editor.setSelectedMarkSubType(markSubType);
            break;

          case NetworkRequestEdit.Generate_Scene:
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

          case NetworkRequestEdit.Download:
            final sceneWriter = SceneWriter();
            final compiled = sceneWriter.compileScene(player.scene, gameObjects: true);
            player.writeByte(NetworkResponse.Scene);
            player.writeByte(NetworkResponseScene.Download_Scene);

            if (player.scene.name.isEmpty){
              player.scene.name = generateRandomName();
            }

            player.writeString(player.scene.name);
            player.writeUInt16(compiled.length);
            player.writeBytes(compiled);
            break;

          case NetworkRequestEdit.Scene_Set_Floor_Type:
            final nodeType = parseArg2(arguments);
            if (nodeType == null) return;
            for (var i = 0; i < game.scene.area; i++){
              game.scene.types[i] = nodeType;
            }
            game.playersDownloadScene();
            break;
          case NetworkRequestEdit.Clear_Spawned:
            game.clearSpawnedAI();
            break;
          case NetworkRequestEdit.Spawn_AI:
            game.clearSpawnedAI();
            player.amuletGame.spawnFiendsAtSpawnNodes();
            break;

          case NetworkRequestEdit.Save:
            if (game.scene.name.isEmpty){
              player.writeGameError(GameError.Save_Scene_Failed);
              return;
            }
            game.applyChangesToScene();
            amulet.scenes.saveSceneToFile(game.scene);
            break;

          case NetworkRequestEdit.Modify_Canvas_Size:
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
          case NetworkRequestEdit.Randomize:
            randomizeScene(player.scene);
            player.game.notifyPlayersSceneChanged();
            break;
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
        handleNetworkRequestDebug(arguments);
        break;

      case NetworkRequest.Player:
        handlePlayerRequest(arguments);
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

  void sendGameError(GameError error) {
    errorWriter.writeByte(NetworkResponse.Game_Error);
    errorWriter.writeByte(error.index);
    sink.add(errorWriter.compile());
  }

  void compileAndSendPlayerBuffer() => sink.add(player.compile());

  Future sendServerError(dynamic error) async {
    errorWriter.writeByte(NetworkResponse.Server_Error);
    errorWriter.writeString(error.toString());
    sink.add(errorWriter.compile());
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


  int? parseArg0(List<String> arguments,) => parseArg(arguments, 0);

  int? parseArg1(List<String> arguments,) => parseArg(arguments, 1);

  int? parseArg2(List<String> arguments,) => parseArg(arguments, 2);

  int? parseArg3(List<String> arguments,) => parseArg(arguments, 3);

  int? parseArg4(List<String> arguments,) => parseArg(arguments, 4);

  int? parseArg5(List<String> arguments,) => parseArg(arguments, 5);

  int? parseArg6(List<String> arguments,) => parseArg(arguments, 6);

  int getArg(List<String> arguments, int index){
    if (index < 0 || index >= arguments.length){
      throw Exception('invalid index');
    }
    return int.parse(arguments[index]);

  }

  void handleNetworkRequestEditAddKey(List<String> arguments) {
    if (arguments.length < 3){
      throw Exception('arguments.length < 3');
    }

    final game = player.game;
    final scene = game.scene;
    final name = arguments[2];
    final index = parseArg(arguments, 3, error: false);

    if (index == null){
      throw Exception('index == null');
    }
    scene.addKey(name, index);
    game.notifyPlayersSceneKeysChanged();
  }

  void readIsometricRequest(List<String> arguments){
    final player = this.player;
    final game = player.game;
    final isometricClientRequestIndex = parseArg1(arguments);
    if (isometricClientRequestIndex == null) {
      return;
    }

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

      case NetworkRequestIsometric.Set_Seconds_Per_Frame:
        final secondsPerFrame = parseArg2(arguments);
        if (secondsPerFrame == null) return;
        game.setSecondsPerFrame(secondsPerFrame);
        break;

      case NetworkRequestIsometric.Editor_Load_Game:
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
        if (debugCharacter is! Character) {
          return;
        }
        final characterType = parseArg2(arguments);
        if (characterType == null) {
          return;
        }
        debugCharacter.characterType = characterType;
        break;

      case NetworkRequestIsometric.Debug_Character_Set_Weapon_Type:
        final debugCharacter = player.selectedCollider;
        if (debugCharacter is! Character) {
          return;
        }
        final weaponType = parseArg2(arguments);
        if (weaponType == null) {
          return;
        }
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

  void readSceneRequest(List<String> arguments) {

    final sceneRequestIndex = parseArg1(arguments);
    if (sceneRequestIndex == null) {
      return;
    }

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
        player.editor.selectedMarkListIndex = player.scene.marks.indexWhere((mark) {
          return index == MarkType.getIndex(mark) && markType ==  MarkType.getType(mark);
        });
        break;
    }
  }

  void handleNetworkRequestAmulet(List<String> arguments){

    final player = this.player;
    final amuletPlayer = player;
    final amuletGame = player.amuletGame;
    final requestIndex = parseArg1(arguments);

    if (requestIndex == null) return;

    if (!isValidIndex(requestIndex, NetworkRequestAmulet.values)){
      errorInvalidClientRequest();
      return;
    }

    final networkRequestAmulet = NetworkRequestAmulet.values[requestIndex];

    switch (networkRequestAmulet) {
      case NetworkRequestAmulet.Spawn_Random_Enemy:
        amuletGame.spawnRandomEnemy();
        break;
      case NetworkRequestAmulet.Acquire_Amulet_Item:
        final amuletItemIndex = arguments.tryGetArgInt('--index');
        final amuletItem = AmuletItem.values.tryGet(amuletItemIndex);
        if (amuletItem == null){
          sendServerError('invalid amulet item index');
          return;
        }
        player.acquireAmuletItem(amuletItem);
        break;
      case NetworkRequestAmulet.End_Interaction:
        player.endInteraction();
        break;
      case NetworkRequestAmulet.Drop_Item_Type:
        final itemType = parseArg2(arguments);
        if (itemType == null) return;
        player.dropItemType(itemType);
        break;
      case NetworkRequestAmulet.Select_Slot_Type:
        final index = parseArg2(arguments);
        final slotType = SlotType.values.tryGet(index);
        if (slotType == null) return;
        player.selectSlotType(slotType);
        break;
      case NetworkRequestAmulet.Select_Talk_Option:
        final index = parseArg2(arguments);
        if (index == null) return;
        player.selectNpcTalkOption(index);
        break;
      case NetworkRequestAmulet.Select_Skill_Type_Left:
        final skillTypeIndex = parseArg2(arguments);
        if (skillTypeIndex == null) return;
        final skillType = SkillType.values.tryGet(skillTypeIndex);
        if (skillType == null){
          return;
        }
        player.selectSkillTypeLeft(skillType);
        break;
      case NetworkRequestAmulet.Select_Skill_Type_Right:
        final skillTypeIndex = parseArg2(arguments);
        if (skillTypeIndex == null) return;
        final skillType = SkillType.values.tryGet(skillTypeIndex);
        if (skillType == null){
          return;
        }
        player.selectSkillTypeRight(skillType);
        break;
      case NetworkRequestAmulet.Reset:
        if (!isAdmin) {
          throw Exception('admin mode not enabled');
        }
        amulet.resetPlayer(amuletPlayer);
        break;
      case NetworkRequestAmulet.Player_Change_Game:
        final index = getArg(arguments, 2);
        final amuletScene = AmuletScene.values[index];
        final amulet = amuletGame.amulet;
        final targetGame = amulet.getAmuletSceneGame(amuletScene);

        amulet.playerChangeGame(
          player: player,
          target: targetGame,
        );

        final portal = targetGame.scene.keys['portal'];

        if (portal != null){
          player.scene.movePositionToIndex(player, portal);
        } else {
          if (player.scene.outOfBoundsPosition(player)){
            player.x = player.scene.rowLength * 0.5;
            player.y = player.scene.columnLength * 0.5;
            player.z = player.scene.heightLength * 0.5;
          }
        }

        break;
      case NetworkRequestAmulet.Skip_Tutorial:
        player.tutorialObjective = QuestTutorial.Finished;
        amulet.playerChangeGameToTown(player);
        break;
    }
  }

  void handleNetworkRequestDebug(List<String> arguments) {

    // final debugRequest = arg1;
    // if (debugRequest == null){
    //   return;
    // }

    // switch (debugRequest) {
    //   case NetworkRequestDebug.Set_Complexion:
    //     final complexion = arg2;
    //     if (complexion == null || complexion < 0 || complexion >= 64){
    //       return;
    //     }
    //     final selectedCollider = player.selectedCollider;
    //     if (selectedCollider is! Character) {
    //       return;
    //     }
    //     final selectedCharacter = selectedCollider;
    //     selectedCharacter.complexion = complexion;
    //     break;
    // }
  }


  void handleNetworkRequestEditDeleteKey(List<String> arguments) {

    if (arguments.length < 3){
      errorInvalidClientRequest();
      return;
    }

    final name = arguments[2];
    final game = player.game;
    final scene = game.scene;
    scene.deleteKey(name);
    game.notifyPlayersSceneKeysChanged();
  }

  void handleNetworkRequestEditMoveKey(List<String> arguments) {

    final name = arguments.tryGetArgString('--name');
    final index = arguments.tryGetArgInt('--index');

    if (name == null){
      sendServerError('--name required');
      return;
    }

    if (index == null){
      sendServerError('--index required');
      return;
    }

    final game = player.game;
    final scene = game.scene;
    final key = scene.keys[name];

    if (key == null){
      sendServerError('key $name could not be found');
      return;
    }

    scene.keys[name] = index;
    game.notifyPlayersSceneKeysChanged();
  }


  void handleNetworkRequestEditRenameKey(List<String> arguments) {

    final from = arguments.tryGetArgString('--from');
    final to = arguments.tryGetArgString('--to');

    if (from == null){
      sendServerError('--from required');
      return;
    }

    if (to == null){
      sendServerError('--to required');
      return;
    }

    final game = player.game;
    final scene = game.scene;
    final keys = scene.keys;

    if (keys.containsKey(to)){
      sendServerError('rename_key_error: "$to" already exists');
      return;
    }

    final index = keys[from];
    if (index == null) {
      sendServerError('rename_key_error: "$from" could not be found');
      return;
    }

    scene.setKey(to, index);
    scene.deleteKey(from);
    game.notifyPlayersSceneKeysChanged();
  }

  void handleNetworkRequestEditSetNode(List<String> arguments) {

    final index = arguments.getArgInt('--index');
    final nodeType = arguments.tryGetArgInt('--type');
    final orientation = arguments.tryGetArgInt('--orientation');
    final variation = arguments.tryGetArgInt('--variation');

    if (nodeType == NodeType.Tree_Bottom){
      player.game.setNode(
        nodeIndex: index + player.game.scene.area,
        nodeType: NodeType.Tree_Top,
        orientation: orientation,
        variation: variation,
      );
    }

    player.game.setNode(
      nodeIndex: index,
      nodeType: nodeType,
      orientation: orientation,
      variation: variation,
    );
  }

  void handleNetworkRequestEditClearScene(List<String> arguments) {
    if (!isLocalMachine && player.game is! IsometricEditor) return;
    final scene = player.game.scene;
    final height = scene.height;
    final rows = scene.rows;
    final columns = scene.columns;

    var index = 0;
    for (var z = 0; z < height; z++){
      for (var row = 0; row < rows; row++){
        for (var column = 0; column < columns; column++){
          if (z == 0){
            scene.setNode(index, NodeType.Grass, NodeOrientation.Solid);
          } else {
            scene.setNode(index, NodeType.Empty, NodeOrientation.None);
          }
          index++;
        }
      }
    }
    scene.gameObjects.clear();
    scene.marks.clear();
    scene.locations.clear();
    scene.keys.clear();
    player.game.notifyPlayersSceneChanged();

  }

  void handleIsometricNetworkRequestEditGameObject(List<String> arguments) {
    if (!isLocalMachine && player.game is! IsometricEditor) return;

    final gameObjectRequestIndex = parseArg2(arguments);

    if (gameObjectRequestIndex == null) {
      return errorInvalidClientRequest();
    }

    if (!isValidIndex(gameObjectRequestIndex, gameObjectRequests)) {
      return errorInvalidClientRequest();
    }

    final gameObjectRequest = gameObjectRequests[gameObjectRequestIndex];
    final selectedGameObject = player.editorSelectedGameObject;

    switch (gameObjectRequest) {


      case IsometricEditorGameObjectRequest.Select:
        final gameObjects = player.game.gameObjects;
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
        if (index == null) {
          return;
        }
        if (type == null) {
          return;
        }
        if (index < 0) {
          return errorInvalidClientRequest();
        }

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

      case IsometricEditorGameObjectRequest.Toggle_Hitable:
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

      case IsometricEditorGameObjectRequest.Toggle_Collidable:
        if (selectedGameObject == null) return;
        selectedGameObject.collidable = !selectedGameObject.collidable;
        player.writeEditorGameObjectSelected();
        break;

      case IsometricEditorGameObjectRequest.Toggle_Interactable:
        if (selectedGameObject == null) return;
        selectedGameObject.interactable = !selectedGameObject.interactable;
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

  void handlePlayerRequest(List<String> arguments) {
    final playerRequestIndex = parseArg1(arguments);
    if (playerRequestIndex == null){
      return;
    }

    if (!isValidIndex(playerRequestIndex, NetworkRequestPlayer.values)){
      return;
    }
    final playerRequest = NetworkRequestPlayer.values[playerRequestIndex];

    switch (playerRequest) {
      case NetworkRequestPlayer.toggleGender:
        player.toggleGender();
        break;

      case NetworkRequestPlayer.setGender:
        final gender = parseArg2(arguments);
        if (gender == null) {
          return;
        }
        player.gender = gender;
        break;

      case NetworkRequestPlayer.setHeadType:
        final headType = parseArg2(arguments);
        if (headType == null) {
          return;
        }
        player.headType = headType;
        break;

      case NetworkRequestPlayer.setHairColor:
        final value = parseArg2(arguments);
        if (value == null) {
          return;
        }
        player.hairColor = value;
        break;

      case NetworkRequestPlayer.setHairType:
        final value = parseArg2(arguments);
        if (value == null) {
          return;
        }
        player.hairType = value;
        break;

      case NetworkRequestPlayer.setComplexion:
        final value = parseArg2(arguments);
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

  void readEnvironmentRequest(List<String> arguments) {
    if (!isLocalMachine && player.game is! IsometricEditor) return;

    final environmentRequest = parseArg1(arguments);

    switch (environmentRequest) {
      case NetworkRequestEnvironment.Set_Myst:
        final mystType = parseArg2(arguments);
        if (mystType == null) {
          return;
        }

        if (!isValidIndex(mystType, MystType.values)){
          return;
        }
        player.game.environment.mystType = mystType;
        break;

      case NetworkRequestEnvironment.Set_Lightning:
        final type = parseArg2(arguments);
        if (type == null) {
          return;
        }

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

  void leaveCurrentGame(){
    final game = player.game;
    game.removePlayer(player);
  }

  void joinGame(AmuletGame game){
    leaveCurrentGame();
    player.game = game;
    player.amuletGame = game;
    player.active = true;
    game.add(player);
  }

  Future joinGameEditorScene(Scene scene) async {
    // final game = AmuletGameEditor(
    //   scene: scene,
    //   amulet: root.amulet,
    // );
    // root.amulet.addGame(game);
    // joinGame(game);
  }

  void handleClientRequestUpdate({
    required bool debug,
    required IsometricPlayer player,
    required ByteReader parser,
  }) {

    player.framesSinceClientRequest = 0;

    final hex = parser.readByte();
    final direction         = hex & 0xf;
    final mouseDownLeft     = hex & ByteHex.Hex_16 > 0;
    final mouseDownRight    = hex & ByteHex.Hex_32 > 0;
    final keyDownShift      = hex & ByteHex.Hex_64 > 0;
    final keyDownSpace      = hex & ByteHex.Hex_128 > 0;
    player.inputMode = hex & ByteHex.Hex_64 > 0 ? 1 : 0;
    player.mouseLeftDown = mouseDownLeft;

    final compress1 = parser.readByte();
    final compress2 = parser.readByte();

    final changeMouseWorldX = compress1 &  0x03;
    final changeMouseWorldY = (compress1 & Hex00001100) >> 2;
    final changeScreenLeft = compress2 & Hex00000011;
    final changeScreenTop = (compress2 & Hex00001100) >> 2;
    final changeScreenRight = (compress2 & Hex00110000) >> 4;
    final changeScreenBottom = (compress2 & Hex11000000) >> 6;

    if (changeMouseWorldX == ChangeType.One) {
      player.mouseX++;
    } else if (changeMouseWorldX == ChangeType.Delta){
      player.mouseX += parser.readInt8();
    } else if (changeMouseWorldX == ChangeType.Absolute){
      player.mouseX = parser.readInt16().toDouble();
    }

    if (changeMouseWorldY == ChangeType.One) {
      player.mouseY++;
    } else if (changeMouseWorldY == ChangeType.Delta){
      player.mouseY += parser.readInt8();
    } else if (changeMouseWorldY == ChangeType.Absolute){
      player.mouseY = parser.readInt16().toDouble();
    }

    if (changeScreenLeft == ChangeType.One) {
      player.screenLeft++;
    } else if (changeScreenLeft == ChangeType.Delta){
      player.screenLeft += parser.readInt8();
    } else if (changeScreenLeft == ChangeType.Absolute){
      player.screenLeft = parser.readInt16().toDouble();
    }

    if (changeScreenTop == ChangeType.One) {
      player.screenTop++;
    } else if (changeScreenTop == ChangeType.Delta){
      player.screenTop += parser.readInt8();
    } else if (changeScreenTop == ChangeType.Absolute){
      player.screenTop = parser.readInt16().toDouble();
    }

    if (changeScreenRight == ChangeType.One) {
      player.screenRight++;
    } else if (changeScreenRight == ChangeType.Delta){
      player.screenRight += parser.readInt8();
    } else if (changeScreenRight == ChangeType.Absolute){
      player.screenRight = parser.readInt16().toDouble();
    }

    if (changeScreenBottom == ChangeType.One) {
      player.screenBottom++;
    } else if (changeScreenBottom == ChangeType.Delta){
      player.screenBottom += parser.readInt8();
    } else if (changeScreenBottom == ChangeType.Absolute){
      player.screenBottom = parser.readInt16().toDouble();
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

  void playerJoinGameTutorial() {
    joinGame(amulet.buildAmuletGameTutorial());
  }

  void playerJoin(){
    playerJoinAmuletTown();
    // if (player.tutorialObjective == QuestTutorial.Finished) {
    //   playerJoinAmuletTown();
    // } else {
    //   playerJoinGameTutorial();
    // }
  }

  void playerJoinAmuletTown() {
    final game = amulet.amuletGameWorld11;
    joinGame(game);
    game.movePositionToIndex(player, game.indexSpawnPlayer);
    player.x += giveOrTake(5);
    player.y += giveOrTake(5);
    player.writePlayerMoved();
  }
}
