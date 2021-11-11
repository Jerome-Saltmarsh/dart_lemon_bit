
import 'dart:async';

class ReactiveValue<T> {
  T _value;
  T get value => _value;
  final StreamController<T> _controller = StreamController.broadcast();

  ReactiveValue(this._value);

  set value(T t){
    if (_value == t) return;
    _value = t;
    _controller.add(value);
  }

  void call(T t){
    value = t;
  }

  StreamSubscription<T> onChanged(void function(T t)){
    return stream.listen((event) {
      function(event);
    });
  }

  Stream get stream => _controller.stream;
}