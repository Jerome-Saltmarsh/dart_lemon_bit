
num clampRange(num value, num min, num max){
  final clamped = (value % max) + min;
  assert (clamped >= min);
  assert (clamped <= max);
  return clamped;
}