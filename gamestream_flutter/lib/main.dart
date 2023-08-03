import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_colors.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/ui/loading_page.dart';
import 'package:provider/provider.dart';

import 'gamestream/isometric/isometric.dart';
import 'ui/isomeric_app.dart';

void main() {
  print('main()');
  WidgetsFlutterBinding.ensureInitialized();

  final isometric = Isometric();
  final engine = Engine(
    init: isometric.init,
    update: isometric.update,
    render: (canvas, size) {}, // overridden when components are ready
    onDrawForeground: (canvas, size) {}, // overridden when components are ready
    title: 'AMULET',
    themeData: ThemeData(fontFamily: 'VT323-Regular'),
    backgroundColor: IsometricColors.Black,
    onError: isometric.onError,
    buildUI: (context)=> LoadingPage(),
    buildLoadingScreen: (context) => LoadingPage(),
  );

  isometric.engine = engine;
  isometric.connectComponents();

  runApp(Provider<Isometric>(
    create: (context) => isometric,
    child: engine,
  ));
}

