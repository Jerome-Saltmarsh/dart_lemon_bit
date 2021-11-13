import 'package:bleed_client/mappers/mapHourToPhase.dart';
import 'package:bleed_client/watches/phase.dart';

const secondsPerMinute = 60;
const minutesPerHour = 60;
const secondsPerHour = 60 * 60 * 60;

int _hour = 0;

void onTimeChanged(int timeInSeconds) {
  double timeInMinutes = timeInSeconds / secondsPerMinute;
  double timeInHours = timeInMinutes / minutesPerHour;
  int _h = timeInHours.toInt();
  if (_hour == _h) return;
  _hour = _h;
  phase.value = mapHourToPhase(_hour);
}
