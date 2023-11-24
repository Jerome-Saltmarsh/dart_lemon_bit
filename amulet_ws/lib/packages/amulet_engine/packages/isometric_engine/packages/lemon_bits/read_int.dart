

int readInt1FromBytes(int bytes) {
  final extractedByte = (bytes & 0xFF);
  return (extractedByte & 0x80) != 0 ? -((0x100 - extractedByte) & 0xFF) : extractedByte;
}

int readInt2FromBytes(int bits64) {
  final extractedByte = ((bits64 >> 8) & 0xFF);
  return (extractedByte & 0x80) != 0 ? -((0x100 - extractedByte) & 0xFF) : extractedByte;
}

int readInt3FromBytes(int bits64) {
  final extractedByte = ((bits64 >> 16) & 0xFF);
  return (extractedByte & 0x80) != 0 ? -((0x100 - extractedByte) & 0xFF) : extractedByte;
}

int readInt4FromBytes(int bits64) {
  final extractedByte = ((bits64 >> 24) & 0xFF);
  return (extractedByte & 0x80) != 0 ? -((0x100 - extractedByte) & 0xFF) : extractedByte;
}

int readInt5FromBytes(int bits64) {
  final extractedByte = ((bits64 >> 32) & 0xFF);
  return (extractedByte & 0x80) != 0 ? -((0x100 - extractedByte) & 0xFF) : extractedByte;
}

int readInt6FromBytes(int bits64) {
  final extractedByte = ((bits64 >> 40) & 0xFF);
  return (extractedByte & 0x80) != 0 ? -((0x100 - extractedByte) & 0xFF) : extractedByte;
}

int readInt7FromBytes(int bits64) {
  final extractedByte = ((bits64 >> 48) & 0xFF);
  return (extractedByte & 0x80) != 0 ? -((0x100 - extractedByte) & 0xFF) : extractedByte;
}

int readInt8FromBytes(int bits64) {
  final extractedByte = ((bits64 >> 56) & 0xFF);
  return (extractedByte & 0x80) != 0 ? -((0x100 - extractedByte) & 0xFF) : extractedByte;
}
