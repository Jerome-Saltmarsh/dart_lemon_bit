/// Extension methods for lists in Dart.
extension ListExtensions<T> on List<T> {

  /// Tries to get the element at the specified index. Returns null if the index is out of range.
  /// Returns the element if the index is valid.
  T? tryGet(int? index) =>
      index == null ||
          index < 0 ||
          index >= length
          ? null
          : this[index];

  /// Sorts the list based on the provided value getter function.
  /// Returns the sorted list.
  List<T> sortBy(num Function(T value) getValue) {
    sort((a, b) => getValue(a).compareTo(getValue(b)));
    return this;
  }

  /// Fills the entire list with the specified value.
  void fill(T? value) => fillRange(0, length, value);

  /// Checks if the provided index is a valid index within the list bounds.
  bool isValidIndex(int? index) =>
      index != null &&
          index >= 0 &&
          index <= length;

  /// Maps each element of the list to a value using the provided builder function and
  /// returns the resulting map. The keys are the elements of the list and the values
  /// are determined by the builder function.
  Map<T, J> asMapReversed<J>(J Function(T t) build) {
    final map = <T, J>{};
    for (var i = 0; i < length; i++) {
      map[this[i]] = build(this[i]);
    }
    return map;
  }

  /// Retrieves the element at the specified index, cycling through the list if necessary.
  /// Throws an exception if the list is empty.
  T cycle(int index) {
    if (isEmpty) {
      throw Exception('Empty list cannot be cycled');
    }
    return this[index % length];
  }
}
