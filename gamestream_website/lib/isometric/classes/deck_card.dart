
import 'package:bleed_common/card_type.dart';
import 'package:lemon_watch/watch.dart';

class DeckCard {
   final CardType type;
   final int level;
   final cooldownRemaining = Watch(0);
   final cooldown = Watch(0);
   final selectable = Watch(true);

   CardGenre get genre => getCardTypeGenre(type);
   String get name => getCardTypeName(type);
   double get cooldownPercentage {
      if (cooldownRemaining.value == 0) return 0;
      return cooldownRemaining.value / cooldown.value;
   }

   DeckCard(this.type, this.level){
      cooldownRemaining.onChanged((int remaining) {
          selectable.value = remaining == 0;
      });
   }
}