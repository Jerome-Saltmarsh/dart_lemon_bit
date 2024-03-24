
import 'package:amulet_client/enums/cursor_type.dart';
import 'package:amulet_client/enums/mode.dart';
import 'package:amulet_common/src.dart';
import 'package:amulet_client/classes/position.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_watch/src.dart';
import 'package:flutter/material.dart';
import 'package:amulet_client/components/src.dart';

import 'isometric_component.dart';

class IsometricOptions with IsometricComponent implements Updatable {
  var renderNorth = true;
  var renderEast = true;
  var alphaBlend = 128;
  var cameraPlayFollowPlayer = true;
  var charactersEffectParticles = false;
  var renderWindVelocity = false;
  var renderCameraTargets = false;
  var renderVisibilityBeams = false;
  var renderHeightMap = false;
  var renderCharacterAnimationFrame = false;
  var characterRenderScale = 0.35;
  var characterShadowColor = Colors.black38;
  var framesPerLightingUpdate = 60;
  var cursorType = IsometricCursorType.Hand;
  var renderCursorEnable = true;
  var renderHealthBars = true;
  var updateAmbientAlphaAccordingToTimeEnabled = true;
  var sceneSmokeSourcesSmokeDuration = 250;
  var clearErrorTimer = -1;
  var messageStatusDuration = 0;
  var renderResponse = true;
  var developMode = false;

  final secondsPerFrame = Watch(0);
  final cameraPlay = Position();
  final cameraEdit = Position();
  final cameraDebug = Position();
  final mode = Watch(Mode.play);
  final highlightIconInventory = WatchBool(false);
  final timeVisible = WatchBool(false);
  final windowOpenMenu = WatchBool(false);
  final serverFPS = Watch(0);
  final sceneName = Watch<String?>(null);
  final gameRunning = Watch(true);
  final watchTimePassing = Watch(false);
  final rendersSinceUpdate = Watch(0);
  final triggerAlarmNoMessageReceivedFromServer = Watch(false);
  final messageStatus = Watch('');
  final colorFilterColor = Watch(Colors.white);
  final colorFilterBlendMode = Watch(BlendMode.modulate);
  final colorFilterDay = Watch(Colors.white);
  final colorFilterNight = Watch(Color.lerp(Color.fromRGBO(247, 150, 23, 1.0), Colors.white, goldenRatio_0381) ?? (throw Exception()));
  final filterQuality = Watch(FilterQuality.none);
  final colorFilters = List.generate(colorFiltersLength, (index) => ColorFilter.mode(Colors.white, BlendMode.modulate));
  // late final Watch<Game> game;

  static const colorFiltersLength = 48;

  IsometricOptions(){
    mode.onChanged(onChangedMode);
    messageStatus.onChanged(_onChangedMessageStatus);
    rendersSinceUpdate.onChanged(_onChangedRendersSinceUpdate);
    sceneName.onChanged((t) {print('scene.name = $t');});
    colorFilterColor.onChanged((t) {
      engine.paint.colorFilter = ColorFilter.mode(t, colorFilterBlendMode.value);
    });
    colorFilterBlendMode.onChanged((t) {
      engine.paint.colorFilter = ColorFilter.mode(colorFilterColor.value, t);
    });
    filterQuality.onChanged((t) {
      engine.paint.filterQuality = t;
    });
    colorFilterDay.onChanged((t) {
      rebuildColorFilters();
    });
    colorFilterNight.onChanged((t) {
      rebuildColorFilters();
    });
  }

  void rebuildColorFilters() {
    for (var index = 0; index < colorFilters.length; index++){
      final i = index / colorFiltersLength;
      final color = Color.lerp(colorFilterDay.value, colorFilterNight.value, i);
      colorFilters[index] = ColorFilter.mode(color ?? (throw Exception('invalid color')), BlendMode.modulate);
    }
    scene.refreshColorFilter();
  }

  @override
  void onComponentReady() {
    super.onComponentReady();
    rebuildColorFilters();
  }

  @override
  Future onComponentInit(sharedPreferences) async {
    print('uri-base-host: ${Uri.base.host}');
    // game = Watch<Game>(website, onChanged: _onChangedGame);
    engine.durationPerUpdate.value = convertFramesPerSecondToDuration(45);
    engine.cursorType.value = SystemMouseCursors.basic;
    engine.paint.colorFilter = ColorFilter.mode(Colors.orange, BlendMode.modulate);
    engine.paint.filterQuality = filterQuality.value;

    assert((){
      print('options.developMode: true');
      developMode = true;
      return true;
    }());

    // colorFilters = List.generate(colorFiltersLength, (index) {
    //    final i = index / colorFiltersLength;
    //    final color = Color.lerp(colorFilterDay.value, colorFilterNight.value, i);
    //    return ColorFilter.mode(color ?? (throw Exception('invalid color')), BlendMode.modulate);
    // });

    // var cacheLoaded = false;
    // server.remote.userId.onChanged((t) {
    //   if (t.isEmpty){
    //     sharedPreferences.remove('userId');
    //   } else {
    //     sharedPreferences.setString('userId', t);
    //   }
    // });
    // serverMode.onChanged((value){
    //   if (cacheLoaded){
    //     return;
    //   }
    //   cacheLoaded = true;
    //   if (value == ServerMode.remote){
    //     final userId = sharedPreferences.getString('userId');
    //     if (userId != null) {
    //       server.remote.userId.value = userId;
    //     }
    //   }
    // });
  }

