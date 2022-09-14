
class Value <T>{
  late T _value;
  Function(T oldValue, T newValue)? onChanged;
  Value(T t, {this.onChanged}) {
    _value = t;
  }

  set value(T t) {
    if (_value == t) return;
    final previous = _value;
    _value = t;
    onChanged?.call(previous, t);
  }
}