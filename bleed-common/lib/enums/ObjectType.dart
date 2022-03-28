enum ObjectType {
  House01,
  Tree01,
  Rock,
  House02,
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
  LongGrass,
  Rock_Wall,
  Flag,
  Block_Grass,
}

final List<ObjectType> objectTypes = ObjectType.values;

String parseEnvironmentObjectTypeToString(ObjectType type){
  return type.toString().replaceAll("ObjectType.", "");
}

ObjectType parseObjectTypeFromString(String value){
     return objectTypes.firstWhere((type) => parseEnvironmentObjectTypeToString(type) == value, orElse: (){
    throw Exception("could not parse $value to type");
  });
}
