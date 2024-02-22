import '../../src.dart';
import 'package:collection/collection.dart';


enum AmuletItem {
  Weapon_Sword_Short(
      label: 'Short Sword',
      level: 1,
      slotType: SlotType.Weapon,
      subType: WeaponType.Sword_Short,
      attackSpeed: AttackSpeed.Very_Fast,
      range: WeaponRange.Very_Short,
      areaDamage: AreaDamage.Very_Small,
      damage: 3,
      
      criticalHitPoints: 0,
  ),
  Weapon_Sword_Broad(
      label: 'Broad Sword',
      level: 2,
      slotType: SlotType.Weapon,
      subType: WeaponType.Sword_Broad,
      attackSpeed: AttackSpeed.Fast,
      range: WeaponRange.Short,
      areaDamage: AreaDamage.Small,
      damage: 4,
      
      criticalHitPoints: 0,
  ),
  Weapon_Sword_Long(
      label: 'Long Sword',
      level: 3,
      slotType: SlotType.Weapon,
      subType: WeaponType.Sword_Long,
      attackSpeed: AttackSpeed.Slow,
      range: WeaponRange.Long,
      areaDamage: AreaDamage.Large,
      damage: 5,
      
      criticalHitPoints: 0,
  ),
  Weapon_Sword_Giant(
      label: 'Giant Sword',
      level: 4,
      slotType: SlotType.Weapon,
      subType: WeaponType.Sword_Giant,
      attackSpeed: AttackSpeed.Very_Slow,
      range: WeaponRange.Very_Long,
      areaDamage: AreaDamage.Very_Large,
      damage: 6,
      
      criticalHitPoints: 0,
  ),
  Weapon_Bow_Short(
    label: 'Short Bow',
    level: 1,
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Short,
    skillType: SkillType.Split_Shot,
    attackSpeed: AttackSpeed.Fast,
    range: WeaponRange.Very_Short,
    damage: 2,
    
  ),
  Weapon_Bow_Reflex(
    label: 'Reflex Bow',
    level: 2,
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Reflex,
    skillType: SkillType.Split_Shot,
    attackSpeed: AttackSpeed.Fast,
    range: WeaponRange.Short,
    damage: 3,
  ),
  Weapon_Bow_Composite(
    label: 'Composite Bow',
    level: 3,
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Composite,
    skillType: SkillType.Split_Shot,
    attackSpeed: AttackSpeed.Slow,
    range: WeaponRange.Long,
    damage: 4,
  ),
  Weapon_Bow_Long(
    label: 'Long Bow',
    level: 4,
    slotType: SlotType.Weapon,
    subType: WeaponType.Bow_Long,
    skillType: SkillType.Split_Shot,
    attackSpeed: AttackSpeed.Very_Slow,
    range: WeaponRange.Very_Long,
    damage: 5,
  ),
  Weapon_Staff_Wand(
    label: 'Wand',
    level: 1,
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Wand,
    skillType: SkillType.Fireball,
    attackSpeed: AttackSpeed.Very_Fast,
    range: WeaponRange.Very_Short,
    damage: 1,
    criticalHitPoints: 0,
  ),
  Weapon_Staff_Globe(
    label: 'Globe',
    level: 2,
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Globe,
    skillType: SkillType.Fireball,
    attackSpeed: AttackSpeed.Fast,
    range: WeaponRange.Short,
    damage: 2,
    criticalHitPoints: 0,
  ),
  Weapon_Staff_Scepter(
    label: 'Scepter',
    level: 3,
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Scepter,
    skillType: SkillType.Fireball,
    attackSpeed: AttackSpeed.Slow,
    range: WeaponRange.Long,
    damage: 3,
    criticalHitPoints: 0,
  ),
  Weapon_Staff_Long(
    label: 'Staff',
    level: 4,
    slotType: SlotType.Weapon,
    subType: WeaponType.Staff_Long,
    skillType: SkillType.Fireball,
    attackSpeed: AttackSpeed.Very_Slow,
    range: WeaponRange.Very_Long,
    damage: 5,
    criticalHitPoints: 0,
  ),
  Helm_Leather_Cap(
    label: 'Leather Cap',
    level: 1,
    slotType: SlotType.Helm,
    subType: HelmType.Leather_Cap,
    skillType: SkillType.Heal,
    maxHealth: 5,
    masterySword: 1,
    regenHealth: 1,
  ),
  Helm_Steel_Cap(
    label: 'Steel Cap',
    level: 2,
    slotType: SlotType.Helm,
    subType: HelmType.Steel_Cap,
    skillType: SkillType.Mighty_Strike,
    maxHealth: 8,
    masterySword: 2,
    regenHealth: 1,
  ),
  Helm_Full(
    label: 'Full Helm',
    level: 3,
    slotType: SlotType.Helm,
    subType: HelmType.Full_Helm,
    maxHealth: 11,
    masterySword: 3,
    regenHealth: 1,
  ),
  Helm_Crooked_Hat(
    label: 'Crooked Hat',
    level: 1,
    skillType: SkillType.Heal,
    slotType: SlotType.Helm,
    subType: HelmType.Pointed_Hat_Purple,
    maxHealth: 1,
    maxMagic: 3,
    regenMagic: 1,
    masteryStaff: 2,
  ),
  Helm_Pointed_Hat(
    label: 'Pointed Hat',
    level: 2,
    slotType: SlotType.Helm,
    subType: HelmType.Pointed_Hat_Black,
    maxHealth: 2,
    maxMagic: 5,
    regenMagic: 1,
    masteryStaff: 4,
  ),
  Helm_Cowl(
    label: 'Cowl',
    level: 3,
    slotType: SlotType.Helm,
    subType: HelmType.Cowl,
    maxHealth: 2,
    maxMagic: 7,
    regenMagic: 1,
    masteryStaff: 6,
  ),
  Helm_Feathered_Cap(
    label: 'Feather Cap',
    level: 1,
    skillType: SkillType.Ice_Arrow,
    slotType: SlotType.Helm,
    subType: HelmType.Feather_Cap,
    maxHealth: 3,
    masteryBow: 2,
    agility: 2,
  ),
  Helm_Cape(
    label: 'Cape',
    level: 2,
    slotType: SlotType.Helm,
    subType: HelmType.Cape,
    skillType: SkillType.Split_Shot,
    maxHealth: 4,
    maxMagic: 2,
    masteryBow: 4,
    agility: 3,
  ),
  Helm_Veil(
    label: 'Veil',
    level: 3,
    slotType: SlotType.Helm,
    subType: HelmType.Cape,
    maxHealth: 4,
    maxMagic: 2,
    masteryBow: 6,
    agility: 5,
  ),
  Armor_Tunic(
    label: 'Tunic',
    level: 1,
    slotType: SlotType.Armor,
    subType: ArmorType.Tunic,
    maxHealth: 5,
    maxMagic: 5,
    skillType: SkillType.Heal,
    masterySword: 1,
    masteryBow: 1,
    masteryStaff: 1,
    masteryCaste: 1,
    regenHealth: 1,
  ),
  Armor_Leather(
    label: 'Leather',
    level: 1,
    slotType: SlotType.Armor,
    subType: ArmorType.Leather,
    maxHealth: 10,
    regenHealth: 1,
    masterySword: 3,
    skillType: SkillType.Mighty_Strike,
  ),
  Armor_Chainmail(
    label: 'Chainmail',
    level: 2,
    slotType: SlotType.Armor,
    subType: ArmorType.Chainmail,
    maxHealth: 20,
    regenHealth: 2,
    masterySword: 5,
    skillType: SkillType.Mighty_Strike,
  ),
  Armor_Platemail(
    label: 'Platemail',
    level: 3,
    slotType: SlotType.Armor,
    subType: ArmorType.Platemail,
    maxHealth: 30,
    regenHealth: 3,
    masterySword: 8,
    healthSteal: 1,
    skillType: SkillType.Mighty_Strike,
  ),
  Armor_Robes(
    label: 'Robes',
    level: 1,
    slotType: SlotType.Armor,
    subType: ArmorType.Robes,
    maxHealth: 5,
    regenMagic: 1,
    maxMagic: 5,
    masteryStaff: 3,
    magicSteal: 1,
  ),
  Armor_Cloak(
    label: 'Cloak',
    level: 1,
    slotType: SlotType.Armor,
    subType: ArmorType.Cloak,
    maxHealth: 5,
    regenMagic: 1,
    maxMagic: 5,
    masteryStaff: 3,
    magicSteal: 1,
  ),
  Armor_Mantle(
    label: 'Mantle',
    level: 2,
    slotType: SlotType.Armor,
    subType: ArmorType.Mantle,
    maxHealth: 9,
    masteryBow: 5,
  ),
  Armor_Shroud(
    label: 'Shroud',
    level: 3,
    slotType: SlotType.Armor,
    subType: ArmorType.Shroud,
    maxHealth: 9,
    masteryBow: 5,
  ),
  Shoes_Leather_Boots(
    label: 'Leather Boots',
    level: 1,
    slotType: SlotType.Shoes,
    subType: ShoeType.Leather_Boots,
    maxHealth: 5,
    agility: 2,
    masterySword: 5,
  ),
  Shoes_Grieves(
    label: 'Grieves',
    level: 2,
    slotType: SlotType.Shoes,
    subType: ShoeType.Grieves,
    maxHealth: 5,
    agility: 20,
    masterySword: 5,
  ),
  Shoes_Warrior_3_Sabatons_Common(
    label: 'Sabatons',
    level: 3,
    slotType: SlotType.Shoes,
    subType: ShoeType.Sabatons,
    maxHealth: 5,
    agility: 3,
    masterySword: 5,
  ),
  Shoes_Black_Slippers(
    label: 'Black Slippers',
    level: 1,
    slotType: SlotType.Shoes,
    subType: ShoeType.Black_Slippers,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Frostball,
    masteryStaff: 5,
  ),
  Shoes_Footwraps(
    label: 'Footwraps',
    level: 2,
    slotType: SlotType.Shoes,
    subType: ShoeType.Footwraps,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Ice_Arrow,
    masteryStaff: 5,
    masteryCaste: 3,
  ),
  Shoes_Soles(
    label: 'Soles',
    level: 3,
    slotType: SlotType.Shoes,
    subType: ShoeType.Soles,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Blind,
    masteryStaff: 5,
  ),
  Shoes_Treads(
    label: 'Treads',
    level: 1,
    slotType: SlotType.Shoes,
    subType: ShoeType.Treads,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Split_Shot,
    masteryBow: 5,
  ),
  Shoes_Striders(
    label: 'Striders',
    level: 2,
    slotType: SlotType.Shoes,
    subType: ShoeType.Striders,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Mighty_Strike,
    masteryBow: 5,
    agility: 8,
  ),
  Shoes_Satin_Boots(
    label: 'Satin_Boots',
    level: 3,
    slotType: SlotType.Shoes,
    subType: ShoeType.Satin_Boots,
    maxHealth: 1,
    maxMagic: 5,
    skillType: SkillType.Ice_Arrow,
    masteryBow: 3,
  ),
  Consumable_Potion_Magic(
    label: 'a common tonic',
    slotType: SlotType.Consumable,
    subType: ConsumableType.Potion_Blue,
    level: 0,
    regenMagic: 20,
  ),
  Consumable_Potion_Health(
    label: 'a common tonic',
    slotType: SlotType.Consumable,
    subType: ConsumableType.Potion_Red,
    level: 0,
    regenHealth: 20,
  );

