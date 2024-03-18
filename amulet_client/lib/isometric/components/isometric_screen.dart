
import 'package:amulet_client/isometric/components/isometric_component.dart';
import 'package:amulet_client/isometric/classes/position.dart';

class IsometricScreen with IsometricComponent  {

  bool contains(Position position) {
    const Pad_Distance = 75.0;
    final rx = position.renderX;
    final engine = this.engine;

    if (rx < engine.Screen_Left - Pad_Distance || rx > engine.Screen_Right + Pad_Distance)
      return false;

    final ry = position.renderY;
    return ry > engine.Screen_Top - Pad_Distance && ry < engine.Screen_Bottom + Pad_Distance;
  }
}