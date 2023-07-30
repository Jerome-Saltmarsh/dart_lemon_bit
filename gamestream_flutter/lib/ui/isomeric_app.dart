import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:provider/provider.dart';

class IsometricApp extends StatefulWidget  {

  final Isometric isometric;

  const IsometricApp(this.isometric);

  @override
  State<StatefulWidget> createState() => IsometricAppState();
}

class IsometricAppState extends State<IsometricApp> {

  @override
  Widget build(BuildContext context) => Provider<Isometric>(
    create: (context) => widget.isometric,
    child: widget.isometric.build(context),
  );
}
