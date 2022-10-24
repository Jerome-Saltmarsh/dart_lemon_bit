
import 'package:gamestream_flutter/isometric/render/render_circle.dart';

import '../../library.dart';

void renderOutline(Vector3 value){
  renderCircle32(value.renderX, value.renderY);
}