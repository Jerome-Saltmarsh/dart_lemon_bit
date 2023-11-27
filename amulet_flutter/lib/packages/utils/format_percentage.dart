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

