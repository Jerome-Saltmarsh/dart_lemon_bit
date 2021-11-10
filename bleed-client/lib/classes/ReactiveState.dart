
import 'dart:async';

class ReactiveState<T> {
  T _value;
  T get value => _value;
  final StreamController<T> onChanged = StreamController.broadcast();

  ReactiveState(this._value);

  set value(T t){
    if (_value == t) return;
    _value = t;
    onChanged.add(value);
  }

  void call(T t){
    value = t;
  }

  Stream get stream => onChanged.stream;
}