

import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_power_mode.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_power_type.dart';

class CaptureTheFlagPower {

  var cooldownRemaining = 0;

  final int cooldown;
  final double range;
  final CaptureTheFlagPowerType type;

  CaptureTheFlagPower({
    required this.type,
    required this.range,
    required this.cooldown,
  });

  bool get isPositional => type.mode == CaptureTheFlagPowerMode.Positional;

  bool get isTargeted => type.mode == CaptureTheFlagPowerMode.Targeted;

  bool get isSelf => type.mode == CaptureTheFlagPowerMode.Self;

  bool get ready => cooldownRemaining <= 0;

  void update(){
     if (ready) return;
     cooldownRemaining--;
  }

  void activated(){
    cooldownRemaining = cooldown;
  }

}

