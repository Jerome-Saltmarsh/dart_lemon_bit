
import 'package:archive/archive.dart';
import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_response_reader.dart';
import 'package:gamestream_flutter/gamestream/games/game_scissors_paper_rock.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_read_response.dart';
import 'package:gamestream_flutter/gamestream/games/website/website_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/isometric_events.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/classes/template_animation.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/isometric_response_reader.dart';
import 'package:gamestream_flutter/gamestream/network/functions/detect_connection_region.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game.dart';
import 'games.dart';
import 'games/fight2d/game_fight2d.dart';
import 'isometric/atlases/atlas.dart';
import 'isometric/classes/isometric_character.dart';
import 'isometric/classes/isometric_position.dart';
import 'isometric/classes/isometric_projectile.dart';
import 'isometric/components/functions/format_bytes.dart';
import 'isometric/isometric.dart';
import 'isometric/ui/isometric_colors.dart';
import 'network/enums/connection_region.dart';
import 'network/enums/connection_status.dart';
import 'network/game_network.dart';
import 'operation_status.dart';

class Gamestream extends StatelessWidget with ByteReader {

  final serverResponseStack = Uint8List(1000);
  final serverResponseStackLength = Uint16List(1000);
  var serverResponseStackIndex = 0;

  var previousServerResponse = -1;
  var renderResponse = false;
  var clearErrorTimer = -1;

  DateTime? timeConnectionEstablished;

  final serverFPS = Watch(0);
  final bufferSize = Watch(0);
  final bufferSizeTotal = Watch(0);
  final decoder = ZLibDecoder();
  final audio = GameAudio();
  final operationStatus = Watch(OperationStatus.None);
  final isometric = Isometric();

  late final Engine engine;
  late final updateFrame = Watch(0, onChanged: onChangedUpdateFrame);
  late final io = GameIO(isometric);
  late final gameType = Watch(GameType.Website, onChanged: onChangedGameType);
  late final game = Watch<Game>(games.website, onChanged: _onChangedGame);
  late final error = Watch<GameError?>(null, onChanged: _onChangedGameError);
  late final account = Watch<Account?>(null, onChanged: onChangedAccount);
  late final GameNetwork network;
  late final Games games;
  late final rendersSinceUpdate = Watch(0, onChanged: gamestream.isometric.onChangedRendersSinceUpdate);
  var engineBuilt = false;

  Gamestream() {
    print('GameStream()');
    games = Games(this);
    network = GameNetwork(this);
    network.connectionStatus.onChanged(onChangedNetworkConnectionStatus);
  }

   Future init(SharedPreferences sharedPreferences) async {
     print('gamestream.init()');
     print("environment: ${engine.isLocalHost ? 'localhost' : 'production'}");

     final visitDateTimeString = sharedPreferences.getString('visit-datetime');
     if (visitDateTimeString != null) {
       final visitDateTime = DateTime.parse(visitDateTimeString);
       final durationSinceLastVisit = DateTime.now().difference(visitDateTime);
       print('duration since last visit: ${durationSinceLastVisit.inSeconds} seconds');
       games.website.saveVisitDateTime();
       if (durationSinceLastVisit.inSeconds > 45){
         games.website.checkForLatestVersion();
         return;
       }
     }

     print('time zone: ${detectConnectionRegion()}');
     engine.onScreenSizeChanged = onScreenSizeChanged;
     engine.deviceType.onChanged(onDeviceTypeChanged);
     engine.durationPerUpdate.value = convertFramesPerSecondToDuration(20);
     engine.drawCanvasAfterUpdate = false;
     renderResponse = true;
     Images.loadImages();
     engine.cursorType.value = CursorType.Basic;
     io.detectInputMode();

     for (final entry in GameObjectType.Collection.entries){
       final type = entry.key;
       final values = entry.value;
       final atlas = Atlas.SrcCollection[type];
       for (final value in values){
         if (!atlas.containsKey(value)){
           // print('missing atlas src for ${GameObjectType.getName(type)} ${GameObjectType.getNameSubType(type, value)}');
           throw Exception('missing atlas src for ${GameObjectType.getName(type)} ${GameObjectType.getNameSubType(type, value)}');
         }
       }
     }

     for (final weaponType in WeaponType.values){
       try {
         TemplateAnimation.getWeaponPerformAnimation(weaponType);
       } catch (e){
         print('attack animation missing for ${GameObjectType.getNameSubType(GameObjectType.Weapon, weaponType)}');
       }
     }

     error.onChanged((GameError? error) {
         if (error == null) return;
         game.value.onGameError(error);
     });

     games.website.errorMessageEnabled.value = true;

     final visitCount = sharedPreferences.getInt('visit-count');
     if (visitCount == null){
       sharedPreferences.putAny('visit-count', 1);
       games.website.visitCount.value = 1;
     } else {
       sharedPreferences.putAny('visit-count', visitCount + 1);
       games.website.visitCount.value = visitCount + 1;

       final cachedVersion = sharedPreferences.getString('version');
       if (cachedVersion != null){
         if (version != cachedVersion){
           print('New version detected (previous: $cachedVersion, latest: $version)');
         }
       }

       network.region.value = engine.isLocalHost ? ConnectionRegion.LocalHost : ConnectionRegion.Asia_South;
     }
     await Future.delayed(const Duration(seconds: 4));
   }

