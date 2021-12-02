enum CharacterType {
  Human,
  Zombie,
  Witch,
  Knight,
  Archer,
  Musketeer,
}

const characterTypes = CharacterType.values;

final List<CharacterType> playableCharacterTypes = [
  CharacterType.Witch,
  CharacterType.Knight,
  CharacterType.Archer,
  CharacterType.Musketeer,
];

String characterTypeToString(CharacterType value){
  return value.toString().replaceAll("CharacterType.", "");
}