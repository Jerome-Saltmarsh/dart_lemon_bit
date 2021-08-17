import 'package:bleed_client/enums/InventoryItemType.dart';

class InventoryItem {
  int row;
  int column;
  InventoryItemType type;
  InventoryItem(this.row, this.column, this.type);
}