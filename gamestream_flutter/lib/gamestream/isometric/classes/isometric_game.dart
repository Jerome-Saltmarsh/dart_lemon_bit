
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_editor_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/cursor_type.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/isometric_actions.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_player.dart';
import 'package:gamestream_flutter/gamestream/ui/builders/src.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/stack_fullscreen.dart';
import 'package:gamestream_flutter/library.dart';

import '../ui/game_isometric_ui.dart';

class IsometricGame extends Game {

  final Isometric isometric;

  IsometricGame({required this.isometric}) {
    isometric.camera.target = isometric.player.position;
  }

  IsometricPlayer get player => isometric.player;

  @override
  void drawCanvas(Canvas canvas, Size size) {
    isometric.drawCanvas(canvas, size);
    updateCursorType();
  }

  void updateCursorType() {
    isometric.clientState.cursorType = mapTargetCategoryToCursorType(isometric.player.aimTargetCategory);
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
    isometric.particles.clearParticles();
    isometric.ui.windowOpenMenu.setFalse();

    gamestream.audio.musicStop();
    engine.onMouseMoved = gamestream.io.touchController.onMouseMoved;

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
          isometric.clientState.triggerAlarmNoMessageReceivedFromServer,
          GameIsometricUI.buildDialogFramesSinceUpdate,
      ),
      WatchBuilder(isometric.clientState.edit, (edit) =>
        edit ? isometric.editor.buildEditor() : customBuildUI(context)),
      isometric.ui.buildStackDebug(),
      isometric.ui.buildWindowLightSettings(),
      Positioned(
          top: 80,
          right: 16,
          child: isometric.debug.buildUI()
      ),
      Positioned(top: 16, right: 16, child: GameIsometricUI.buildMainMenu(children: buildMenuItems())),
    ]);

  @override
  void onLeftClicked() {
    if (gamestream.io.inputModeTouch){
      gamestream.io.touchController.onClick();
    }
    if (isometric.clientState.edit.value) {
      isometric.editor.onMouseLeftClicked();
    }
  }

  @override
  void onKeyPressed(int key) {

    if (key == KeyCode.Tab) {
      isometric.clientState.edit.value = !isometric.clientState.edit.value;
      return;
    }

    if (key == KeyCode.Digit_0) {
      isometric.ui.windowOpenDebug.toggle();
      return;
    }

    if (key == KeyCode.Escape) {
      isometric.ui.windowOpenMenu.toggle();
      return;
    }

    if (key == KeyCode.G) {
      isometric.teleportDebugCharacterToMouse();
      return;
    }

    if (key == KeyCode.P) {
      isometric.ui.windowOpenLightSettings.toggle();
      return;
    }

    if (isometric.clientState.editMode){
      isometric.editor.onKeyPressedModeEdit(key);
      return;
    }

    // play mode

    if (key == KeyCode.F) {
      gamestream.isometric.toggleZoom();
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