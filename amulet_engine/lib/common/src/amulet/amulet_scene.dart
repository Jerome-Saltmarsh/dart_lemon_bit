

enum AmuletScene {
  Tutorial(level: 1),
  Witches_Lair_1 (level: 3),
  Witches_Lair_2 (level: 4),
  Lost_Swamps (level: 2),
  Marshlands (level: 2),
  World_02 (level: 3),
  World_10 (level: 1),
  Village (level: 1),
  World_12 (level: 1),
  World_20 (level: 1),
  World_21 (level: 1),
  World_22 (level: 1),
  Editor (level: 1),
  Loading (level: 0);

  final int level;
  const AmuletScene({required this.level});

  static AmuletScene findByName(String name){
    for (final value in values){
      if (value.name == name) {
        return value;
      }
    }
    throw Exception('AmuletScene.findByName("$name")');
  }
}