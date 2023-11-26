
bool readBitFromByte(int byte, int index) {
  assert(index >= 0);
  assert(index <= 7);

  int mask = 1 << index;  // Create a mask with the bit at the given index set to 1
  int maskedByte = byte & mask;  // Perform bitwise AND to extract the bit value

  return maskedByte != 0;  // Return true if the masked byte is not zero, false otherwise
}

bool readBitFromByteLR(int byte, int index) {
  const hexValues = [
    0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01
  ];
  if (index < 0 || index >= hexValues.length) {
    throw Exception('Invalid index');
  }

  return (byte & hexValues[index]) == hexValues[index];
}
