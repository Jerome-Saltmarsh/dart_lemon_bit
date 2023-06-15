
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:gamestream_flutter/isometric/render/render_circle.dart';

void renderOutline(IsometricPosition value){
  renderCircle32(value.renderX, value.renderY);
}