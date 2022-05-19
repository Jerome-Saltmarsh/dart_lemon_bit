
import 'package:bleed_common/card_type.dart';
import 'package:lemon_watch/watch.dart';

class DeckCard {
   final CardType type;
   final cooldownRemaining = Watch(0);
   final cooldown = Watch(0);
   DeckCard(this.type);
}