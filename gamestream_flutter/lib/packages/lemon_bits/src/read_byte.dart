int readByte1(int value) => value & 0xFF;

int readByteAtIndex({required int value, required int bits}) => readByte1(value >> bits);

const bitsPerByte = 8;

int readByte2(int value) => readByteAtIndex(value: value, bits: bitsPerByte * 1);

int readByte3(int value) => readByteAtIndex(value: value, bits: bitsPerByte * 2);

int readByte4(int value) => readByteAtIndex(value: value, bits: bitsPerByte * 3);

int readByte5(int value) => readByteAtIndex(value: value, bits: bitsPerByte * 4);

int readByte6(int value) => readByteAtIndex(value: value, bits: bitsPerByte * 5);

int readByte7(int value) => readByteAtIndex(value: value, bits: bitsPerByte * 6);

int readByte8(int value) => readByteAtIndex(value: value, bits: 56);








