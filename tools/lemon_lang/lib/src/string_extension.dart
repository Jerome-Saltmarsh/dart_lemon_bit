
extension StringExtension on String {
  String get clean => replaceAll('_', ' ');
  String get upper => toUpperCase();
  String get lower => toLowerCase();
}