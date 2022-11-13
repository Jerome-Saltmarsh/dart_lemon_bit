
class ClientType {
  static const Index_Drag_Start = 0;

  static const Drag_Start_None = Index_Drag_Start + 1;
  static const Drag_Start_Inventory_Unequipped = Drag_Start_None + 1;
  static const Drag_Start_Inventory_Equipped = Drag_Start_Inventory_Unequipped + 1;
  static const Drag_Start_HotKey_Unassigned = Drag_Start_Inventory_Equipped + 1;
  static const Drag_Start_HotKey_Assigned = Drag_Start_HotKey_Unassigned + 1;
}