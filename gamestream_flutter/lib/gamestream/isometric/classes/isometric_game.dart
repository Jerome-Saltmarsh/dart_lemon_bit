
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/debug/isometric_debug_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/editor/isometric_editor_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/cursor_type.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/isometric_actions.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_player.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/library.dart';

import '../ui/game_isometric_ui.dart';

class IsometricGame extends Game {

  IsometricRender get renderer => isometric.renderer;

  final Isometric isometric;

  IsometricGame({required this.isometric}) {
    isometric.camera.target = isometric.player.position;
  }

  bool get debugMode => gamestream.isometric.player.debugging.value;

  bool get editMode => isometric.edit.value;

  IsometricPlayer get player => isometric.player;

  @override
  void drawCanvas(Canvas canvas, Size size) {
    isometric.drawCanvas(canvas, size);
    updateCursorType();
  }

  void updateCursorType() {
    isometric.cursorType = mapTargetCategoryToCursorType(isometric.player.aimTargetCategory);
  }

  @override
  void renderForeground(Canvas canvas, Size size) {
    isometric.renderer.renderForeground(canvas, size);
  }

  @override
  void update() {
    isometric.update();
  }

  void sendIsometricClientRequest([dynamic message]) {
    gamestream.network.sendClientRequest(ClientRequest.Isometric, message);
  }

  @override
  void onActivated() {
    isometric.clearParticles();
    isometric.ui.windowOpenMenu.setFalse();

    gamestream.audio.musicStop();
    gamestream.engine.onMouseMoved = gamestream.io.touchController.onMouseMoved;

    if (!gamestream.engine.isLocalHost) {
      gamestream.engine.fullScreenEnter();
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
          isometric.triggerAlarmNoMessageReceivedFromServer,
          GameIsometricUI.buildDialogFramesSinceUpdate,
      ),
      WatchBuilder(isometric.edit, (edit) =>
        edit ? isometric.editor.buildEditor() : customBuildUI(context)),
      Positioned(
          top: 16,
          left: 16,
          child: isometric.debug.buildUI()
      ),
      Positioned(
          top: 16,
          right: 16,
          child: GameIsometricUI.buildMainMenu(children: buildMenuItems()),
      ),
      Positioned(
        bottom: 16,
        left: 0,
        child: Container(
            width: gamestream.engine.screen.width,
            alignment: Alignment.center,
            child: buildGameError()),
      ),
    ]);

  Widget buildGameError(){
    return buildWatch(gamestream.error, (error){
       if (error == null)
         return nothing;

       return buildText(error.name);
    });
  }

  @override
  void onLeftClicked() {
    if (gamestream.io.inputModeTouch) {
      gamestream.io.touchController.onClick();
    }
    if (editMode) {
      isometric.editor.onMouseLeftClicked();
      return;
    }
    if (debugMode) {
      isometric.debug.onMouseLeftClicked();
      return;
    }
  }

  @override
  void onRightClicked() {
    if (debugMode) {
      isometric.debug.onMouseRightClicked();
      return;
    }
  }

  @override
  void onKeyPressed(int key) {

    if (key == KeyCode.Tab) {
      toggleEditMode();
      return;
    }

    if (key == KeyCode.Digit_0) {
      gamestream.isometric.toggleDebugging();
      return;
    }

    if (key == KeyCode.Escape) {
      isometric.ui.windowOpenMenu.toggle();
      return;
    }

    if (isometric.editMode){
      isometric.editor.onKeyPressedModeEdit(key);
      return;
    }

    // play mode

    if (key == KeyCode.Z) {
      gamestream.isometric.toggleZoom();
      return;
    }

    if (debugMode) {
      isometric.debug.onKeyPressed(key);
      return;
    }
  }

  void toggleEditMode() {
    isometric.edit.value = !editMode;
  }

  /// override to customize cursor type
  int mapTargetCategoryToCursorType(int targetCategory) => switch(targetCategory) {
    TargetCategory.Attack => IsometricCursorType.CrossHair_Red,
    TargetCategory.Talk => IsometricCursorType.Talk,
    TargetCategory.Nothing => IsometricCursorType.CrossHair_White,
    TargetCategory.Collect => IsometricCursorType.Hand,
    TargetCategory.Run => IsometricCursorType.CrossHair_White,
    _ => IsometricCursorType.CrossHair_White,
  };
}