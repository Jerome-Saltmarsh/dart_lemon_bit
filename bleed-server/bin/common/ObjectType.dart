
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
}

const List<EnvironmentObjectType> environmentObjectTypes = EnvironmentObjectType.values;

const List<EnvironmentObjectType> _palisades = [
  EnvironmentObjectType.Palisade,
  EnvironmentObjectType.Palisade_H,
  EnvironmentObjectType.Palisade_V,
];

bool isPalisade(EnvironmentObjectType type){
  return _palisades.contains(type);
}

bool isGeneratedAtBuild(EnvironmentObjectType type){
  return isPalisade(type);
}

