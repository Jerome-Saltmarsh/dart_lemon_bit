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

/// Writes numbers up to 256^3
/// Consumes 4 bytes
void writeBigNumberToArray({
  required num number,
  required List<int> list,
  required int index
}){
  assert(number <= 16777216);
  final numberInt = number.toInt();
  final count65536 = numberInt ~/ 65536;
  final remainder65536 = numberInt % 65536;
  final count256 = remainder65536 ~/ 256;
  final remainder = remainder65536 % 256;
  list[index] = count65536;
  list[index + 1] = count256;
  list[index + 2] = remainder;
}

int readBigNumberFromArray(List<int> bytes, {required int index}) {
  final count65536 = bytes[index];
  final count256 = bytes[index + 1];
  final remainder = bytes[index + 2];
  return (count65536 * 65536) + (count256 * 256) + remainder; 
}

