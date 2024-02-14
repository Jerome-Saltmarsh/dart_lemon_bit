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
      quantify: 0,
      casteSpeed: AttackSpeed.Very_Slow,
  ),
  Strike(
      description: 'Attack with a melee weapon',
      casteType: CasteType.Melee,
      magicCost: 0,
      quantify: 0,
  ),
  Mighty_Strike(
      description: 'Applies area of effect damage to melee attacks',
      casteType: CasteType.Melee,
      magicCost: 3,
      quantify: 3,
  ),
  Frostball(
      description: 'Fire a ball of frost that slows enemies',
      casteType: CasteType.Staff,
      magicCost: 4,
      range: 125,
      damageMin: 3,
      damageMax: 5,
    quantify: 3,
  ),
  Fireball(
      description: 'Shoot a ball of fire that scorches enemies',
      casteType: CasteType.Staff,
      magicCost: 5,
      range: 150,
      damageMin: 4,
      damageMax: 6,
    quantify: 3,
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
    quantify: 4,
  ),
  Freeze_Target(
      description: 'Slows a single enemy',
      casteType: CasteType.Staff,
      magicCost: 8,
      range: 125,
    quantify: 4,
  ),
  Freeze_Area(
      description: 'Creates a small blizzard to freeze enemies',
      casteType: CasteType.Staff,
      magicCost: 5,
      range: 150,
    quantify: 5,
  ),
  // BOW
  Shoot_Arrow(
      description: 'Shoot a regular arrow',
      casteType: CasteType.Bow,
      magicCost: 0,
      quantify: 0,
  ),
  Exploding_Arrow(
      description: 'Shoot an arrow that explodes on impact',
      casteType: CasteType.Bow,
      magicCost: 5,
      quantify: 4,
  ),
  Split_Shot(
      description: 'Fire multiple arrows at once',
      casteType: CasteType.Bow,
      magicCost: 4,
      quantify: 3,
  ),
  Ice_Arrow(
      description: 'Shoot an arrow dipped in ice to freeze enemies',
      casteType: CasteType.Bow,
      magicCost: 4,
      ailmentDuration: 4.5,
      quantify: 5,
  ),
  Fire_Arrow(
      description: 'Shoot an arrow that burns on impact',
      casteType: CasteType.Bow,
      magicCost: 4,
      ailmentDuration: 3.5,
      ailmentDamage: 1,
      quantify: 5,
  ),
  // CASTE
  Heal(
      description: 'Heals a small amount of health',
      casteType: CasteType.Caste,
      magicCost: 4,
      casteSpeed: AttackSpeed.Fast,
      range: 0,
      quantify: 3,
      amount: 10,
  ),
  Teleport(
      description: 'move a short distance through space',
      casteType: CasteType.Caste,
      magicCost: 5,
      casteSpeed: AttackSpeed.Fast,
      range: 250,
    quantify: 4,
  ),
  Entangle(
      description: 'Binds an enemies legs for a short duration',
      casteType: CasteType.Caste,
      magicCost: 4,
      range: 150,
      casteSpeed: AttackSpeed.Slow,
    quantify: 3,
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
  final int quantify;
  final int? amount;

  const SkillType({
    required this.casteType,
    required this.magicCost,
    required this.description,
    required this.quantify,
    this.casteSpeed,
    this.ailmentDuration,
    this.ailmentDamage,
    this.damageMin,
    this.damageMax,
    this.range,
    this.amount,
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
}

