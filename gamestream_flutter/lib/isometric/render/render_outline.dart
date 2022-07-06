
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/render/render_circle.dart';

void renderOutline(Vector3 value){
  renderCircle32(value.renderX, value.renderY);
}