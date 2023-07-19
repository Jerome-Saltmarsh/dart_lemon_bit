
import 'power_mode.dart';

enum PowerType {
  Blink(PowerMode.Positional),
  Slow(PowerMode.Targeted_Enemy),
  Heal(PowerMode.Targeted_Ally);

  final PowerMode mode;
  const PowerType(this.mode);
}