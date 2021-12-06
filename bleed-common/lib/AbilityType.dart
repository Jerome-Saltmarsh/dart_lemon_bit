enum AbilityType {
  None,
  FreezeCircle,
  Blink,
  Explosion,
  Fireball,
}

final List<AbilityType> abilities = AbilityType.values;

final int maxAbilityIndex = 3;

String abilityTypeToString(AbilityType value){
  return value.toString().replaceAll("AbilityType.", "");
}