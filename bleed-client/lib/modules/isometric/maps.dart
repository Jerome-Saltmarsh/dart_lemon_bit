
import 'package:bleed_client/common/enums/Shade.dart';

import 'enums.dart';

class IsometricMaps {

  IsometricMaps(){
    _compile();
  }

  void _compile(){
    phases.forEach((phase) {
      if (!_phaseShade.containsKey(phase)){
        throw Exception("$phase missing in isometric.maps.phaseShade");
      }
    });
  }

  final Map<Phase, int> _phaseShade = {
    Phase.EarlyMorning: Shade_Dark,
    Phase.Morning: Shade_Medium,
    Phase.Day: Shade_Bright,
    Phase.EarlyEvening: Shade_Medium,
    Phase.Evening: Shade_Dark,
    Phase.Night: Shade_VeryDark,
    Phase.MidNight: Shade_PitchBlack ,
  };

  int phaseToShade(Phase phase){
    return _phaseShade[phase]!;
  }

  Phase hourToPhase(int hour) {
    if (hour < 2) return Phase.MidNight;
    if (hour < 4) return Phase.Night;
    if (hour < 6) return Phase.EarlyMorning;
    if (hour < 10) return Phase.Morning;
    if (hour < 16) return Phase.Day;
    if (hour < 18) return Phase.EarlyEvening;
    if (hour < 20) return Phase.Evening;
    return Phase.Night;
  }

}