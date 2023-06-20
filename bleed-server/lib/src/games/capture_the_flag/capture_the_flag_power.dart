

import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_power_mode.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_power_type.dart';

class CaptureTheFlagPower {
  final CaptureTheFlagPowerType type;
  CaptureTheFlagPower(this.type);

  bool get isPositional => type.mode == CaptureTheFlagPowerMode.Positional;
  bool get isTargeted => type.mode == CaptureTheFlagPowerMode.Targeted;
  bool get isSelf => type.mode == CaptureTheFlagPowerMode.Self;
}

