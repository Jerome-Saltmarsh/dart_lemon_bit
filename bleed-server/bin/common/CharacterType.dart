enum CharacterType {
  Human,
  Zombie,
}

extension CharacterTypeExtensions on CharacterType {
  bool get isHuman => this == CharacterType.Human;
  bool get isZombie => this == CharacterType.Zombie;
}

const characterTypes = CharacterType.values;

final List<CharacterType> playableCharacterTypes = [
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