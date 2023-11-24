
bool isValidIndex(int? index, List values) {
  if (index == null) return false;
  if (values.isEmpty) return false;
  if (index < 0) return false;
  return index < values.length;
}
