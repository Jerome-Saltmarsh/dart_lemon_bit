import 'package:gamestream_flutter/library.dart';
import 'package:bleed_common/src/capture_the_flag/capture_the_flag_power_type.dart';

class CaptureTheFlagPower {
   final type = Watch(CaptureTheFlagPowerType.Blink);
   final cooldown = Watch(0);
   final activated = Watch(false);
   final coolingDown = Watch(false);

   late final cooldownRemaining = Watch(0, onChanged: onChangedCooldownRemaining);

   void onChangedCooldownRemaining(int value){
      coolingDown.value = value > 0;
   }

   double get cooldownPercentage => (cooldown.value - cooldownRemaining.value) / cooldown.value;
}