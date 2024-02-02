
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gamestream/isometric/isometric_components.dart';
import 'gamestream/isometric/ui/isometric_colors.dart';
import 'gamestream/isometric/ui/widgets/loading_page.dart';

class AmuletApp extends LemonEngine {

  late IsometricComponents components;

  AmuletApp() : super(
    title: 'AMULET',
    themeData: ThemeData(fontFamily: 'VT323-Regular'),
    backgroundColor: IsometricColors.Black,
    buildLoadingScreen: (context) => LoadingPage(),
  ) {
    zoomMin = 0.3;
  }

  @override
  Widget buildUI(BuildContext buildContext) =>
      components.ui.buildUI(buildContext);

  @override
  void onDispose() {
    components.onDispose();
  }

  @override
  void onDrawCanvas(Canvas canvas, Size size) {
    if (!components.ready){
      return;
    }
    components.render.drawCanvas(canvas, size);
  }

  @override
  void onDrawForeground(Canvas canvas, Size size) {
    // components.render.drawForeground(canvas, size);
  }

  @override
  Future onInit(SharedPreferences sharedPreferences)  async {
     await components.init(sharedPreferences);
   }


  @override
  void onUpdate(double delta) {
    if (!components.ready){
      return;
    }
    components.update(delta);
  }

  @override
  void onScreenSizeChanged(
      double previousWidth,
      double previousHeight,
      double newWidth,
      double newHeight,
  ) {

  }

  @override
  void onMouseEnterCanvas() {
    if (!components.ready){
      return;
    }
    components.options.onMouseEnterCanvas();
  }

  @override
  void onMouseExitCanvas() {
    if (!components.ready){
      return;
    }
    components.options.onMouseExitCanvas();
  }

  @override
  void onLeftClicked() {
    if (!components.ready){
      return;
    }
    components.options.game.value.onLeftClicked();
  }

  @override
  void onRightClicked() {
    if (!components.ready){
      return;
    }
    components.options.game.value.onRightClicked();
  }

  @override
  void onKeyPressed(PhysicalKeyboardKey key) {

    if (!components.ready){
      return;
    }

    if (key == PhysicalKeyboardKey.escape){
      components.engine.fullscreenToggle();
    }

    if (key == PhysicalKeyboardKey.enter){
      components.engine.fullscreenToggle();
    }

    components.options.game.value.onKeyPressed(key);
  }
}