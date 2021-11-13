import 'package:bleed_client/watches/time.dart';


Phase getPhase() {
  double _hour = hour;
  if (_hour < 4) return Phase.Night;
  if (_hour < 6) return Phase.EarlyMorning;
  if (_hour < 10) return Phase.Morning;
  if (_hour < 16) return Phase.Day;
  if (_hour < 18) return Phase.EarlyEvening;
  if (_hour < 20) return Phase.Evening;
  return Phase.Night;
}

double get minute {
  return time.value / 60.0;
}

double get hour {
  return minute / 60;
}

enum Phase {
  EarlyMorning,
  Morning, // 5 - 9
  Day, // 9 - 5
  EarlyEvening,
  Evening, // 5 - 9
  Night, // 9 - 5
}