   /// EVENT HANDLER (DO NOT CALL)
   void _onChangedGame(Game game) {
     engine.onDrawCanvas = game.drawCanvas;
     engine.onDrawForeground = game.renderForeground;
     engine.buildUI = game.buildUI;
     engine.onLeftClicked = game.onLeftClicked;
     engine.onRightClicked = game.onRightClicked;
     engine.onKeyPressed = game.onKeyPressed;
     engine.onMouseEnterCanvas = game.onMouseEnter;
     engine.onMouseExitCanvas = game.onMouseExit;
     game.onActivated();
   }

   void onChangedGameType(GameType value) {
     print('onChangedGameType(${value.name})');
     io.reset();
     startGameByType(value);
   }

   void startGameByType(GameType gameType){
     game.value = games.mapGameTypeToGame(gameType);
   }

   void onScreenSizeChanged(
       double previousWidth,
       double previousHeight,
       double newWidth,
       double newHeight,
       ) => io.detectInputMode();

   void onDeviceTypeChanged(int deviceType){
     io.detectInputMode();
   }

   void startGameType(GameType gameType){
      network.connectToGame(gameType);
   }

   void disconnect(){
     network.disconnect();
   }

   void onError(Object error, StackTrace stack) {
     if (error.toString().contains('NotAllowedError')){
       // https://developer.chrome.com/blog/autoplay/
       // This error appears when the game attempts to fullscreen
       // without the user having interacted first
       // TODO dispatch event on fullscreen failed
       isometric.onErrorFullscreenAuto();
       return;
     }
     print(error.toString());
     print(stack);
     gamestream.games.website.error.value = error.toString();
   }

   void _onChangedGameError(GameError? gameError){
     print('_onChangedGameError($gameError)');
     if (gameError == null)
       return;

     clearErrorTimer = 300;
     isometric.playAudioError();
     switch (gameError) {
       case GameError.Unable_To_Join_Game:
         gamestream.games.website.error.value = 'unable to join game';
         network.disconnect();
         break;
       default:
         break;
     }
   }

   void onChangedAccount(Account? account) {
     if (account == null) return;
     final flag = 'subscription_status_${account.userId}';
     if (storage.contains(flag)){
       final storedSubscriptionStatusString = storage.get<String>(flag);
       final storedSubscriptionStatus = parseSubscriptionStatus(storedSubscriptionStatusString);
     }
   }

