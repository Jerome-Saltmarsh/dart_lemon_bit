
import 'dart:typed_data';

Uint16List copyUInt16List(List<int> values){
  final array = Uint16List(values.length);
  for (var i = 0; i < values.length; i++){
    array[i] = values[i];
  }
  return array;
}