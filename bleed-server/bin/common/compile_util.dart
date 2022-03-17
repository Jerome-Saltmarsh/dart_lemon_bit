const END = 200;

void writeNumberToByteArray({
  required num number,
  required List<int> list,
  required int index
}){
  final abs = number.toInt().abs();
  final count = abs ~/ 100;
  final remainder = abs % 100;
  final sign = number >= 0 ? 100 : 0;
  list[index] = sign + count;
  list[index + 1] = remainder;
}

int readNumberFromByteArray(List<int> bytes, {required int index}){
  final a = bytes[index];
  final b = bytes[index + 1];
  final sign = a < 100 ? -1 : 1;
  final count = a % 100;
  return sign * (count * 100 + b);
}

// void writeNumberToByteArray({
//   required num number,
//   required List<int> list,
//   required int index
// }){
//   assert(number <= _max);
//   assert(number >= -_max);
//
//   final abs = number.toInt().abs();
//   final count = abs ~/ _256Int;
//   final countIsZero = count == _zero;
//
//   list[index] =
//       countIsZero
//       ? number < _zero ? _zero : _oneInt
//       : number < _zero ? _twoInt : _threeInt
//   ;
//
//   if (countIsZero) {
//     list[index + _oneInt] = abs;
//     return;
//   }
//
//   list[index + _oneInt] = abs ~/ _256Int;  // count
//   list[index + _twoInt] = abs % _256Int;   // remainder
// }
//
// int readNumberFromByteArray(List<int> bytes, {required int index}){
//   final value1 = bytes[index + _oneInt];
//   switch(bytes[index]) {
//     case _zero:
//       return -value1;
//     case _oneInt:
//       return value1;
//     case _twoInt:
//       return -((value1 * _256Int) + (bytes[index + _twoInt]));
//     case _threeInt:
//       return ((value1 * _256Int) + bytes[index + _twoInt]);
//     default:
//       throw Exception("Invalid pivot number ${bytes[index]} at index $index");
//   }
// }

