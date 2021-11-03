const int _zero = 0;

num abs(num value) {
  if (value < _zero) return -value;
  return value;
}
