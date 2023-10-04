import 'is_byte.dart';

int compressBytesToUInt64(
    int a,
    int b,
    int c,
    int d,
    int e,
    int f,
    int g,
    int h,
    ) {
  assert (isByte(a));
  assert (isByte(b));
  assert (isByte(c));
  assert (isByte(d));
  return
    (a << 56) |
    (b << 48) |
    (c << 40) |
    (d << 32) |
    (e << 24) |
    (f << 16) |
    (g << 8) |
    h;
}
