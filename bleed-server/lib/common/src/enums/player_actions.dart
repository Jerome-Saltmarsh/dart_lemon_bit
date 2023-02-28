

class PlayerAction {
  static const None = 0;
  static const Purchase_Weapon = 1;
  static const Upgrade_Weapon = 2;

  static String getName(int playerAction) => <int, String> {
       None: "None",
       Purchase_Weapon: "Purchase",
       Upgrade_Weapon: "Upgrade",
  }[playerAction] ?? 'unknown player action: $playerAction';
}