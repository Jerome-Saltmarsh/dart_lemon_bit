import 'is_byte.dart';

int compressBytesToUInt32(int a, int b, int c, int d) {
  assert (isByte(a));
  assert (isByte(b));
  assert (isByte(c));
  assert (isByte(d));
  return (a << 24) | (b << 16) | (c << 8) | d;
}

