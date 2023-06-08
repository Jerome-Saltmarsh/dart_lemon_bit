
import 'package:gamestream_flutter/gamestream/isometric/isometric_position.dart';
import 'package:gamestream_flutter/isometric/render/render_circle.dart';

import '../../library.dart';

void renderOutline(IsometricPosition value){
  renderCircle32(value.renderX, value.renderY);
}