  int get levelMax => level + 1;
  
  /// the minimum level of a fiend that can drop this item
  final int level;
  /// the maximum level of fiends that can drop this item
  
  /// see item_type.dart in commons
  final SlotType slotType;
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
    required this.slotType,
    required this.subType,
    required this.level,
    required this.label,
    this.quality = ItemQuality.Common,
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

  bool get isWeapon => slotType == SlotType.Weapon;

  bool get isWeaponSword => isWeapon && WeaponType.isSword(subType);

  bool get isWeaponStaff => isWeapon && WeaponType.isStaff(subType);

  bool get isWeaponBow => isWeapon && WeaponType.isBow(subType);

  bool get isShoes => slotType == SlotType.Shoes;

  bool get isHelm => slotType == SlotType.Helm;

  bool get isConsumable => slotType == SlotType.Consumable;

  bool get isArmor => slotType == SlotType.Armor;

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
        amuletItem.level <= level &&
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
    }


    if (this.isConsumable) return;

    final expectedValue = this.expectedValue;

    if (expectedValue == null){
      throw Exception('$this.expectedValue is null');
    }

    final value = this.quantify;
    if (value != expectedValue){
      print('$this.validationError '
          'incorrect value. '
          '{got: $value, expected: $expectedValue}\n'
      );
    }

  }

  int? get expectedValue => itemValues[slotType]?[quality]?[level];


  static const itemValues = {
    SlotType.Weapon: const {
      ItemQuality.Common: {
        1: 5,
        2: 10,
        3: 16,
        4: 20,
      },
      ItemQuality.Unique: {
        1: 7,
        2: 13,
        3: 18,
        4: 26,
      },
    },
    SlotType.Helm: const {
      ItemQuality.Common: {
        1: 5,
        2: 10,
        3: 16,
      },
      ItemQuality.Unique: {
        1: 7,
        2: 13,
        3: 18,
      },
    },
    SlotType.Armor: const {
      ItemQuality.Common: {
        1: 5,
        2: 10,
        3: 16,
      },
      ItemQuality.Unique: {
        1: 7,
        2: 13,
        3: 18,
      },
    },
    SlotType.Shoes: const {
      ItemQuality.Common: {
        1: 5,
        2: 10,
        3: 16,
      },
      ItemQuality.Unique: {
        1: 7,
        2: 13,
        3: 18,
      },
    },
  };
}

enum CasteType {
  Bow,
  Sword,
  Staff,
  Caste,
  Melee,
}

enum ItemQuality {
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

  static int getPointTargetShoes({
    required int level,
    required ItemQuality quality,
  }) => const {
      ItemQuality.Common: {
        1: 5,
        2: 10,
        3: 16,
      },
      ItemQuality.Unique: {
        1: 7,
        2: 13,
        3: 18,
      },
    }[quality]?[level] ?? 0;

}
