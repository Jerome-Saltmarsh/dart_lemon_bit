

import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules.dart';

class IsometricProperties {
  bool get dayTime => modules.isometric.state.ambient.value.index == Shade.Bright.index;
}