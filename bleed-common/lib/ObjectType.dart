
import 'enums/EnvironmentObjectType.dart';

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

