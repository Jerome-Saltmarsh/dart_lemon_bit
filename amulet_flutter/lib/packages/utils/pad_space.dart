
String padSpace(num value, {required int length}) {
  String t = value.toInt().toString();
  final difference = length - t.length;
  if (difference <= 0) return t;
  if (t.length >= length) return t;
  for (var i = 0; i < difference; i++){
    t = ' $t';
  }
  return t;
}
