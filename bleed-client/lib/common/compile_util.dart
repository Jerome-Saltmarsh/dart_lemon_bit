
const _256Int = 256;
const _oneDouble = 1.0;
const _oneInt = 1;
const _twoInt = 2;
const _minusOneDouble = -_oneDouble;
const _minusOneInt = -_oneInt;
const _zero = 0;

/// Max 65536
/// Parses a double into an array
/// Index 0: Sign 0 for negative and 1 for positive
/// Index 1: Number of 256
/// Index 2: Remainder from 256
void compileNumber({
  required num value,
  required List<int> list,
  required int index
}){
  assert(value <= 65536);
  assert(value >= -65536);

  final abs = value.toInt().abs();
  list[index] = value < _zero ? _zero : _oneInt; // sign
  list[index + _oneInt] = abs ~/ _256Int;  // count
  list[index + _twoInt] = abs % _256Int;   // remainder
}

/// Uses 4 bytes to store a number
/// Max 16777216
void compileLargeNumber({
  required num value,
  required List<int> list,
  required int index
}){
  assert(value <= 65536);
  assert(value >= -65536);

  final abs = value.toInt().abs();
  list[index] = value < _zero ? _zero : _oneInt; // sign
  list[index + _oneInt] = abs ~/ _256Int;  // count
  list[index + _twoInt] = abs % _256Int;   // remainder
}

double consumeDouble({required List<int> list, required int index}){
  final sign = list[index] == _zero ? _minusOneDouble : _oneDouble;
  final count = list[index + _oneInt];
  final remainder = list[index + _twoInt];
  return sign * ((count * _256Int) + remainder);
}

int readInt({required List<int> list, required int index}){
  final sign = list[index] == _zero ? _minusOneInt : _oneInt;
  final count = list[index + _oneInt];
  final remainder = list[index + _twoInt];
  return sign * ((count * _256Int) + remainder);
}

