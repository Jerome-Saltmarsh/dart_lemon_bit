enum AbilityType {
  None,
  FreezeCircle,
  Blink,
  Explosion,
  Dash,
  Fireball,
  Split_Arrow,
  Long_Shot,
  Iron_Shield, // knight
  Brutal_Strike, // knight -- aoe attack
  Death_Strike, // knight - 1 target 300% damage
}

final List<AbilityType> abilities = AbilityType.values;

final int maxAbilityIndex = 3;

String abilityTypeToString(AbilityType value){
  return value.toString().replaceAll("AbilityType.", "");
}