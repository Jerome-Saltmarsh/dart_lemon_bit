import '../../src.dart';
import 'package:collection/collection.dart';



enum AmuletItem {
  Weapon_Sword_1_Common(
      label: 'Short Sword',
      levelMin: 1,
      levelMax: 5,
      type: ItemType.Weapon,
      subType: WeaponType.Shortsword,
      performDuration: WeaponDuration.Normal,
      range: WeaponRange.Melee_Long,
      damage: 3,
      quality: ItemQuality.Common,
      areaOfEffectDamage: 1,
  ),
  Weapon_Sword_1_Rare(
    label: "Sharpened Short Sword",
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    skillType: SkillType.Strike,
    performDuration: WeaponDuration.Normal,
    range: WeaponRange.Melee_Short,
    damage: 4,
    quality: ItemQuality.Rare,
  ),
  Weapon_Sword_1_Legendary(
    label: "Short Blade of Glen",
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Shortsword,
    skillType: SkillType.Mighty_Strike,
    performDuration: WeaponDuration.Fast,
    range: WeaponRange.Melee_Short,
    damage: 5,
    quality: ItemQuality.Legendary,
  ),
  Weapon_Staff_1_Of_Frost(
    label: 'Staff of Frost',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    skillType: SkillType.Frostball,
    performDuration: WeaponDuration.Slow,
    range: WeaponRange.Melee_Medium,
    damage: 2,
    quality: ItemQuality.Rare,
  ),
  Weapon_Staff_1_Of_Fire(
    label: 'Staff of Fire',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    skillType: SkillType.Fireball,
    performDuration: WeaponDuration.Slow,
    range: WeaponRange.Melee_Medium,
    damage: 3,
    quality: ItemQuality.Rare,
  ),
  Weapon_Staff_1_Legendary(
    label: 'Wooden Staff',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff,
    skillType: SkillType.Fireball,
    performDuration: WeaponDuration.Slow,
    range: WeaponRange.Melee_Medium,
    damage: 5,
    quality: ItemQuality.Legendary,
  ),
  Weapon_Bow_1_Common(
    label: 'Common Short Bow',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Split_Shot,
    performDuration: WeaponDuration.Normal,
    range: WeaponRange.Ranged_Short,
    damage: 2,
    quality: ItemQuality.Common,
  ),
  Weapon_Bow_1_Rare(
    label: 'Rare Short Bow',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Split_Shot,
    performDuration: WeaponDuration.Normal,
    range: WeaponRange.Ranged_Short,
    damage: 8,
    quality: ItemQuality.Rare,
  ),
  Weapon_Bow_1_Legendary(
    label: "Ligon's Bow",
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow,
    skillType: SkillType.Split_Shot,
    performDuration: WeaponDuration.Fast,
    range: WeaponRange.Ranged_Short,
    damage: 12,
    quality: ItemQuality.Legendary,
  ),
  Helm_Warrior_1_Leather_Cap_Common(
    label: 'Leather Cap',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Leather_Cap,
    skillType: SkillType.Heal,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
  ),
  Helm_Wizard_1_Pointed_Hat_Purple_Common(
    label: 'Crooked Hat',
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Heal,
    type: ItemType.Helm,
    subType: HelmType.Pointed_Hat_Purple,
    maxHealth: 2,
    quality: ItemQuality.Common,
    regenMagic: 1,
    masteryStaff: 2,
  ),
  Helm_Rogue_1_Hood_Common(
    label: 'Feather Cap',
    levelMin: 1,
    levelMax: 5,
    skillType: SkillType.Entangle,
    type: ItemType.Helm,
    subType: HelmType.Feather_Cap,
    maxHealth: 3,
    quality: ItemQuality.Common,
    masteryBow: 2,
  ),
  Helm_Warrior_2_Steel_Cap_Common(
    label: 'Steel Cap',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Steel_Cap,
    skillType: SkillType.Mighty_Strike,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    masterySword: 2,
  ),
  Helm_Wizard_2_Pointed_Hat_Black_Common(
    label: 'Pointed Hat',
    levelMin: 2,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Pointed_Hat_Black,
    skillType: SkillType.Ice_Arrow,
    maxMagic: 5,
    quality: ItemQuality.Common,
    regenMagic: 1,
    masteryStaff: 3,
  ),
  Helm_Rogue_2_Cape_Common(
    label: 'Cape',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Cape,
    skillType: SkillType.Split_Shot,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    masteryBow: 3,
  ),
  Helm_Warrior_3_Full_Helm_Common(
    label: 'Full Helm',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Full_Helm,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    masterySword: 3,
  ),
  Helm_Wizard_3_Circlet_Common(
    label: 'Circlet',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Cowl,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    masteryStaff: 3,
  ),
  Helm_Rogue_3_Veil_Common(
    label: 'Veil',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Helm,
    subType: HelmType.Cape,
    maxHealth: 5,
    quality: ItemQuality.Common,
    regenHealth: 1,
    masteryBow: 4,
  ),
  Armor_Neutral_1_Common_Tunic(
    label: 'Common',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Tunic,
    quality: ItemQuality.Common,
    maxHealth: 5,
    maxMagic: 5,
    skillType: SkillType.Heal,
    masterySword: 1,
    masteryBow: 1,
    masteryStaff: 1,
    masteryCaste: 1
  ),
  Armor_Warrior_1_Leather_Common(
    label: 'Leather',
    levelMin: 1,
    levelMax: 3,
    type: ItemType.Armor,
    subType: ArmorType.Leather,
    quality: ItemQuality.Common,
    maxHealth: 10,
    regenHealth: 1,
    skillType: SkillType.Mighty_Strike,
    masterySword: 3,
  ),
  Armor_Warrior_1_Leather_Rare(
    label: 'Leather',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Leather,
    quality: ItemQuality.Rare,
    maxHealth: 15,
    regenHealth: 1,
    skillType: SkillType.Mighty_Strike,
    masterySword: 3,
  ),
  Armor_Warrior_1_Leather_Legendary(
    label: 'Leather',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Leather,
    quality: ItemQuality.Legendary,
    maxHealth: 20,
    regenHealth: 2,
    skillType: SkillType.Mighty_Strike,
    masterySword: 3,
    healthSteal: 1,
  ),
  Armor_Warrior_2_Chainmail_Common(
    label: 'Chainmail',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Chainmail,
    quality: ItemQuality.Common,
    maxHealth: 20,
    regenHealth: 2,
    masterySword: 3,
    healthSteal: 1,
  ),
  Armor_Warrior_2_Chainmail_Rare(
    label: 'Chainmail',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Chainmail,
    quality: ItemQuality.Rare,
    maxHealth: 30,
    regenHealth: 2,
    masterySword: 3,
  ),
  Armor_Warrior_2_Chainmail_Legendary(
    label: 'Chainmail',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Chainmail,
    quality: ItemQuality.Legendary,
    maxHealth: 40,
    regenHealth: 3,
    masterySword: 3,
    healthSteal: 1,
    magicSteal: 1,
  ),
  Armor_Warrior_3_Platemail_Common(
    label: 'Platemail',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Platemail,
    quality: ItemQuality.Common,
    maxHealth: 30,
    regenHealth: 3,
    masterySword: 3,
  ),
  Armor_Warrior_3_Platemail_Rare(
    label: 'Platemail',
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Armor,
    subType: ArmorType.Platemail,
    quality: ItemQuality.Rare,
    maxHealth: 30,
    regenHealth: 3,
    masterySword: 3,
  ),
  Armor_Warrior_3_Platemail_Legendary(
    label: 'Platemail',
    levelMin: 5,
    levelMax: 10,
    type: ItemType.Armor,
    subType: ArmorType.Platemail,
    quality: ItemQuality.Legendary,
    maxHealth: 30,
    regenHealth: 3,
    masterySword: 3,
  ),
  Armor_Wizard_1_Robe_Common(
    label: 'Robe',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Robes,
    quality: ItemQuality.Common,
    maxHealth: 5,
    regenMagic: 1,
    maxMagic: 5,
    masteryStaff: 3,
    magicSteal: 1,
  ),
  Armor_Wizard_1_Robe_Rare(
    label: 'Robe',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Garb,
    quality: ItemQuality.Rare,
    maxHealth: 8,
    maxMagic: 10,
    masteryStaff: 3,
  ),
  Armor_Wizard_1_Robe_Legendary(
    label: 'Robe',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Attire,
    quality: ItemQuality.Legendary,
    maxHealth: 10,
    maxMagic: 15,
    masteryStaff: 3,
  ),
  Armor_Rogue_1_Cloak_Common(
    label: 'Cloak',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Cloak,
    quality: ItemQuality.Common,
    maxHealth: 7,
    masteryBow: 5,
  ),
  Armor_Rogue_1_Cloak_of_Frost(
    label: 'Cloak of Frost',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Cloak,
    quality: ItemQuality.Rare,
    maxHealth: 10,
    skillType: SkillType.Ice_Arrow,
    masteryBow: 5,
  ),
  Armor_Rogue_1_Cloak_of_Fire(
    label: 'Cloak of Fire',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Cloak,
    quality: ItemQuality.Rare,
    maxHealth: 10,
    skillType: SkillType.Fire_Arrow,
    masteryBow: 5,
  ),
  Armor_Rogue_1_Cloak_Legendary(
    label: 'Cloak',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Cloak,
    quality: ItemQuality.Legendary,
    maxHealth: 12,
    masteryBow: 5,
  ),
  Armor_Rogue_2_Mantle_Common(
    label: 'Mantle',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Mantle,
    quality: ItemQuality.Common,
    maxHealth: 9,
    masteryBow: 5,
  ),
  Armor_Rogue_2_Mantle_Rare(
    label: 'Mantle',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Mantle,
    quality: ItemQuality.Rare,
    maxHealth: 9,
    masteryBow: 5,
  ),
  Armor_Rogue_2_Mantle_Legendary(
    label: 'Mantle',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Mantle,
    quality: ItemQuality.Legendary,
    maxHealth: 9,
    masteryBow: 5,
  ),
  Armor_Rogue_3_Shroud_Common(
    label: 'Shroud',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Shroud,
    quality: ItemQuality.Common,
    maxHealth: 9,
    masteryBow: 5,
  ),
  Armor_Rogue_3_Shroud_Rare(
    label: 'Shroud',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Shroud,
    quality: ItemQuality.Rare,
    maxHealth: 9,
    masteryBow: 5,
  ),
  Armor_Rogue_3_Shroud_Legendary(
    label: 'Shroud',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Armor,
    subType: ArmorType.Shroud,
    quality: ItemQuality.Legendary,
    maxHealth: 9,
    masteryBow: 5,
  ),
  Shoes_Warrior_1_Leather_Boots_Common(
    label: 'Leather Boots',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Leather_Boots,
    quality: ItemQuality.Common,
    maxHealth: 5,
    agility: 2,
    masterySword: 5,
  ),
  Shoes_Wizard_1_Black_Slippers_Common(
    label: 'Black Slippers',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Black_Slippers,
    quality: ItemQuality.Common,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Teleport,
    masteryStaff: 5,
  ),
  Shoes_Rogue_1_Treads_Common(
    label: 'Treads',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Treads,
    quality: ItemQuality.Common,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Teleport,
    masteryBow: 5,
  ),
  Shoes_Warrior_2_Grieves_Common(
    label: 'Grieves',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Grieves,
    quality: ItemQuality.Common,
    maxHealth: 5,
    agility: 20,
    masterySword: 5,
  ),
  Shoes_Wizard_2_Footwraps_Common(
    label: 'Footwraps',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Footwraps,
    quality: ItemQuality.Common,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Teleport,
    masteryStaff: 5,
    masteryCaste: 3,
  ),
  Shoes_Rogue_2_Striders_Common(
    label: 'Striders',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Striders,
    quality: ItemQuality.Common,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Teleport,
    masteryBow: 5,
    agility: 8,
  ),
  Shoes_Warrior_3_Sabatons_Common(
    label: 'Sabatons',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Sabatons,
    quality: ItemQuality.Common,
    maxHealth: 5,
    agility: 3,
    masterySword: 5,
  ),
  Shoes_Wizard_3_Soles_Common(
    label: 'Soles',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Soles,
    quality: ItemQuality.Common,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Teleport,
    masteryStaff: 5,
  ),
  Shoes_Rogue_3_Satin_Boots_Common(
    label: 'Satin_Boots',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Shoes,
    subType: ShoeType.Satin_Boots,
    quality: ItemQuality.Common,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Teleport,
    masteryBow: 3,
  ),
  Consumable_Potion_Magic(
    label: 'a common tonic',
    type: ItemType.Consumable,
    subType: ConsumableType.Potion_Blue,
    levelMin: 0,
    levelMax: 99,
    quality: ItemQuality.Common,
    maxMagic: 20,
  ),
  Consumable_Potion_Health(
    label: 'a common tonic',
    type: ItemType.Consumable,
    subType: ConsumableType.Potion_Red,
    levelMin: 0,
    levelMax: 99,
    quality: ItemQuality.Common,
    health: 20,
  );

