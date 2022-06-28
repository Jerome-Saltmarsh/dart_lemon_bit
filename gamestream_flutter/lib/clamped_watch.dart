import 'package:lemon_watch/watch.dart';

typedef GetInt = int Function();

class ClampedIntWatch extends Watch<int> {

  final GetInt getMax;
  final GetInt getMin;

  ClampedIntWatch(int value, this.getMax, this.getMin) : super(value){

  }
}