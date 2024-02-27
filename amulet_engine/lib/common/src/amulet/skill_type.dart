import 'amulet_item.dart';

enum SkillClass {
  Sword,
  Bow,
  Staff,
  Caste,
}

enum SkillType {
  None(
      casteType: CasteType.Caste,
      magicCost: 0,
      range: 0,
      description: '',
      casteSpeed: AttackSpeed.Very_Slow,
  ),
  Strike(
      description: 'Attack with a melee weapon',
      casteType: CasteType.Melee,
      magicCost: 0,
  ),
  Mighty_Strike(
      description: 'Causes extra damage',
      casteType: CasteType.Sword,
      magicCost: 3,
  ),
  Frostball(
      description: 'Fire a ball of frost that slows enemies',
      casteType: CasteType.Staff,
      magicCost: 4,
      range: 125,
      damageMin: 3,
      damageMax: 5,
  ),
  Fireball(
      description: 'Shoot a ball of fire that scorches enemies',
      casteType: CasteType.Staff,
      magicCost: 5,
      range: 150,
      damageMin: 4,
      damageMax: 6,
  ),
  Explode(
      description: 'Create a blast of energy',
      casteType: CasteType.Staff,
      magicCost: 7,
      range: 125,
      damageMin: 8,
      damageMax: 12,
      ailmentDamage: 1,
      ailmentDuration: 1,
  ),
  Freeze_Target(
      description: 'Slows a single enemy',
      casteType: CasteType.Staff,
      magicCost: 8,
      range: 125,
  ),
  Freeze_Area(
      description: 'Creates a small blizzard to freeze enemies',
      casteType: CasteType.Staff,
      magicCost: 5,
      range: 150,
  ),
  // BOW
  Shoot_Arrow(
      description: 'Shoot a regular arrow',
      casteType: CasteType.Bow,
      magicCost: 0,
  ),
  Exploding_Arrow(
      description: 'Shoot an arrow that explodes on impact',
      casteType: CasteType.Bow,
      magicCost: 5,
  ),
  Split_Shot(
      description: 'Fire multiple arrows at once',
      casteType: CasteType.Bow,
      magicCost: 4,
  ),
  Ice_Arrow(
      description: 'Shoot an arrow dipped in ice to freeze enemies',
      casteType: CasteType.Bow,
      magicCost: 4,
      ailmentDuration: 4.5,
  ),
  Fire_Arrow(
      description: 'Shoot an arrow that burns on impact',
      casteType: CasteType.Bow,
      magicCost: 4,
      ailmentDuration: 3.5,
      ailmentDamage: 1,
  ),
  // CASTE
  Heal(
      description: 'Heals Wounds',
      casteType: CasteType.Caste,
      magicCost: 4,
      casteSpeed: AttackSpeed.Fast,
      range: 0,
  ),
  Blind(
    description: 'Blinds enemies for a short duration',
    casteType: CasteType.Caste,
    magicCost: 5,
    range: 300,
    casteSpeed: AttackSpeed.Fast,
  ),
  Attack_Speed(
    description: 'Increases attack and caste speed',
    casteType: CasteType.Passive,
    magicCost: 0,
  ),
  Health_Steal(
    description: 'Steal health when damage is applied to enemies',
    casteType: CasteType.Passive,
    magicCost: 0,
  ),
  Magic_Steal(
    description: 'Steal magic when damage is applied to enemies',
    casteType: CasteType.Passive,
    magicCost: 0,
  ),
  Critical_Hit(
    description: 'Chance of doing double damage',
    casteType: CasteType.Passive,
    magicCost: 0,
  ),
  Magic_Regen(
    description: 'Increase mana gained over time',
    casteType: CasteType.Passive,
    magicCost: 0,
  ),
  Health_Regen(
    description: 'Increase health gained over time',
    casteType: CasteType.Passive,
    magicCost: 0,
  ),
  Area_Damage(
    description: 'Effects the amount of enemies effected by a melee attack',
    casteType: CasteType.Passive,
    magicCost: 0,
  ),
  Run_Speed(
    description: 'How fast one can run',
    casteType: CasteType.Passive,
    magicCost: 0,
  ),
  ;


  final CasteType casteType;
  final int magicCost;
  /// if null the weapon perform duration is used
  final AttackSpeed? casteSpeed;
  /// if null the weapon range is used
  final double? range;
  final int? damageMin;
  final int? damageMax;
  final String description;
  final double? ailmentDuration;
  final int? ailmentDamage;

  const SkillType({
    required this.casteType,
    required this.magicCost,
    required this.description,
    this.casteSpeed,
    this.ailmentDuration,
    this.ailmentDamage,
    this.damageMin,
    this.damageMax,
    this.range,
  });

  static void validate() {
    for (final skillType in values){
      if (skillType.casteType == CasteType.Caste){
        if (skillType.range == null){
          throw Exception('$skillType.range cannot be null');
        }
        if (skillType.casteSpeed == null){
          throw Exception('$skillType.casteDuration cannot be null');
        }
      }
    }
  }

  static SkillType parse(String name){
     for (final skillType in values) {
        if (skillType.name == name)
          return skillType;
     }
     throw Exception('SkillType.parse("$name")');
  }

  static String? getLevelDescription(SkillType skillType, int level){

    switch (skillType){
      case SkillType.Heal:
        return 'Heals ${getHealAmount(level)} health';
      default:
        return '';
    }
  }

  static int getHealAmount(int level) => 5 * level;
}

