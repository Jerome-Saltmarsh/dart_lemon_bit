import 'Vector2.dart';

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

  bool acquire(InventoryItemType type) {
    if (type.width == 1 && type.height == 1) {
      Slot? emptySlot = findEmptySingleSlot();
      if (emptySlot == null) return false;
      items.add(InventoryItem(emptySlot.row, emptySlot.column, type));
      return true;
    }
    return false;
  }

  List<List<InventoryItem?>> getSlots() {
    List<List<InventoryItem?>> grid = [];

    for(int row = 0; row < rows; row++){
      List<InventoryItem?> row = List.filled(columns, null);
      grid.add(row);
    }

    for (InventoryItem item in items) {
      grid[item.row][item.column] = item;
    }
    return grid;
  }

  Slot? findEmptySingleSlot() {
    List<List<InventoryItem?>> slots = getSlots();
    for (int row = 0; row < slots.length; row++) {
      for (int column = 0; column < slots[0].length; column++) {
        if (slots[row][column] == null) {
          return Slot(row, column);
        }
      }
    }
    return null;
  }
}

class InventoryItem {
  int row;
  int column;
  InventoryItemType type;

  InventoryItem(this.row, this.column, this.type);
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
