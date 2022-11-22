
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

String getPercentageDifferenceFormatted(num a, num b) {
  return formatPercentage(getPercentageDifference(a, b));
}

String formatPercentage(num a) => '${(a * 100).toInt()}%';

double getPercentageDifference(num a, num b) {
  if (a == 0 && b == 0) return 0;
  if (a == 0) return -1.0;
  if (b == 0) return 1.0;
  return (a - b) / b;
}
