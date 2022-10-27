import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/game_system.dart';
import 'package:gamestream_flutter/game_website.dart';
import 'package:lemon_engine/engine.dart';

void main() {
  Engine.run(
    title: "GameStream",
    init: GameSystem.init,
    buildUI: GameWebsite.buildUI,
    buildLoadingScreen: GameWebsite.buildLoadingPage,
    themeData: ThemeData(fontFamily: 'JetBrainsMono-Regular'),
    backgroundColor: GameState.colorPitchBlack,
    onError: GameSystem.onError,
  );
}

