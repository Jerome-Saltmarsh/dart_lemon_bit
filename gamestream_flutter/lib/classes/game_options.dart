import 'package:gamestream_flutter/library.dart';

class GameOptions {
   static final perks = Watch(false);
   static final inventory = Watch(false);
   static final items = Watch(false);
   static final item_damage = <int, int>{};

   static int getItemTypeDamage(int itemType, {bool ignoreEmpty = true}){
      if (itemType == ItemType.Empty && ignoreEmpty) return 0;
      return item_damage[itemType] ?? 0;
   }
}