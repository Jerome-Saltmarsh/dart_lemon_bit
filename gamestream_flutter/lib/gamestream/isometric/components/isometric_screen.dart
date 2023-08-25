
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:gamestream_flutter/packages/lemon_components.dart';

class IsometricScreen with IsometricComponent implements Updatable  {

  bool contains(Position position) {
    const Pad_Distance = 75.0;
    final rx = position.renderX;

    if (rx < engine.Screen_Left - Pad_Distance || rx > engine.Screen_Right + Pad_Distance)
      return false;

    final ry = position.renderY;
    return ry > engine.Screen_Top - Pad_Distance && ry < engine.Screen_Bottom + Pad_Distance;
  }

  @override
  void onComponentUpdate() {
    // TODO: implement update
  }
}