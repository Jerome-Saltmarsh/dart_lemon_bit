
import 'is_nibble.dart';

int writeNibblesToByte(int a, int b) {
  assert (isNibble(a));
  assert (isNibble(b));
  return (a << 4) | b;
}

