

class PlayerAction {
  static const None = 0;
  static const Purchase = 1;
  static const Upgrade = 2;
  static const Equip = 3;

  static String getName(int playerAction) => <int, String> {
       None: "None",
       Purchase: "Purchase",
       Upgrade: "Upgrade",
       Equip: "Equip",
  }[playerAction] ?? 'unknown player action: $playerAction';
}