  /// the minimum level of a fiend that can drop this item
  final int levelMin;
  /// the maximum level of fiends that can drop this item
  final int levelMax;
  /// see item_type.dart in commons
  final int type;
  final int subType;
  final SkillType? skillType;
  final int? damage;
  final double? range;
  final int? performDuration;
  final int? health;
  final ItemQuality quality;
  final String label;
  final int? areaOfEffectDamage;
  final int? maxHealth;
  final int? maxMagic;
  final int? regenMagic;
  final int? regenHealth;
  final int? agility;
  final int masterySword;
  final int masteryBow;
  final int masteryStaff;
  final int masteryCaste;
  final int magicSteal;
  final int healthSteal;

  const AmuletItem({
    required this.type,
    required this.subType,
    required this.levelMin,
    required this.quality,
    required this.label,
    this.levelMax = 99,
    this.maxHealth = 0,
    this.maxMagic,
    this.regenMagic,
    this.regenHealth,
    this.skillType,
    this.damage,
    this.range,
    this.performDuration,
    this.health,
    this.agility,
    this.areaOfEffectDamage,
    this.masteryBow = 0,
    this.masteryCaste = 0,
    this.masteryStaff = 0,
    this.masterySword = 0,
    this.magicSteal = 0,
    this.healthSteal = 0,
  });

