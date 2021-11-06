void insertionSort<E>({
  required List<E> list,
  required int Function(E, E) compare,
}) {
  int start = 0;
  int end = list.length;

  for (var pos = start + 1; pos < end; pos++) {
    var min = start;
    var max = pos;
    var element = list[pos];
    while (min < max) {
      var mid = min + ((max - min) >> 1);
      if (compare(element, list[mid]) < 0) {
        max = mid;
      } else {
        min = mid + 1;
      }
    }
    list.setRange(min + 1, pos + 1, list, min);
    list[min] = element;
  }
}
