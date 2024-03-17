
import 'package:amulet_connect/enums/connection_region.dart';

ConnectionRegion detectConnectionRegion() {
  final now = DateTime.now();
  final timeZoneName = now.timeZoneName;
// print("$timeZoneName utc: ${now.timeZoneOffset.inHours}");
  if (timeZoneName.contains('Australian')) {
    return ConnectionRegion.Oceania;
  }
  if (timeZoneName.contains('AWST')) {
    return ConnectionRegion.Oceania;
  }
  if (timeZoneName.contains('ACST')) {
    return ConnectionRegion.Oceania;
  }
  if (timeZoneName.contains('AEST')) {
    return ConnectionRegion.Oceania;
  }
  if (timeZoneName.contains('Singapore')) {
    return ConnectionRegion.Asia_South;
  }
  if (timeZoneName.contains('Indochina')) {
    return ConnectionRegion.Asia_South;
  }
  if (timeZoneName.contains('Brasil')) {
    return ConnectionRegion.America_South;
  }
  if (timeZoneName.contains('Brazil')) {
    return ConnectionRegion.America_South;
  }
  if (timeZoneName.contains('Central European Time')) {
    return ConnectionRegion.Europe;
  }
  final utc = now.timeZoneOffset.inHours;

// if (utc == -9) {
//   return ConnectionRegion.USA_West;
// }
// if (utc == -8) {
//   return ConnectionRegion.USA_West;
// }
// if (utc == -7) {
//   return ConnectionRegion.USA_East;
// }
// if (utc == -6) {
//   return ConnectionRegion.USA_East;
// }
  if (utc == -5) {
// return ConnectionRegion.USA_East;
  }
  if (utc == 0) {
    return ConnectionRegion.Europe;
  }
  if (utc == 1) {
    return ConnectionRegion.Europe;
  }
  if (utc == 2) {
    return ConnectionRegion.Europe;
  }
  if (utc == 3) {
    return ConnectionRegion.Europe;
  }
  if (utc == 4) {
    return ConnectionRegion.Europe;
  }
  if (utc == 5) {
    return ConnectionRegion.Europe;
  }
  if (utc == 6) {
    return ConnectionRegion.Asia_South;
  }
  if (utc == 7) {
    return ConnectionRegion.Asia_South;
  }
  if (utc == 8) {
    return ConnectionRegion.Asia_South;
  }
// return ConnectionRegion.USA_West;
  return ConnectionRegion.America_North;
}
