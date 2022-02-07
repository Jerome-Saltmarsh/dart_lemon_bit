import 'WeaponType.dart';

enum SlotType {
  Empty,
  Silver_Pendant,
  Frogs_Amulet,
  Brace,
  Dagger,
  Sword_Wooden,
  Sword_Short,
  Sword_Long,
  Bow_Wooden,
  Bow_Green,
  Bow_Gold,
  Staff_Wooden,
  Staff_Blue,
  Staff_Golden,
  Leather_Cap,
  Steel_Helmet,
  Handgun,
  Shotgun,
  SniperRifle,
  AssaultRifle,
  Spell_Tome_Fireball,
  Armour_Standard,
}

final List<SlotType> slotTypesAll = SlotType.values;
final _SlotTypes slotTypes = _SlotTypes();

class _SlotTypes {

  final List<SlotType> all = SlotType.values;

  final List<SlotType> weapons = [
    SlotType.Sword_Short,
    SlotType.Bow_Wooden,
    SlotType.Sword_Wooden,
  ];

  final List<SlotType> armour = [
    SlotType.Armour_Standard,
  ];

  final List<SlotType> helms = [
    SlotType.Steel_Helmet,
    SlotType.Leather_Cap,
  ];

  final List<SlotType> items = [
    SlotType.Silver_Pendant,
    SlotType.Frogs_Amulet,
  ];
}

extension SlotTypeProperties on SlotType {
  bool get isEmpty => this == SlotType.Empty;
  bool get isWeapon => slotTypes.weapons.contains(this);
  bool get isArmour => slotTypes.armour.contains(this);
  bool get isHelm => slotTypes.helms.contains(this);
  bool get isItem => slotTypes.items.contains(this);

  int get damage {
    return slotWeaponDamage[this] ?? 0;
  }
}

const Map<SlotType, int> slotWeaponDamage = {
  SlotType.Sword_Wooden: 1,
  SlotType.Sword_Short: 2,
  SlotType.Sword_Long: 5,
  SlotType.Bow_Wooden: 1,
  SlotType.Bow_Green: 2,
  SlotType.Bow_Gold: 5,
  SlotType.Staff_Wooden: 1,
  SlotType.Staff_Blue: 2,
  SlotType.Staff_Golden: 5,
};