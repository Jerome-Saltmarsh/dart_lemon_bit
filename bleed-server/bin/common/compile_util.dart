const END = 200;

void writeNumberToByteArray({
  required num number,
  required List<int> list,
  required int index
}){
  final abs = number.toInt().abs();
  list[index] = (number >= 0 ? 100 : 0) + abs ~/ 100;
  list[index + 1] = abs % 100;
}

int readNumberFromByteArray(List<int> bytes, {required int index}){
  final a = bytes[index];
  return (a < 100 ? -1 : 1) * ((a % 100) * 100 + bytes[index + 1]);
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
  final remainder65536 = numberInt % 65536;
  list[index] = numberInt ~/ 65536;
  list[index + 1] = remainder65536 ~/ 256;
  list[index + 2] = remainder65536 % 256;
}

int readBigNumberFromArray(List<int> bytes, {required int index}) {
  final count65536 = bytes[index];
  final count256 = bytes[index + 1];
  final remainder = bytes[index + 2];
  return (count65536 * 65536) + (count256 * 256) + remainder; 
}

