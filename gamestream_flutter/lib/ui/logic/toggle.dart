import 'package:lemon_watch/watch.dart';

void toggle(Watch<bool> watch){
  watch.value = !watch.value;
}