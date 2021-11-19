
import 'enums/ObjectType.dart';

const List<ObjectType> _palisades = [
  ObjectType.Palisade,
  ObjectType.Palisade_H,
  ObjectType.Palisade_V,
];

bool isPalisade(ObjectType type){
  return _palisades.contains(type);
}

bool isGeneratedAtBuild(ObjectType type){
  return isPalisade(type);
}

