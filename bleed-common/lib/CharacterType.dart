enum CharacterType {
  Human,
  Template,
  Soldier,
  Zombie,
  Witch,
  Swordsman,
  Archer,
}

extension CharacterTypeExtensions on CharacterType {
  bool get isTemplate => this == CharacterType.Template;
  bool get isSoldier => this == CharacterType.Soldier;
  bool get isHuman => this == CharacterType.Human;
}

const characterTypes = CharacterType.values;

final List<CharacterType> playableCharacterTypes = [
  CharacterType.Witch,
  CharacterType.Swordsman,
  CharacterType.Archer,
  CharacterType.Human,
];

String characterTypeToString(CharacterType value){
  return value.toString().replaceAll("CharacterType.", "");
}

CharacterType parseCharacterType(String type){
  return characterTypes.firstWhere((element) => element.name == type, orElse: (){
    throw Exception("could not parse $type to CharacterType");
  });
}