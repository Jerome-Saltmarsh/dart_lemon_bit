import 'package:flutter/material.dart';

import 'engine/instances.dart';
import 'library.dart';

void main() {
  Engine.run(
    title: "GAMESTREAM ONLINE",
    init: gamestream.init,
    buildUI: GameWebsite.buildUI,
    buildLoadingScreen: GameWebsite.buildLoadingPage,
    themeData: ThemeData(fontFamily: 'VT323-Regular'),
    backgroundColor: GameColors.black,
    onError: Gamestream.onError,
    update: (){},
    render: (canvas, size) {

    }
  );
}