  bool get isWeapon => type == ItemType.Weapon;

  bool get isWeaponSword => isWeapon && WeaponType.isSword(subType);

  bool get isWeaponStaff => isWeapon && WeaponType.isStaff(subType);

  bool get isWeaponBow => isWeapon && WeaponType.isBow(subType);

  bool get isShoes => type == ItemType.Shoes;

  bool get isHelm => type == ItemType.Helm;

  bool get isConsumable => type == ItemType.Consumable;

  bool get isArmor => type == ItemType.Armor;

  int get quantify {
    var total = 0;
    total += damage ?? 0;
    total += skillType?.quantify ?? 0;
    total += masterySword;
    total += masteryStaff;
    total += masteryBow;
    total += masteryCaste;
    total += maxHealth ?? 0;
    total += maxMagic ?? 0;
    const pointsPerRegen = 5;
    total += (regenHealth ?? 0) * pointsPerRegen;
    total += (regenMagic ?? 0) * pointsPerRegen;
    return total;
  }

  static AmuletItem? findByName(String name) =>
      values.firstWhereOrNull((element) => element.name == name);

  static final Consumables = values
      .where((element) => element.isConsumable)
      .toList(growable: false);

  static Iterable<AmuletItem> find({
    required ItemQuality itemQuality,
    required int level,
  }) =>
      values.where((amuletItem) =>
        amuletItem.quality == itemQuality &&
        amuletItem.levelMin <= level &&
        amuletItem.levelMax > level
      );