   void onChangedNetworkConnectionStatus(ConnectionStatus connection) {
     engine.onDrawForeground = null;
     bufferSizeTotal.value = 0;

     switch (connection) {
       case ConnectionStatus.Connected:
         engine.cursorType.value = CursorType.None;
         engine.zoomOnScroll = true;
         engine.zoom = 1.0;
         engine.targetZoom = 1.0;
         timeConnectionEstablished = DateTime.now();
         audio.enabledSound.value = true;
         if (!engine.isLocalHost) {
           engine.fullScreenEnter();
         }
         break;

       case ConnectionStatus.Done:
         engine.cameraX = 0;
         engine.cameraY = 0;
         engine.zoom = 1.0;
         engine.drawCanvasAfterUpdate = true;
         engine.cursorType.value = CursorType.Basic;
         engine.fullScreenExit();
         isometric.player.active.value = false;
         timeConnectionEstablished = null;
         isometric.clear();
         isometric.clean();
         isometric.gameObjects.clear();
         isometric.sceneEditable.value = false;
         gameType.value = GameType.Website;
         audio.enabledSound.value = false;
         break;
       case ConnectionStatus.Failed_To_Connect:
         gamestream.games.website.error.value = 'Failed to connect';
         break;
       case ConnectionStatus.Invalid_Connection:
         gamestream.games.website.error.value = 'Invalid Connection';
         break;
       case ConnectionStatus.Error:
         gamestream.games.website.error.value = 'Connection Error';
         break;
       default:
         break;
     }
   }

  void onChangedUpdateFrame(int value){
    rendersSinceUpdate.value = 0;
  }

  void update(){
    updateClearErrorTimer();
    game.value.update();
  }

  void updateClearErrorTimer() {
    if (clearErrorTimer <= 0)
      return;

    clearErrorTimer--;
    if (clearErrorTimer > 0)
      return;

    error.value = null;
  }

  void render(Canvas canvas, Size size){

  }

  @override
  Widget build(BuildContext context) {
     print('gamestream.build()');

     if (engineBuilt){
       return engine;
     }

     engineBuilt = true;
     engine = Engine(
      init: init,
      update: update,
      render: render,
      title: 'AMULET',
      themeData: ThemeData(fontFamily: 'VT323-Regular'),
      backgroundColor: IsometricColors.black,
      onError: onError,
      buildUI: games.website.buildUI,
      buildLoadingScreen: games.website.buildLoadingPage,
    );
    return engine;
  }

  Duration? get connectionDuration {
    if (timeConnectionEstablished == null) return null;
    return DateTime.now().difference(timeConnectionEstablished!);
  }


  String get formattedConnectionDuration {
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    final seconds = duration.inSeconds % 60;
    final minutes = duration.inMinutes;
    return 'minutes: $minutes, seconds: $seconds';
  }

  String formatAverageBufferSize(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    final seconds = duration.inSeconds;
    final bytesPerSecond = (bytes / seconds).round();
    final bytesPerMinute = bytesPerSecond * 60;
    final bytesPerHour = bytesPerMinute * 60;
    return 'per second: $bytesPerSecond, per minute: $bytesPerMinute, per hour: $bytesPerHour';
  }

