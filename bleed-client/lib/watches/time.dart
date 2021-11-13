import 'package:lemon_watch/watch.dart';

final timeInSeconds = Watch(0);

double get timeInMinutes {
  return timeInSeconds.value / 60.0;
}

double get timeInHours {
  return timeInMinutes / 60;
}



