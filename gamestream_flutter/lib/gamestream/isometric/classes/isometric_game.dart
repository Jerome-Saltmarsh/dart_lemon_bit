
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/debug/isometric_debug_ui.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/isometric.dart';
import 'package:gamestream_flutter/library.dart';

class IsometricGame extends Game {

  bool get debugMode => isometric.player.debugging.value;

  bool get editMode => options.edit.value;

  IsometricPlayer get player => isometric.player;

  @override
  void drawCanvas(Canvas canvas, Size size) {
    // isometric.drawCanvas(canvas, size);
    updateCursorType();
  }

  void updateCursorType() {
    options.cursorType = mapTargetCategoryToCursorType(isometric.player.aimTargetCategory);
  }

  void renderForeground(Canvas canvas, Size size) {

  }

  void update() {
  }

  void sendIsometricClientRequest([dynamic message]) {
    network.send(ClientRequest.Isometric, message);
  }

  @override
  void onActivated() {
    particles.clearParticles();
    options.windowOpenMenu.setFalse();
    action.cameraTargetPlayer();

    audio.musicStop();
    isometric.engine.onMouseMoved = isometric.io.touchController.onMouseMoved;

    if (!isometric.engine.isLocalHost) {
      isometric.engine.fullScreenEnter();
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
          isometric.ui.buildDialogFramesSinceUpdate,
      ),
      WatchBuilder(options.edit, (edit) =>
        edit ? isometric.editor.buildEditor() : customBuildUI(context)),
      Positioned(
          top: 16,
          left: 16,
          child: isometric.debug.buildUI()
      ),
      Positioned(
          top: 16,
          right: 16,
          child: isometric.ui.buildMainMenu(children: buildMenuItems()),
      ),
      Positioned(
        bottom: 16,
        left: 0,
        child: Container(
            width: isometric.engine.screen.width,
            alignment: Alignment.center,
            child: buildGameError()),
      ),
    ]);

  Widget buildGameError(){
    return buildWatch(options.error, (error){
       if (error == null)
         return nothing;

       return buildText(error.name);
    });
  }

  @override
  void onLeftClicked() {
    if (isometric.io.inputModeTouch) {
      isometric.io.touchController.onClick();
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
      isometric.editor.onKeyPressedModeEdit(key);
      return;
    }

    // play mode

    if (key == KeyCode.Z) {
      action.toggleZoom();
      return;
    }

    if (debugMode) {
      isometric.debug.onKeyPressed(key);
      return;
    }
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