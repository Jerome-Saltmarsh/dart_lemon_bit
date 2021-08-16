class Inventory {
  int rows;
  int columns;
  List<InventoryItem> items;

  Inventory(this.rows, this.columns, this.items);
}

extension InventoryExtensions on Inventory {
  int countItems(InventoryItemType type) {
    return items.where((element) => element.type == type).length;
  }

  int get handgunClips => countItems(InventoryItemType.HandgunClip);

  void remove(InventoryItemType type) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].type == type) {
        items.removeAt(i);
        return;
      }
    }
  }
}

class InventoryItem {
  int x;
  int y;
  InventoryItemType type;

  InventoryItem(this.x, this.y, this.type);
}

enum InventoryItemType {
  Handgun,
  HandgunClip,
  Shotgun,
  ShotgunClip,
  HealthPack,
}

extension ItemTypeExtensions on InventoryItemType {
  int get width {
    switch (this) {
      case InventoryItemType.HandgunClip:
        return 1;
      case InventoryItemType.Shotgun:
        return 2;
      default:
        return 1;
    }
  }

  int get height {
    switch (this) {
      case InventoryItemType.HandgunClip:
        return 1;
      default:
        return 1;
    }
  }
}
