class ChangeNotifier<T> {
  late T _value;
  final Function(T t) onChanged;

  ChangeNotifier(T t, this.onChanged) {
    _value = t;
  }

  T get value => _value;

  set value(T t){
    if (t == _value) return;
    _value = t;
    onChanged(t);
  }
}