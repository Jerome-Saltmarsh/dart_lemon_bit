import 'package:gamestream_flutter/library.dart';

class CaptureTheFlagPower {
   final type = Watch(PowerType.Blink);
   final cooldown = Watch(0);
   final activated = Watch(false);
   final coolingDown = Watch(false);
   final level = Watch(0);

   late final cooldownRemaining = Watch(0, onChanged: onChangedCooldownRemaining);

   void onChangedCooldownRemaining(int value){
      coolingDown.value = value > 0;
   }

   double get cooldownPercentage => (cooldown.value - cooldownRemaining.value) / cooldown.value;
}