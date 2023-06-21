
import 'capture_the_flag_power_mode.dart';

enum CaptureTheFlagPowerType {
  Blink(CaptureTheFlagPowerMode.Positional),
  Slow(CaptureTheFlagPowerMode.Targeted),
  Heal(CaptureTheFlagPowerMode.Targeted_Ally);

  final CaptureTheFlagPowerMode mode;
  const CaptureTheFlagPowerType(this.mode);
}