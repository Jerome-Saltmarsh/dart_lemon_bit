
class PerkTypes {
  static const Extra_Gold_1 = 0;
  static const Extra_Gold_2 = 1;
  static const Extra_Gold_3 = 2;
  static const Grenade_Capacity_1 = 3;
  static const Grenade_Capacity_2 = 4;
  static const Grenade_Capacity_3 = 5;

  static const Values = [
    Extra_Gold_1,
    Extra_Gold_2,
    Extra_Gold_3,
    Grenade_Capacity_1,
    Grenade_Capacity_2,
    Grenade_Capacity_3,
  ];

  static int getCost(int perkType) => const {
    Extra_Gold_1: 10,
    Extra_Gold_2: 10,
    Extra_Gold_3: 10,
    Grenade_Capacity_1: 50,
    Grenade_Capacity_2: 150,
    Grenade_Capacity_3: 200,
  }[perkType] ?? 0;
}
