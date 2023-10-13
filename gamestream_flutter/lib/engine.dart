
import 'package:flutter/material.dart';
import 'package:lemon_engine/lemon_engine.dart';

import 'gamestream/isometric/ui/isometric_colors.dart';
import 'gamestream/isometric/ui/widgets/loading_page.dart';

class AppleEngine extends LemonEngine {
  AppleEngine() : super(
    init: (_){},
    update: (delta) {},
    render: (canvas, size) {}, // overridden when components are ready
    onDrawForeground: (canvas, size) {}, // overridden when components are ready
    title: 'AMULET',
    themeData: ThemeData(fontFamily: 'VT323-Regular'),
    backgroundColor: IsometricColors.Black,
    buildUI: (context) => LoadingPage(),
    buildLoadingScreen: (context) => LoadingPage(),
  );
}