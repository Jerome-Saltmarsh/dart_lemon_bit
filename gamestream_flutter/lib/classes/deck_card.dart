
import 'package:bleed_common/card_type.dart';
import 'package:lemon_watch/watch.dart';

class DeckCard {
   final CardType type;
   final level = Watch(0);
   final cooldownRemaining = Watch(0);
   final cooldown = Watch(0);
   final selectable = Watch(true);

   CardGenre get genre => getCardTypeGenre(type);
   String get name => getCardTypeName(type);
   double get cooldownPercentage {
      if (cooldownRemaining.value == 0) return 0;
      return cooldownRemaining.value / cooldown.value;
   }

   DeckCard(this.type, int level){
      cooldownRemaining.onChanged((int remaining) {
          selectable.value = remaining == 0;
      });
      this.level.value = level;
   }
}