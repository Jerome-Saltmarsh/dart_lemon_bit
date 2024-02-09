

enum AmuletScene {
  Tutorial(level: 1),
  Witches_Lair_1 (level: 3),
  Witches_Lair_2 (level: 4),
  World_00 (level: 2),
  World_01 (level: 2),
  World_02 (level: 3),
  World_10 (level: 1),
  World_11 (level: 1),
  World_12 (level: 1),
  World_20 (level: 1),
  World_21 (level: 1),
  World_22 (level: 1),
  Editor (level: 1),
  Loading (level: 0);

  final int level;
  const AmuletScene({required this.level});
}