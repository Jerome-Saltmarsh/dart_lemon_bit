
import 'package:gamestream_flutter/gamestream/isometric/components/editor/isometric_editor_ui.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/debug/isometric_debug_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/cursor_type.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:lemon_watch/src.dart';

class IsometricGame extends Game {

  bool get debugMode => player.debugging.value;

  bool get editMode => options.edit.value;

  @override
  void drawCanvas(Canvas canvas, Size size) {
    // drawCanvas(canvas, size);
    updateCursorType();
  }

  void updateCursorType() {
    options.cursorType = mapTargetActionToCursorType(player.aimTargetAction.value);
  }

  void renderForeground(Canvas canvas, Size size) {

  }

  void update() {
  }

  void sendIsometricClientRequest([dynamic message]) {
    network.sendNetworkRequest(NetworkRequest.Isometric, message);
  }

  @override
  void onActivated() {
    options.windowOpenMenu.setFalse();
    actions.cameraPlayerTargetPlayer();

    audio.musicStop();
    // engine.onMouseMoved = io.touchController.onMouseMoved;

    if (!engine.isLocalHost) {
      engine.fullScreenEnter();
    }
  }

  Widget customBuildUI(BuildContext context){
    return const SizedBox();
  }

  List<Widget> buildMenuItems(){
    return [];
  }

  @override
  Widget buildUI(BuildContext context) => StackFullscreen(children: [
      buildWatchBool(
          options.triggerAlarmNoMessageReceivedFromServer,
          ui.buildDialogFramesSinceUpdate,
      ),
      WatchBuilder(options.edit, (edit) =>
        edit ? editor.buildEditor() : customBuildUI(context)),
      Positioned(
          top: 16,
          left: 16,
          child: debug.buildUI()
      ),
      // Positioned(
      //   top: 0,
      //   left: 0,
      //   child: Container(
      //       width: engine.screen.width,
      //       alignment: Alignment.center,
      //       child: buildWatch(ui.dialog, (t) => t ?? nothing),
      //   ),
      // ),
      Positioned(
          top: 16,
          right: 16,
          child: ui.buildMainMenu(children: buildMenuItems()),
      ),
      Positioned(
        top: 8,
        left: 0,
        child: Container(
            width: engine.screen.width,
            alignment: Alignment.center,
            child: buildGameError()),
      ),
    ]);

  Widget buildGameError(){
    return buildWatch(options.gameError, (error){
       if (error == null)
         return nothing;

       return buildText(error.name);
    });
  }

  @override
  void onLeftClicked() {
    // if (io.inputModeTouch) {
    //   io.touchController.onClick();
    // }
    if (debugMode) {
      debug.onMouseLeftClicked();
      return;
    }
    if (editMode) {
      editor.onMouseLeftClicked();
      return;
    }
  }

  @override
  void onRightClicked() {
    if (debugMode) {
      debug.onMouseRightClicked();
      return;
    }

    if (editMode){
      editor.onMouseRightClicked();
      return;
    }
  }

  @override
  void onKeyPressed(int key) {

    if (key == KeyCode.Tab) {
      options.toggleEditMode();
      return;
    }

    if (key == KeyCode.Digit_0) {
      network.sendIsometricRequestToggleDebugging();
      return;
    }

    if (key == KeyCode.Escape) {
      options.windowOpenMenu.toggle();
      return;
    }

    if (options.editMode){
      editor.onKeyPressed(key);
      return;
    }

    // play mode

    if (key == KeyCode.Z) {
      actions.toggleZoom();
      return;
    }

    if (key == KeyCode.M){
      amulet.spawnRandomEnemy();
    }

    if (debugMode) {
      debug.onKeyPressed(key);
      return;
    }
  }

  /// override to customize cursor type
  int mapTargetActionToCursorType(int targetCategory) => switch(targetCategory) {
    TargetAction.Attack => IsometricCursorType.CrossHair_Red,
    TargetAction.Talk => IsometricCursorType.Talk,
    TargetAction.Collect => IsometricCursorType.Hand,
    TargetAction.Run => IsometricCursorType.CrossHair_White,
    _ => IsometricCursorType.CrossHair_White,
  };
}