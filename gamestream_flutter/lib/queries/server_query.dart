

import 'package:gamestream_flutter/library.dart';

class ServerQuery {
  static bool playerCanAffordToBuy(int itemType) =>
    ItemType.getBuyPrice(itemType) <= ServerState.playerGold.value;
}