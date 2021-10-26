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
  Rock_Small
}

String toString(EnvironmentObjectType type){
  return type.toString().replaceAll("EnvironmentObjectType.", "");
}

EnvironmentObjectType fromString(String value){
  return EnvironmentObjectType.values.firstWhere((element) => toString(element) == value, orElse: (){
    throw Exception("could not parse $value to type");
  });
}
