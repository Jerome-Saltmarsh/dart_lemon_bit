import 'package:flutter/material.dart';

import 'library.dart';

void main() {
  Engine.run(
    title: "GAMESTREAM ONLINE",
    init: GameSystem.init,
    buildUI: GameWebsite.buildUI,
    buildLoadingScreen: GameWebsite.buildLoadingPage,
    themeData: ThemeData(fontFamily: 'VT323-Regular'),
    backgroundColor: GameColors.black,
    onError: GameSystem.onError,
  );
}

