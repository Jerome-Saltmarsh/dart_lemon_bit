int writeBits(
    bool i0,
    bool i1,
    bool i2,
    bool i3,
    bool i4,
    bool i5,
    bool i6,
    bool i7,
    ) {
  int byteValue = 0;

  byteValue |= (i0 ? 1 : 0);  // Set the 0th bit
  byteValue |= (i1 ? 1 : 0) << 1;  // Set the 1st bit
  byteValue |= (i2 ? 1 : 0) << 2;  // Set the 2nd bit
  byteValue |= (i3 ? 1 : 0) << 3;  // Set the 3rd bit
  byteValue |= (i4 ? 1 : 0) << 4;  // Set the 4th bit
  byteValue |= (i5 ? 1 : 0) << 5;  // Set the 5th bit
  byteValue |= (i6 ? 1 : 0) << 6;  // Set the 6th bit
  byteValue |= (i7 ? 1 : 0) << 7;  // Set the 7th bit

  return byteValue;
}
