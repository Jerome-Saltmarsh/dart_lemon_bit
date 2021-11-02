import 'package:bleed_client/input.dart';
import 'package:bleed_client/state.dart';

// const secondsPerMinute = 60;
// const minutesPerHour = 60;
// const hoursPerDay = 24;
//
// const secondsPerDay = secondsPerMinute * minutesPerHour * hoursPerDay;

// Phase phase = Phase.Day;

void setTime(int value) {
  Phase _phase1 = getPhase();
  compiledGame.time = value;
  Phase _phase2 = getPhase();
  if (_phase1 == _phase2) return;

  switch (_phase2) {
    case Phase.EarlyMorning:
      setAmbientLightDark();
      break;
    case Phase.Morning:
      setAmbientLightMedium();
      break;
    case Phase.Day:
      setAmbientLightBright();
      break;
    case Phase.EarlyEvening:
      setAmbientLightMedium();
      break;
    case Phase.Evening:
      setAmbientLightDark();
      break;
    case Phase.Night:
      setAmbientLightVeryDark();
      break;
  }
}

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
  return compiledGame.time / 60;
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
