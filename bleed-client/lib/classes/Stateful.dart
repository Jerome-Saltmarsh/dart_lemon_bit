
import 'dart:async';

class State<T> {
  T _value;
  T get value => _value;
  final StreamController<T> onChanged = StreamController.broadcast();

  State(this._value);

  set value(T t){
    if (_value == t) return;
    _value = t;
    onChanged.add(value);
  }

  void call(T t){
    value = t;
  }
}