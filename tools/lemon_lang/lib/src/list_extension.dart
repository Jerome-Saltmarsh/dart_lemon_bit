extension ListExtensions<T> on List<T> {

  T? tryGet(int? index) =>
      index == null ||
          index < 0 ||
          index >= length
          ? null
          : this[index];

  List<T> sortBy(int Function(T value) getValue) {
    sort((a, b) => getValue(a).compareTo(getValue(b)));
    return this;
  }

  void fill(T? value) => fillRange(0, length, value);

  bool isValidIndex(int? index) =>
      index != null &&
          index >= 0 &&
          index <= length;
}