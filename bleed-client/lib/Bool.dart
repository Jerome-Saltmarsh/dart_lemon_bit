import 'package:lemon_watch/watch.dart';

class Bool extends Watch<bool> {
  Bool(bool value) : super(value);

  void toggle(){
    this.value = !value;
  }

  void setTrue(){
    value = true;
  }

  void setFalse(){
    value = false;
  }
}
