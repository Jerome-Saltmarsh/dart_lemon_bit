
class ChangeType {

  static const None = 0;
  static const Small = 1;
  static const Big = 2;

  static int fromDiff(int diff){
    if (diff == 0)
      return None;
    if (diff.abs() < 126)
      return Small;
    return Big;
  }
}