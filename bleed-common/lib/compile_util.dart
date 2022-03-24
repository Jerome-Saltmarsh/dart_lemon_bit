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