  String formatAverageBytePerSecond(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round());
  }

  String formatAverageBytePerMinute(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round() * 60);
  }

  String formatAverageBytePerHour(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round() * 3600);
  }

  void readServerResponse(Uint8List values) {
    assert (values.isNotEmpty);
    updateFrame.value++;
    index = 0;
    this.values = values;
    bufferSize.value = values.length;
    bufferSizeTotal.value += values.length;

    var serverResponseStart = -1;
    var serverResponse = -1;
    serverResponseStackIndex = -1;
    final length = values.length - 1;

    while (index < length) {

      if (serverResponse != -1) {
        serverResponseStackIndex++;
        serverResponseStack[serverResponseStackIndex] = serverResponse;
        serverResponseStackLength[serverResponseStackIndex] = index - serverResponseStart;
      }

      serverResponseStart = index;
      serverResponse = readByte();
      readResponse(serverResponse);

      previousServerResponse = serverResponse;
    }

    serverResponseStackIndex++;
    serverResponseStack[serverResponseStackIndex] = serverResponse;
    serverResponseStackLength[serverResponseStackIndex] = index - serverResponseStart;
    bufferSize.value = index;
    index = 0;

    if (renderResponse){
      engine.redrawCanvas();
    }
  }

  void readResponse(int serverResponse){
    switch (serverResponse) {
      case ServerResponse.Isometric_Characters:
        readIsometricCharacters();
        break;
      case ServerResponse.Api_Player:
        readApiPlayer();
        break;
      case ServerResponse.Api_SPR:
        readServerResponseApiSPR();
        break;
      case ServerResponse.Isometric:
        readIsometricResponse();
        break;
      case ServerResponse.GameObject:
        readGameObject();
        break;
      case ServerResponse.Projectiles:
        readProjectiles();
        break;
      case ServerResponse.Game_Event:
        readGameEvent();
        break;
      case ServerResponse.Player_Event:
        readPlayerEvent();
        break;
      case ServerResponse.Game_Time:
        readGameTime();
        break;
      case ServerResponse.Game_Type:
        final index = readByte();
        if (index >= GameType.values.length){
          throw Exception('invalid game type index $index');
        }
        gameType.value = GameType.values[index];
        break;
      case ServerResponse.Environment:
        readServerResponseEnvironment();
        break;
      case ServerResponse.Node:
        readNode();
        break;
      case ServerResponse.Player_Target:
        readIsometricPosition(isometric.player.target);
        break;
      case ServerResponse.Store_Items:
        readStoreItems();
        break;
      case ServerResponse.Npc_Talk:
        readNpcTalk();
        break;
      case ServerResponse.Weather:
        readWeather();
        break;
      case ServerResponse.Game_Properties:
        readGameProperties();
        break;
      case ServerResponse.Map_Coordinate:
        readMapCoordinate();
        break;
      case ServerResponse.Editor_GameObject_Selected:
        readEditorGameObjectSelected();
        break;
      case ServerResponse.Info:
        readServerResponseInfo();
        break;
      case ServerResponse.Fight2D:
        readServerResponseFight2D(games.fight2D);
        break;
      case ServerResponse.Capture_The_Flag:
        readCaptureTheFlag();
        break;
      case ServerResponse.MMO:
        readMMOResponse();
        break;
      case ServerResponse.Download_Scene:
        final name = readString();
        final length = readUInt16();
        final bytes = readBytes(length);
        engine.downloadBytes(bytes, name: '$name.scene');
        break;
      case ServerResponse.GameObject_Deleted:
        isometric.removeGameObjectById(readUInt16());
        break;
      case ServerResponse.Game_Error:
        final errorTypeIndex = readByte();
        error.value = GameError.fromIndex(errorTypeIndex);
        return;
      case ServerResponse.FPS:
        serverFPS.value = readUInt16();
        return;
      default:
        print('read error; index: $index, previous-server-response: $previousServerResponse');
        print(values);
        return;
    }
  }

  void readServerResponseFight2D(GameFight2D game) {
    final fight2DResponse = readByte();
    switch (fight2DResponse) {
      case GameFight2DResponse.Characters:
        readGameFight2DResponseCharacters(game);
        break;
      case GameFight2DResponse.Player:
        final player = game.player;
        player.state = readByte();
        player.x = readInt16().toDouble();
        player.y = readInt16().toDouble();
        break;
      case GameFight2DResponse.Event:
        readFight2DEvent();
        break;
      case GameFight2DResponse.Scene:
        game.sceneWidth = readUInt16();
        game.sceneHeight = readUInt16();
        game.sceneNodes = readUint8List(game.sceneTotal);
        break;
      case GameFight2DResponse.Player_Edit:
        game.player.edit.value = readBool();
        break;
      default:
        throw Exception('unknown fight2DResponse $fight2DResponse');
    }
  }

  void readFight2DEvent() {
    final eventType = readByte();
    final x = readInt16().toDouble();
    final y = readInt16().toDouble();

    switch (eventType) {
      case GameFight2DEvents.Punch:
        audio.playAudioSingle2D(audio.heavy_punch_13, x, y);
        break;
      case GameFight2DEvents.Jump:
        audio.playAudioSingle2D(audio.jump, x, y);
        break;
      case GameFight2DEvents.Footstep:
        audio.playAudioSingle2D(audio.footstep_stone, x, y);
        break;
      case GameFight2DEvents.Strike_Swing:
        audio.playAudioSingle2D(audio.arm_swing_whoosh_11, x, y);
        break;
      case GameFight2DEvents.Death:
        audio.playAudioSingle2D(audio.magical_impact_16, x, y);
        break;
    }
  }

  void readMap(Map<int, int> map){
    final length = readUInt16();
    map.clear();
    for (var i = 0; i < length; i++) {
      final key = readUInt16();
      final value = readUInt16();
      map[key] = value;
    }
  }

  void readServerResponseInfo() {
    final info = readString();
    print(info);
  }

  void readServerResponseEnvironment() {
    final environmentResponse = readByte();
    switch (environmentResponse) {
      case EnvironmentResponse.Rain:
        isometric.rainType.value = readByte();
        break;
      case EnvironmentResponse.Lightning:
        isometric.lightningType.value = readByte();
        break;
      case EnvironmentResponse.Wind:
        isometric.windTypeAmbient.value = readByte();
        break;
      case EnvironmentResponse.Breeze:
        isometric.weatherBreeze.value = readBool();
        break;
      case EnvironmentResponse.Underground:
        isometric.sceneUnderground.value = readBool();
        break;
      case EnvironmentResponse.Lightning_Flashing:
        isometric.lightningFlashing.value = readBool();
        break;
      case EnvironmentResponse.Time_Enabled:
        isometric.gameTimeEnabled.value = readBool();
        break;
    }
  }

  void readGameObject() {
    final id = readUInt16();
    final gameObject = isometric.findOrCreateGameObject(id);
    gameObject.active = readBool();
    gameObject.type = readByte();
    gameObject.subType = readByte();
    gameObject.health = readUInt16();
    gameObject.maxHealth = readUInt16();
    readIsometricPosition(gameObject);
    isometric.gameObjects.sort();
  }

  void readApiPlayer() {
    final apiPlayer = readByte();
    final player = isometric.player;
    switch (apiPlayer) {
      case ApiPlayer.Aim_Target_Category:
        player.aimTargetCategory = readByte();
        break;
      case ApiPlayer.Aim_Target_Position:
        readIsometricPosition(player.aimTargetPosition);
        break;
      case ApiPlayer.Aim_Target_Type:
        player.aimTargetType = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Quantity:
        player.aimTargetQuantity = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Name:
        player.aimTargetName = readString();
        break;
      case ApiPlayer.Arrived_At_Destination:
        player.arrivedAtDestination.value = readBool();
        break;
      case ApiPlayer.Run_To_Destination_Enabled:
        player.runToDestinationEnabled.value = readBool();
        break;
      case ApiPlayer.Debugging:
        player.debugging.value = readBool();
        break;
      case ApiPlayer.Destination:
        player.runX = readDouble();
        player.runY = readDouble();
        player.runZ = readDouble();
        break;
      case ApiPlayer.Target_Position:
        player.runningToTarget = true;
        readIsometricPosition(player.targetPosition);
        break;
      case ApiPlayer.Experience_Percentage:
        isometric.playerExperiencePercentage.value = readPercentage();
        break;
      case ApiPlayer.Health:
        readPlayerHealth();
        break;
      case ApiPlayer.Aim_Angle:
        isometric.player.mouseAngle = readAngle();
        break;
      case ApiPlayer.Message:
        isometric.player.message.value = readString();
        break;
      case ApiPlayer.Alive:
        isometric.player.alive.value = readBool();
        // isometric.ui.mouseOverDialog.setFalse();
        break;
      case ApiPlayer.Spawned:
        isometric.camera.centerOnChaseTarget();
        io.recenterCursor();
        break;
      case ApiPlayer.Damage:
        isometric.player.weaponDamage.value = readUInt16();
        break;
      case ApiPlayer.Id:
        isometric.player.id.value = readUInt24();
        break;
      case ApiPlayer.Active:
        isometric.player.active.value = readBool();
        break;
      case ApiPlayer.Team:
        isometric.player.team.value = readByte();
        break;
      default:
        throw Exception('Cannot parse apiPlayer $apiPlayer');
    }
  }

  void readApiPlayerEnergy() =>
      isometric.player.energyPercentage = readPercentage();

  void readPlayerHealth() {
    isometric.player.health.value = readUInt16();
    isometric.player.maxHealth.value = readUInt16();
  }

  void readMapCoordinate() {
    readByte(); // DO NOT DELETE
  }

  void readEditorGameObjectSelected() {
    // readVector3(isometricEngine.editor.gameObject);

    final id = readUInt16();
    final gameObject = isometric.findGameObjectById(id);
    if (gameObject == null) throw Exception('could not find gameobject with id $id');
    isometric.editor.gameObject.value = gameObject;
    isometric.editor.gameObjectSelectedCollidable   .value = readBool();
    isometric.editor.gameObjectSelectedFixed        .value = readBool();
    isometric.editor.gameObjectSelectedCollectable  .value = readBool();
    isometric.editor.gameObjectSelectedPhysical     .value = readBool();
    isometric.editor.gameObjectSelectedPersistable  .value = readBool();
    isometric.editor.gameObjectSelectedGravity      .value = readBool();

    isometric.editor.gameObjectSelectedType.value          = gameObject.type;
    isometric.editor.gameObjectSelectedSubType.value       = gameObject.subType;
    isometric.editor.gameObjectSelected.value              = true;
    isometric.editor.cameraCenterSelectedObject();

    isometric.editor.gameObjectSelectedEmission.value = gameObject.colorType;
    isometric.editor.gameObjectSelectedEmissionIntensity.value = gameObject.emission_intensity;
  }

  void readIsometricCharacters(){
    final scene = isometric;
    isometric.totalCharacters = 0;

    while (true) {

      final compressionLevel = readByte();
      if (compressionLevel == CHARACTER_END) break;
      final character = scene.getCharacterInstance();


      final stateAChanged = readBitFromByte(compressionLevel, 0);
      final stateBChanged = readBitFromByte(compressionLevel, 1);
      final changeTypeX = (compressionLevel & Hex00001100) >> 2;
      final changeTypeY =  (compressionLevel & Hex00110000) >> 4;
      final changeTypeZ = (compressionLevel & Hex11000000) >> 6;

      if (stateAChanged) {
        character.characterType = readByte();
        character.state = readByte();
        character.team = readByte();
        character.health = readPercentage();
      }

      if (stateBChanged){
        final animationAndFrameDirection = readByte();
        character.direction = (animationAndFrameDirection & Hex11100000) >> 5;
        assert (character.direction >= 0 && character.direction <= 7);
        character.animationFrame = (animationAndFrameDirection & Hex00011111);
      }



      assert (changeTypeX >= 0 && changeTypeX <= 2);
      assert (changeTypeY >= 0 && changeTypeY <= 2);
      assert (changeTypeZ >= 0 && changeTypeZ <= 2);

      if (changeTypeX == ChangeType.Small) {
        character.x += readInt8();
      } else if (changeTypeX == ChangeType.Big) {
        character.x = readDouble();
      }

      if (changeTypeY == ChangeType.Small) {
        character.y += readInt8();
      } else if (changeTypeY == ChangeType.Big) {
        character.y = readDouble();
      }

      if (changeTypeZ == ChangeType.Small) {
        character.z += readInt8();
      } else if (changeTypeZ == ChangeType.Big) {
        character.z = readDouble();
      }

      if (character.characterType == CharacterType.Template){
        readCharacterTemplate(character);
      }
      scene.totalCharacters++;
    }
  }

  void readNpcTalk() {
    isometric.player.npcTalk.value = readString();
    final totalOptions = readByte();
    final options = <String>[];
    for (var i = 0; i < totalOptions; i++) {
      options.add(readString());
    }
    isometric.player.npcTalkOptions.value = options;
  }

  void readGameProperties() {
    isometric.sceneEditable.value = readBool();
    isometric.sceneName.value = readString();
    isometric.gameRunning.value = readBool();
  }

  void readWeather() {
    isometric.rainType.value = readByte();
    isometric.weatherBreeze.value = readBool();
    isometric.lightningType.value = readByte();
    isometric.windTypeAmbient.value = readByte();
  }

  void readStoreItems() {
    final length = readUInt16();
    if (isometric.player.storeItems.value.length != length){
      isometric.player.storeItems.value = Uint16List(length);
    }
    for (var i = 0; i < length; i++){
      isometric.player.storeItems.value[i] = readUInt16();
    }
  }

  void readNode() {
    final nodeIndex = readUInt24();
    final nodeType = readByte();
    final nodeOrientation = readByte();
    assert(NodeType.supportsOrientation(nodeType, nodeOrientation));
    isometric.nodeTypes[nodeIndex] = nodeType;
    isometric.nodeOrientations[nodeIndex] = nodeOrientation;
    /// TODO optimize
    isometric.onChangedNodes();
    isometric.editor.refreshNodeSelectedIndex();
  }

  void readPlayerTarget() {
    readIsometricPosition(isometric.player.abilityTarget);
  }

  void readGameTime() {
    isometric.seconds.value = readUInt24();
  }

  double readDouble() => readInt16().toDouble();

  void readGameEvent(){
    final type = readByte();
    final x = readDouble();
    final y = readDouble();
    final z = readDouble();
    final angle = readDouble() * degreesToRadians;
    isometric.onGameEvent(type, x, y, z, angle);
  }

  void readProjectiles(){
    isometric.totalProjectiles = readUInt16();
    while (isometric.totalProjectiles >= isometric.projectiles.length){
      isometric.projectiles.add(IsometricProjectile());
    }
    for (var i = 0; i < isometric.totalProjectiles; i++) {
      final projectile = isometric.projectiles[i];
      projectile.x = readDouble();
      projectile.y = readDouble();
      projectile.z = readDouble();
      projectile.type = readByte();
      projectile.angle = readDouble() * degreesToRadians;
    }
  }

  void readCharacterTemplate(IsometricCharacter character){

    final compression = readByte();

    final readA = readBitFromByte(compression, 0);
    final readB = readBitFromByte(compression, 1);
    final readC = readBitFromByte(compression, 2);

    if (readA){
      character.weaponType = readByte();
      character.bodyType = readByte();
      character.headType = readByte();
      character.legType = readByte();
    }

    if (readB){
      final lookDirectionWeaponState = readByte();
      character.lookDirection = readNibbleFromByte1(lookDirectionWeaponState);
      final weaponState = readNibbleFromByte2(lookDirectionWeaponState);
      character.weaponState = weaponState;
    }

    if (readC) {
      character.weaponStateDuration = readByte();
    } else {
      character.weaponStateDuration = 0;
    }
  }

  void readPlayerEvent() {
    isometric.onPlayerEvent(readByte());
  }

  void readIsometricPosition(IsometricPosition value){
    value.x = readDouble();
    value.y = readDouble();
    value.z = readDouble();
  }

  double readPercentage() => readByte() / 255.0;

  double readAngle() => readDouble() * degreesToRadians;

  Map<int, List<int>> readMapListInt(){
    final valueMap = <int, List<int>> {};
    final totalEntries = readUInt16();
    for (var i = 0; i < totalEntries; i++) {
      final key = readUInt16();
      final valueLength = readUInt16();
      final values = readUint16List(valueLength);
      valueMap[key] = values;
    }
    return valueMap;
  }

  void readServerResponseApiSPR() {
    switch (readByte()){
      case ApiSPR.Player_Positions:
        GameScissorsPaperRock.playerTeam = readByte();
        GameScissorsPaperRock.playerX = readDouble();
        GameScissorsPaperRock.playerY = readDouble();

        final total = readUInt16();
        GameScissorsPaperRock.totalPlayers = total;
        for (var i = 0; i < total; i++) {
          final player     = GameScissorsPaperRock.players[i];
          player.team      = readUInt8();
          player.x         = readInt16().toDouble();
          player.y         = readInt16().toDouble();
          player.targetX   = readInt16().toDouble();
          player.targetY   = readInt16().toDouble();
        }
        break;
    }
  }

  void readGameFight2DResponseCharacters(GameFight2D game) {
    final totalPlayers = readUInt16();
    assert (totalPlayers < GameFight2D.length);
    game.charactersTotal = totalPlayers;
    for (var i = 0; i < totalPlayers; i++) {
      game.characterState[i] = readByte();
      game.characterDirection[i] = readByte();
      game.characterIsBot[i] = readBool();
      game.characterDamage[i] = readUInt16();
      game.characterPositionX[i] = readInt16().toDouble();
      game.characterPositionY[i] = readInt16().toDouble();
      game.characterStateDuration[i] = readByte();
    }
  }

  CaptureTheFlagAIDecision readCaptureTheFlagAIDecision() => CaptureTheFlagAIDecision.values[readByte()];

  CaptureTheFlagAIRole readCaptureTheFlagAIRole() => CaptureTheFlagAIRole.values[readByte()];

}