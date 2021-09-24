typedef num GetNum<T>(T t);

void sort<T>(List<T> list, GetNum<T> function) {
  list.sort((T a, T b) {
    return function(a) < function(b) ? 1 : -1;
  });
}
