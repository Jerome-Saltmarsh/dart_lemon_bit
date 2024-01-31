
class ChangeType {
  static const None = 0;
  static const Delta = 1;
  static const Absolute = 2;
  static const One = 3;

  static int fromDiff(num diff) {
    return diff == 0 ? None :
      diff == 1 ? One :
        diff.abs() < 128 ? Delta :
          Absolute;
  }
}