  void onMouseEnterCanvas(){
    renderCursorEnable = true;
  }

  void onMouseExitCanvas(){
    renderCursorEnable = false;
  }

  void toggleRenderHealthBars(){
    renderHealthBars = !renderHealthBars;
  }

  void onChangedGameError(GameError? gameError){
    print('_onChangedGameError($gameError)');
    if (gameError == null)
      return;

    switch (gameError) {
      case GameError.Unable_To_Join_Game:
        server.disconnect();
        break;
      case GameError.PlayerNotFound:
        server.disconnect();
        break;
      default:
        break;
    }
  }

  // void _onChangedGame(Game game) {
  //   print('options.onChangedGame($game)');
  //   ui.gameUI.value = game.buildUI;
  //   game.onActivated();
  // }

  void toggleEditMode() {
    if (editing){
      setModePlay();
    } else {
      setModeEdit();
    }
  }

  void onChangedMode(Mode mode) {
    switch (mode){
      case Mode.play:
        editor.sendGameObjectRequestDeselect();
        activateCameraPlay();
        break;
      case Mode.edit:
        editor.cameraCenterOnNodeSelectedIndex();
        editor.cursorSetToPlayer();
        activateCameraEdit();
        break;
      case Mode.debug:
        activateCameraDebug();
        break;
    }
  }

  void activateCameraDebug() => setCameraTarget(cameraDebug);

  void activateCameraEdit() => setCameraTarget(cameraEdit);

  void activateCameraPlay() => setCameraTarget(cameraPlay);

  void setCameraTarget(Position? value) => camera.target = value;

  void _onChangedMessageStatus(String value){
    if (value.isEmpty){
      messageStatusDuration = 0;
    } else {
      messageStatusDuration = 150;
    }
  }

  void setModePlay() => setMode(Mode.play);

  void setModeEdit() => setMode(Mode.edit);

  void setModeDebug() => setMode(Mode.debug);

  void setMode(Mode value) => mode.value = value;

  void onChangedError(String error) {
    messageStatus.value = error;
    if (error.isNotEmpty) {
      messageStatusDuration = 200;
    } else {
      messageStatusDuration = 0;
    }
  }

  void onComponentUpdate() {

    // game.value.update();

    if (cameraPlayFollowPlayer){
      cameraPlay.copy(player.position);
    }

    if (messageStatusDuration > 0) {
      messageStatusDuration--;
      if (messageStatusDuration <= 0) {
        messageStatus.value = '';
      }
    }

    if (clearErrorTimer > 0) {
      clearErrorTimer--;
      if (clearErrorTimer <= 0)
        amulet.gameError.value = null;
    }

    // switch (mode.value){
    //   case Mode.edit:
    //     editor.update();
    //     break;
    //   case Mode.play:
    //     break;
    //   case Mode.debug:
    //     debugger.update();
    //     break;
    // }
  }

  void _onChangedRendersSinceUpdate(int value){
    triggerAlarmNoMessageReceivedFromServer.value = value > 200;
  }

  // Game mapGameTypeToGame(GameType gameType) => switch (gameType) {
  //   GameType.Website => website,
  //   GameType.Amulet => amulet,
  //   _ => throw Exception('mapGameTypeToGame($gameType)')
  // };

  void toggleRenderCharacterAnimationFrame() =>
      renderCharacterAnimationFrame = !renderCharacterAnimationFrame;

  void toggleRenderCameraTargets() => renderCameraTargets = !renderCameraTargets;

  bool get debugging => isMode(Mode.debug);

  bool get editing => isMode(Mode.edit);

  bool get playing => isMode(Mode.play);

  bool isMode(Mode value) => mode.value == value;

  set debugging(bool value) => mode.value = value ? Mode.debug : Mode.play;

  void setCameraPositionToPlayer(){
    final cameraPlay = this.cameraPlay;
    final player = this.player;
    cameraPlay.x = player.x;
    cameraPlay.y = player.y;
    cameraPlay.z = player.z;
  }

  @override
  void onComponentDispose() {
    print('isometricNetwork.onComponentDispose()');
    server.disconnect();
  }

  // bool get playModeMulti => serverMode.value == ServerMode.remote;

  // bool get playModeSingle => serverMode.value == ServerMode.local;

}