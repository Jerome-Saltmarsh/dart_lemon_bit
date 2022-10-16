import 'package:flutter/material.dart';
import 'package:gamestream_flutter/system.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/website/website.dart';
import 'package:lemon_engine/engine.dart';

void main() {
  Engine.run(
    title: "GameStream",
    init: System.init,
    buildUI: Website.buildUI,
    themeData: ThemeData(fontFamily: 'JetBrainsMono-Regular'),
    backgroundColor: colorPitchBlack,
    onError: System.onError,
  );
}

