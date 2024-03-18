int byteToSign(int value) => switch (value) {
  0x0 => 0,
  0x1 => 1,
  0x2 => -1,
  _ => (throw Exception()),
};
