
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/ui/loading_page.dart';
import 'package:provider/provider.dart';

import 'gamestream/isometric/isometric_components.dart';
import 'gamestream/isometric/ui/isometric_colors.dart';
import 'library.dart';

Widget buildApp(){
  print('buildApp()');

  WidgetsFlutterBinding.ensureInitialized();
  final components = IsometricComponents();
  final engine = Engine(
    init: components.init,
    update: components.update,
    render: (canvas, size) {}, // overridden when components are ready
    onDrawForeground: (canvas, size) {}, // overridden when components are ready
    title: 'AMULET',
    themeData: ThemeData(fontFamily: 'VT323-Regular'),
    backgroundColor: IsometricColors.Black,
    onError: components.onError,
    buildUI: (context)=> LoadingPage(),
    buildLoadingScreen: (context) => LoadingPage(),
  );

  components.engine = engine;
  components.connect();

  return Provider<IsometricComponents>(
    create: (context) => components,
    child: engine,
  );

}