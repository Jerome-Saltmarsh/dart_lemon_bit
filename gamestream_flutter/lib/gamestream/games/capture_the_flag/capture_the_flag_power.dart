import 'package:gamestream_flutter/library.dart';
import 'package:bleed_common/src/capture_the_flag/capture_the_flag_power_type.dart';

class CaptureTheFlagPower {
   final type = Watch(CaptureTheFlagPowerType.Blink);
   final cooldownRemaining = Watch(0);
   final cooldown = Watch(0);
}