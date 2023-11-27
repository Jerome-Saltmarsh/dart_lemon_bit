
import 'package:flutter/material.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gamestream/isometric/isometric_components.dart';
import 'gamestream/isometric/ui/isometric_colors.dart';
import 'gamestream/isometric/ui/widgets/loading_page.dart';

class AppleEngine extends LemonEngine {

  late IsometricComponents components;

  AppleEngine() : super(
    title: 'AMULET',
    themeData: ThemeData(fontFamily: 'VT323-Regular'),
    backgroundColor: IsometricColors.Black,
    buildLoadingScreen: (context) => LoadingPage(),
  );

  @override
  Widget buildUI(BuildContext buildContext) {
    return components.ui.buildUI(buildContext);
  }

  @override
  void onDispose() {
    components.onDispose();
  }

  @override
  void onDrawCanvas(Canvas canvas, Size size) {
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
    components.options.onMouseEnterCanvas();
  }

  @override
  void onMouseExitCanvas() {
    components.options.onMouseExitCanvas();
  }

  @override
  void onLeftClicked() {
    components.options.game.value.onLeftClicked();
  }

  @override
  void onRightClicked() {
    components.options.game.value.onRightClicked();
  }

  @override
  void onKeyPressed(int keyCode) {
    components.options.game.value.onKeyPressed(keyCode);
  }
}