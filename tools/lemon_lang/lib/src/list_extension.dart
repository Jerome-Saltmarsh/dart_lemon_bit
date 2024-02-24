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

  Map<T, J> asMapReversed<J>(J build(T t)) {
    final map = <T, J>{};
    for (var i = 0; i < length; i++) {
      map[this[i]] = build(this[i]);
    }
    return map;
  }
}