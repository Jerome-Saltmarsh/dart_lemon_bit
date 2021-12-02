
enum HeroType {
  None,
  Archer,
  Witch,
  Knight,
  Musketeer,
}

const List<HeroType> heroTypes = HeroType.values;
final List<HeroType> heroTypesExceptNone = heroTypes.where((heroType) => heroType != HeroType.None).toList();

String heroTypeToString(HeroType value){
  return value.toString().replaceAll("HeroType.", "");
}