
String padZero(num value) {
  String t = value.toInt().toString();
  if (t.length >= 2) return t;
  return '0$t';
}

String padSpace(num value, {required int length}) {
  String t = value.toInt().toString();
  final difference = length - t.length;
  if (difference <= 0) return t;
  if (t.length >= length) return t;
  for (var i = 0; i < difference; i++){
     t = " $t";
  }
  return t;
}