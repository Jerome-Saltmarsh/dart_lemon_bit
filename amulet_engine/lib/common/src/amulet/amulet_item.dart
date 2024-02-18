import '../../src.dart';
import 'package:collection/collection.dart';


enum AmuletItem {
  Weapon_Sword_Short(
      label: 'Short Sword',
      levelMin: 1,
      levelMax: 5,
      type: ItemType.Weapon,
      subType: WeaponType.Sword_Short,
      attackSpeed: AttackSpeed.Very_Fast,
      range: WeaponRange.Very_Short,
      areaDamage: AreaDamage.Very_Small,
      damage: 3,
      quality: ItemQuality.Common,
      criticalHitPoints: 2,
  ),
  Weapon_Sword_Broad(
      label: 'Broad Sword',
      levelMin: 1,
      levelMax: 5,
      type: ItemType.Weapon,
      subType: WeaponType.Sword_Broad,
      attackSpeed: AttackSpeed.Fast,
      range: WeaponRange.Short,
      areaDamage: AreaDamage.Small,
      damage: 3,
      quality: ItemQuality.Common,
      criticalHitPoints: 2,
  ),
  Weapon_Sword_Long(
      label: 'Long Sword',
      levelMin: 1,
      levelMax: 5,
      type: ItemType.Weapon,
      subType: WeaponType.Sword_Long,
      attackSpeed: AttackSpeed.Slow,
      range: WeaponRange.Long,
      areaDamage: AreaDamage.Large,
      damage: 5,
      quality: ItemQuality.Common,
      criticalHitPoints: 5,
  ),
  Weapon_Sword_Giant(
      label: 'Claymore',
      levelMin: 1,
      levelMax: 5,
      type: ItemType.Weapon,
      subType: WeaponType.Sword_Giant,
      attackSpeed: AttackSpeed.Very_Slow,
      range: WeaponRange.Very_Long,
      areaDamage: AreaDamage.Very_Large,
      damage: 8,
      quality: ItemQuality.Common,
      criticalHitPoints: 5,
  ),
  Weapon_Bow_Short(
    label: 'Short Bow',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow_Short,
    skillType: SkillType.Split_Shot,
    attackSpeed: AttackSpeed.Fast,
    range: WeaponRange.Very_Short,
    damage: 2,
    quality: ItemQuality.Common,
  ),
  Weapon_Bow_Reflex(
    label: 'Reflex Bow',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow_Reflex,
    skillType: SkillType.Split_Shot,
    attackSpeed: AttackSpeed.Fast,
    range: WeaponRange.Short,
    damage: 5,
    quality: ItemQuality.Common,
  ),
  Weapon_Bow_Composite(
    label: 'Composite Bow',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow_Composite,
    skillType: SkillType.Split_Shot,
    attackSpeed: AttackSpeed.Slow,
    range: WeaponRange.Long,
    damage: 6,
    quality: ItemQuality.Common,
  ),
  Weapon_Bow_Long(
    label: 'Long Bow',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Bow_Long,
    skillType: SkillType.Split_Shot,
    attackSpeed: AttackSpeed.Very_Slow,
    range: WeaponRange.Very_Long,
    damage: 10,
    quality: ItemQuality.Common,
  ),
  Weapon_Staff_Wand(
    label: 'Wand',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff_Wand,
    skillType: SkillType.Fireball,
    attackSpeed: AttackSpeed.Very_Fast,
    range: WeaponRange.Very_Short,
    damage: 5,
    quality: ItemQuality.Common,
    criticalHitPoints: 0,
  ),
  Weapon_Staff_Globe(
    label: 'Globe',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff_Globe,
    skillType: SkillType.Fireball,
    attackSpeed: AttackSpeed.Fast,
    range: WeaponRange.Short,
    damage: 5,
    quality: ItemQuality.Common,
    criticalHitPoints: 0,
  ),
  Weapon_Staff_Scepter(
    label: 'Scepter',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff_Scepter,
    skillType: SkillType.Fireball,
    attackSpeed: AttackSpeed.Slow,
    range: WeaponRange.Long,
    damage: 5,
    quality: ItemQuality.Common,
    criticalHitPoints: 0,
  ),
  Weapon_Staff_Long(
    label: 'Staff',
    levelMin: 1,
    levelMax: 5,
    type: ItemType.Weapon,
    subType: WeaponType.Staff_Long,
    skillType: SkillType.Fireball,
    attackSpeed: AttackSpeed.Very_Slow,
    range: WeaponRange.Very_Long,
    damage: 5,
    quality: ItemQuality.Common,
    criticalHitPoints: 0,
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
  final WeaponRange? range;
  final AttackSpeed? attackSpeed;
  final int? health;
  final ItemQuality quality;
  final String label;
  final AreaDamage? areaDamage;
  final int criticalHitPoints;
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
    this.attackSpeed,
    this.health,
    this.agility,
    this.areaDamage,
    this.masteryBow = 0,
    this.masteryCaste = 0,
    this.masteryStaff = 0,
    this.masterySword = 0,
    this.magicSteal = 0,
    this.healthSteal = 0,
    this.criticalHitPoints = 0,
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
    total += criticalHitPoints;
    total += areaDamage?.quantify ?? 0;
    total += range?.quantify ?? 0;
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
      if ((attackSpeed == null)) {
        throw Exception('$this performDuration of weapon cannot be null');
      }
      if (damage == null || damage! <= 0){
        throw Exception('$this.damage cannot cannot be null or 0');
      }
      if (range == null){
        throw Exception('$this.range cannot cannot be null');
      }
    } else {
      // if ((performDuration ?? 0) > 0 && !this.isWeapon) {
      //   throw Exception('$this performDuration cannot be greater than 0 for non weapon');
      // }
    }

  }
}

enum CasteType {
  Bow,
  Sword,
  Staff,
  Caste,
  Melee,
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

enum WeaponRange {
  Very_Short(melee: 50, ranged: 150),
  Short(melee: 70, ranged: 175,),
  Long(melee: 90, ranged: 200),
  Very_Long(melee: 110, ranged: 2225);

  final double melee;
  final double ranged;
  const WeaponRange({required this.melee, required this.ranged});

  int get quantify => (index * 4).toInt();
}

enum AreaDamage {
  Very_Small(value: 0.25),
  Small(value: 0.50),
  Large(value: 0.75),
  Very_Large(value: 1.0);

  final double value;

  const AreaDamage({required this.value});

  static AreaDamage from(double value){
     for (final areaDamage in values){
       if (areaDamage.value > value) continue;
       return areaDamage;
     }
     return values.last;
  }

  int get quantify {
    return (this.value * 6).toInt();
  }
}

enum AttackSpeed {
  Very_Slow(duration: 48),
  Slow(duration: 40),
  Fast(duration: 32),
  Very_Fast(duration: 24);

  final int duration;

  const AttackSpeed({required this.duration});

  static AttackSpeed fromDuration(int duration){
      for (final value in values){
        if (duration >= value.duration) {
          return value;
        }
      }
      return AttackSpeed.values.last;
  }

}
