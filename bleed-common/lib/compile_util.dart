
const _256Int = 256;
const _oneDouble = 1.0;
const _oneInt = 1;
const _twoInt = 2;
const _minusOne = -_oneDouble;
const _zero = 0;

/// Parses a double into an array
/// Index 0: Sign 0 for negative and 1 for positive
/// Index 1: Number of 256
/// Index 2: Remainder from 256
void compileDouble({
  required double value,
  required List<int> list,
  required int index
}){
  final abs = value.toInt().abs();
  list[index] = value < _zero ? _zero : _oneInt; // sign
  list[index + _oneInt] = abs ~/ _256Int;  // count
  list[index + _twoInt] = abs % _256Int;   // remainder
}

double consumeDouble({required List<int> list, required int index}){
  final sign = list[index] == _zero ? _minusOne : _oneDouble;
  final count = list[index + _oneInt];
  final remainder = list[index + _twoInt];
  return sign * ((count * _256Int) + remainder);
}