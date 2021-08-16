import 'package:bleed_client/enums/InventoryItemType.dart';

class InventoryItem {
  int x;
  int y;
  InventoryItemType type;
  InventoryItem(this.x, this.y, this.type);
}