
import '../capture_the_flag/capture_the_flag_power_mode.dart';

enum PowerType {
  Blink(CaptureTheFlagPowerMode.Positional),
  Slow(CaptureTheFlagPowerMode.Targeted_Enemy),
  Heal(CaptureTheFlagPowerMode.Targeted_Ally);

  final CaptureTheFlagPowerMode mode;
  const PowerType(this.mode);
}