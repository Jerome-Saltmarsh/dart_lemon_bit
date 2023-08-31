
class ChangeType {

  static const None = 0;
  static const Small = 1;
  static const Big = 2;

  static int fromDiff(num diff) =>
      diff == 0
          ? None
            : diff.abs() < 128
              ? Small
                : Big;
}