
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/ui/loading_page.dart';
import 'package:provider/provider.dart';

import 'gamestream/isometric/isometric.dart';
import 'gamestream/isometric/ui/isometric_colors.dart';
import 'library.dart';

Widget buildApp(){
  print('buildApp()');

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

  return Provider<Isometric>(
    create: (context) => isometric,
    child: engine,
  );

}