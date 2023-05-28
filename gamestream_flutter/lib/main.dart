import 'package:flutter/material.dart';

import 'engine/instances.dart';
import 'library.dart';

void main() {
  Engine.run(
    title: "GAMESTREAM ONLINE",
    init: gsEngine.init,
    buildUI: GameWebsite.buildUI,
    buildLoadingScreen: GameWebsite.buildLoadingPage,
    themeData: ThemeData(fontFamily: 'VT323-Regular'),
    backgroundColor: GameColors.black,
    onError: GSEngine.onError,
    update: (){},
    render: (canvas, size) {

    }
  );
}

