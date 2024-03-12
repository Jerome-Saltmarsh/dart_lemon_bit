

import 'package:amulet_engine/common.dart';
import 'package:amulet_flutter/isometric/classes/game.dart';
import 'package:amulet_flutter/isometric/components/debug/isometric_debug_ui.dart';
import 'package:amulet_flutter/isometric/src.dart';
import 'package:amulet_flutter/isometric/ui/widgets/stack_fullscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class IsometricGame extends Game {

  @override
  void drawCanvas(Canvas canvas, Size size) {
    // drawCanvas(canvas, size);
    // updateCursorType();
  }

  void renderForeground(Canvas canvas, Size size) {

  }

  void update() {
  }

  void sendIsometricClientRequest([dynamic message]) =>
      server.sendNetworkRequest(NetworkRequest.Isometric, message);

  @override
  void onActivated() {
    options.windowOpenMenu.setFalse();
    audio.musicStop();
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
        child: buildWatch(options.mode, (mode) =>
            switch (mode) {
              Mode.play => customBuildUI(context),
              Mode.edit => editor.buildEditor(),
              Mode.debug => debugger.buildUI(),
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

       return buildText(error.name.replaceAll('_', ' '));
    });
  }

  @override
  void onLeftClicked() {
    // if (io.inputModeTouch) {
    //   io.touchController.onClick();
    // }
    if (options.debugging) {
      debugger.onMouseLeftClicked();
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
      debugger.onMouseRightClicked();
      return;
    }

    if (options.editing){
      editor.onMouseRightClicked();
      return;
    }
  }

  @override
  void onKeyPressed(PhysicalKeyboardKey key) {

    if (options.developMode){
      if (key == PhysicalKeyboardKey.tab) {
        options.toggleEditMode();
        return;
      }

      if (key == PhysicalKeyboardKey.digit0) {
        server.sendIsometricRequestToggleDebugging();
        return;
      }

      if (key == PhysicalKeyboardKey.digit7) {
        amulet.toggleDebugEnabled();
        return;
      }

      if (key == PhysicalKeyboardKey.digit8) {
        amulet.windowVisibleQuantify.toggle();
        return;
      }
    }

    if (key == PhysicalKeyboardKey.escape) {
      options.windowOpenMenu.toggle();
      return;
    }

    if (options.editing){
      editor.onKeyPressed(key);
      return;
    }

    // play mode

    if (key == PhysicalKeyboardKey.keyZ) {
      actions.toggleZoom();
      return;
    }

    // if (key == PhysicalKeyboardKey.keyM){
    //   amulet.spawnRandomEnemy();
    // }

    if (options.debugging) {
      debugger.onKeyPressed(key);
      return;
    }
  }
}