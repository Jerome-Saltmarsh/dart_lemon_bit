extension DoubleExtension on double {
  String get toStringPercentage => '${(this * 100).toInt()}%';
}
