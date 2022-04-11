import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:gamestream_flutter/modules/isometric/module.dart';
import 'package:lemon_engine/engine.dart';


class IsometricQueries {
  final IsometricModule state;

  final _screen = engine.screen;

  IsometricQueries(this.state);

  int get tileAtMouse => state.getTileAt(mouseWorldX, mouseWorldY);

  bool environmentObjectOnScreenScreen(EnvironmentObject environmentObject) {
    if (environmentObject.top > _screen.bottom) return false;
    if (environmentObject.right < _screen.left) return false;
    if (environmentObject.left > _screen.right) return false;
    if (environmentObject.bottom < _screen.top) return false;
    return true;
  }
}