
const _oneInt = 1;
const _twoInt = 2;
const _threeInt = 3;
const _256Int = 256;
const _zero = 0;
const _max = 65536;

const END = 100;

void writeNumberToByteArray({
  required num number,
  required List<int> list,
  required int index
}){
  assert(number <= _max);
  assert(number >= -_max);

  final abs = number.toInt().abs();
  final count = abs ~/ _256Int;
  final countIsZero = count == _zero;

  list[index] =
      countIsZero
      ? number < _zero ? _zero : _oneInt
      : number < _zero ? _twoInt : _threeInt
  ;

  if (countIsZero) {
    list[index + _oneInt] = abs;
    return;
  }

  list[index + _oneInt] = abs ~/ _256Int;  // count
  list[index + _twoInt] = abs % _256Int;   // remainder
}

int readNumberFromByteArray(List<int> bytes, {required int index}){
  final value1 = bytes[index + _oneInt];
  switch(bytes[index]) {
    case _zero:
      return -value1;
    case _oneInt:
      return value1;
    case _twoInt:
      return -((value1 * _256Int) + (bytes[index + _twoInt]));
    case _threeInt:
      return ((value1 * _256Int) + bytes[index + _twoInt]);
    default:
      throw Exception("Invalid pivot number ${bytes[index]} at index $index");
  }
}

