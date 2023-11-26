int signToByte(int value) => switch (value) {
      0 => 0x0,
      1 => 0x1,
      -1 => 0x2,
      _ => (throw Exception()),
    };