  static final sortedValues = (){
    final vals = List.of(values);
    vals.sort(sortByQuantify);
    return vals;
  }();

  static int sortByQuantify(AmuletItem a, AmuletItem b){
    final aQuantify = a.quantify;
    final bQuantify = b.quantify;
    if (aQuantify < bQuantify){
      return -1;
    }
    if (aQuantify > bQuantify){
      return 1;
    }
    return 0;
  }

  void validate() {
    if (isWeapon){
      if ((performDuration == null)) {
        throw Exception('$this performDuration of weapon cannot be null');
      }
      if ((performDuration! <= 0)) {
        throw Exception('$this performDuration of weapon must be greater than 0');
      }
      if (damage == null || damage! <= 0){
        throw Exception('$this.damage cannot cannot be null or 0');
      }
      if (range == null || range! <= 0){
        throw Exception('$this.range cannot cannot be null or 0');
      }
    } else {
      if ((performDuration ?? 0) > 0 && !this.isWeapon) {
        throw Exception('$this performDuration cannot be greater than 0 for non weapon');
      }
    }

  }
}

enum CasteType {
  Bow,
  Sword,
  Staff,
  Caste,
}

enum ItemQuality {
  Legendary,
  Rare,
  Unique,
  Common,
}

enum WeaponClass {
  Sword,
  Staff,
  Bow;

  static WeaponClass fromWeaponType(int weaponType){
    if (WeaponType.isBow(weaponType)){
      return WeaponClass.Bow;
    }
    if (WeaponType.isSword(weaponType)){
      return WeaponClass.Sword;
    }
    if (WeaponType.isStaff(weaponType)){
      return WeaponClass.Staff;
    }
    throw Exception(
        'amuletPlayer.getWeaponTypeWeaponClass(weaponType: $weaponType)'
    );
  }
}

class WeaponRange {
  static const Melee_Short = 50.0;
  static const Melee_Medium = 75.0;
  static const Melee_Long = 80.0;
  static const Ranged_Short = 150.0;
  static const Ranged_Medium = 175.0;
  static const Ranged_Long = 200.0;
}

class WeaponDuration {
  static const Very_Fast = 20;
  static const Fast = 25;
  static const Normal = 30;
  static const Slow = 35;
  static const Very_Slow = 40;
}

enum AttackSpeed {
  Very_Slow(40),
  Slow(35),
  Normal(30),
  Fast(25),
  Very_Fast(20);

  final int duration;

  const AttackSpeed(this.duration);

  static AttackSpeed fromDuration(int duration){
      for (final value in values){
        if (duration >= value.duration) {
          return value;
        }
      }
      return AttackSpeed.values.last;
  }

}
