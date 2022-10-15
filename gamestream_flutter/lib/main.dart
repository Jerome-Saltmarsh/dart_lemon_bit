import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/modules/core/init.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/website/website.dart';
import 'package:lemon_engine/engine.dart';

import 'gamestream.dart';

void main() {
  Engine.run(
    title: "GameStream",
    init: init,
    buildUI: Website.buildUI,
    themeData: ThemeData(fontFamily: 'JetBrainsMono-Regular'),
    backgroundColor: colorPitchBlack,
    onError: GameStream.onError,
  );
}

