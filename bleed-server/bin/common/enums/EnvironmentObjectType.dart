enum EnvironmentObjectType {
  House01,
  Tree01,
  Rock,
  House02,
  Tree02,
  Palisade,
  Grave,
  Palisade_H,
  Palisade_V,
  SmokeEmitter,
  MystEmitter,
  Torch,
  Bridge,
  Tree_Stump,
  Rock_Small,
  Character,
  LongGrass
}

final List<EnvironmentObjectType> environmentObjectTypes = EnvironmentObjectType.values;

String parseEnvironmentObjectTypeToString(EnvironmentObjectType type){
  return type.toString().replaceAll("EnvironmentObjectType.", "");
}

EnvironmentObjectType parseEnvironmentObjectTypeFromString(String value){
  return environmentObjectTypes.firstWhere((type) => parseEnvironmentObjectTypeToString(type) == value, orElse: (){
    throw Exception("could not parse $value to type");
  });
}
