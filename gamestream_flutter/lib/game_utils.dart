
import 'library.dart';

class GameUtils {
  static ConnectionRegion detectConnectionRegion(){
      final now = DateTime.now();
      final timeZoneName = now.timeZoneName;
      // print("$timeZoneName utc: ${now.timeZoneOffset.inHours}");
      if (timeZoneName.contains('Australian')){
        return ConnectionRegion.Australia;
      }
      if (timeZoneName.contains('AWST')){
        return ConnectionRegion.Australia;
      }
      if (timeZoneName.contains('ACST')){
        return ConnectionRegion.Australia;
      }
      if (timeZoneName.contains('AEST')){
        return ConnectionRegion.Australia;
      }
      if (timeZoneName.contains('Singapore')){
        return ConnectionRegion.Singapore;
      }
      if (timeZoneName.contains('Brasil')){
        return ConnectionRegion.Brazil;
      }
      if (timeZoneName.contains('Brazil')){
        return ConnectionRegion.Brazil;
      }
      if (timeZoneName.contains('Central European Time')){
        return ConnectionRegion.Germany;
      }
      if (timeZoneName.contains('Korea')){
        return ConnectionRegion.South_Korea;
      }

      final utc = now.timeZoneOffset.inHours;

      if (utc == -9) {
        return ConnectionRegion.USA_West;
      }
      if (utc == -8) {
        return ConnectionRegion.USA_West;
      }
      if (utc == -7) {
        return ConnectionRegion.USA_East;
      }
      if (utc == -6) {
        return ConnectionRegion.USA_East;
      }
      if (utc == -5) {
        return ConnectionRegion.USA_East;
      }
      if (utc == 0) {
        return ConnectionRegion.Germany;
      }
      if (utc == 1) {
        return ConnectionRegion.Germany;
      }
      if (utc == 2) {
        return ConnectionRegion.Germany;
      }
      if (utc == 3) {
        return ConnectionRegion.Germany;
      }
      if (utc == 4) {
        return ConnectionRegion.Germany;
      }
      if (utc == 5) {
        return ConnectionRegion.Germany;
      }
      if (utc == 6) {
        return ConnectionRegion.Germany;
      }
      if (utc == 7) {
        return ConnectionRegion.Germany;
      }
      if (utc == 8) {
        return ConnectionRegion.Singapore;
      }
      if (utc == 9) {
        return ConnectionRegion.South_Korea;
      }
      if (utc == 10) {
        return ConnectionRegion.South_Korea;
      }
      if (utc == 11) {
        return ConnectionRegion.South_Korea;
      }
     return ConnectionRegion.USA_West;
  }
}