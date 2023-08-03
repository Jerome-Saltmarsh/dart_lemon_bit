import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:provider/provider.dart';

class IsometricApp extends StatelessWidget  {

  final Engine engine;
  final Isometric isometric;

  IsometricApp(this.isometric, this.engine);

  @override
  Widget build(BuildContext context) => Provider<Isometric>(
    create: (context) => isometric,
    child: engine,
  );
}

