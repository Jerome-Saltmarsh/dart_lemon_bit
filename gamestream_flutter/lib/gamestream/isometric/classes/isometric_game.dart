
import 'package:gamestream_flutter/gamestream/isometric/components/editor/isometric_editor_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/mode.dart';
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
    audio.musicStop();

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
      Positioned(
        top: 0,
        left: 0,
        child: WatchBuilder(options.mode, (mode) =>
            switch (mode) {
              Mode.Play => customBuildUI(context),
              Mode.Edit => editor.buildEditor(),
              Mode.Debug => debug.buildUI(),
              _ => nothing,
            }),
      ),

      // Positioned(
      //     top: 16,
      //     left: 16,
      //     child: debug.buildUI()
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
    if (options.debugging) {
      debug.onMouseLeftClicked();
      return;
    }
    if (options.editing) {
      editor.onMouseLeftClicked();
      return;
    }
  }

  @override
  void onRightClicked() {
    if (options.debugging) {
      debug.onMouseRightClicked();
      return;
    }

    if (options.editing){
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

    if (options.editing){
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

    if (options.debugging) {
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