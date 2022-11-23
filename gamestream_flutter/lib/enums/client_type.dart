
class ClientType {
  static const Index_Drag_Start = 0;
  static const Index_Hot_Keys = Index_Drag_Start + 100;
  static const Index_Inventory_Equipped = Index_Hot_Keys + 100;
  static const Index_Inventory = Index_Inventory_Equipped + 100;

  static const Drag_Start_None = Index_Drag_Start + 1;
  static const Drag_Start_Inventory_Unequipped = Drag_Start_None + 1;
  static const Drag_Start_Inventory_Equipped = Drag_Start_Inventory_Unequipped + 1;
  static const Drag_Start_HotKey_Unassigned = Drag_Start_Inventory_Equipped + 1;
  static const Drag_Start_HotKey_Assigned = Drag_Start_HotKey_Unassigned + 1;

  static const Hot_Key_1 = Index_Hot_Keys + 1;
  static const Hot_Key_2 = Hot_Key_1 + 1;
  static const Hot_Key_3 = Hot_Key_2 + 1;
  static const Hot_Key_4 = Hot_Key_3 + 1;
  static const Hot_Key_Q = Hot_Key_4 + 1;
  static const Hot_Key_E = Hot_Key_Q + 1;

  static const Inventory_Equipped = Hot_Key_Q + 1;
  static const Inventory_Equipped_Weapon = Inventory_Equipped + 1;
  static const Inventory_Equipped_Body = Inventory_Equipped + 2;
  static const Inventory_Equipped_Head = Inventory_Equipped + 3;
  static const Inventory_Equipped_Legs = Inventory_Equipped + 4;

  static const Hover_Target_None = 1000;
  static const Hover_Target_Inventory_Slot = Hover_Target_None + 1;
  static const Hover_Target_Player_Stats_Damage = Hover_Target_Inventory_Slot + 1;
  static const Hover_Target_Player_Stats_Health = Hover_Target_Player_Stats_Damage + 1;

  static String getHotKeyString(int hotKey) => const {
        Hot_Key_1: "1",
        Hot_Key_2: "2",
        Hot_Key_3: "3",
        Hot_Key_4: "4",
        Hot_Key_Q: "Q",
        Hot_Key_E: "E",
      }[hotKey] ?? "unknown-hotkey-$hotKey";
}