import 'package:bleed_client/enums/Phase.dart';

Phase mapHourToPhase(int hour) {
  if (hour < 2) return Phase.MidNight;
  if (hour < 4) return Phase.Night;
  if (hour < 6) return Phase.EarlyMorning;
  if (hour < 10) return Phase.Morning;
  if (hour < 16) return Phase.Day;
  if (hour < 18) return Phase.EarlyEvening;
  if (hour < 20) return Phase.Evening;
  return Phase.Night;
}
