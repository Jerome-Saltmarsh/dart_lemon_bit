
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/enums/Phase.dart';

class IsometricMaps {

  IsometricMaps(){
    _compile();
  }

  void _compile(){
    phases.forEach((phase) {
      if (!phaseShade.containsKey(phase)){
        throw Exception("$phase missing in isometric.maps.phaseShade");
      }
    });
  }

  final Map<Phase, Shade> phaseShade = {
    Phase.EarlyMorning: Shade.Dark,
    Phase.Morning: Shade.Dark,
    Phase.Day: Shade.Bright,
    Phase.EarlyEvening: Shade.Medium,
    Phase.Evening: Shade.Dark,
    Phase.Night: Shade.VeryDark,
    Phase.MidNight: Shade.PitchBlack ,
  };
}