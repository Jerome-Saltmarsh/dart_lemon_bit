
import 'package:bleed_common/card_type.dart';
import 'package:lemon_watch/watch.dart';

class DeckCard {
   final CardType type;
   final cooldown = Watch(0);
   final cooldownTotal = Watch(0);
   DeckCard(this.type);
}