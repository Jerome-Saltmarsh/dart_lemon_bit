import 'package:flutter/material.dart';

import 'library.dart';

void main() {
  Engine.run(
    title: "Gamestream",
    init: GameSystem.init,
    buildUI: GameWebsite.buildUI,
    buildLoadingScreen: GameWebsite.buildLoadingPage,
    // themeData: ThemeData(fontFamily: 'JetBrainsMono-Regular'),
    themeData: ThemeData(fontFamily: 'Audiowide-Regular'),
    backgroundColor: GameColors.black,
    onError: GameSystem.onError,
  );
}

