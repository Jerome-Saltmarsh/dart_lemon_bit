
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

  final Map<Phase, Shade> _phaseShade = {
    Phase.EarlyMorning: Shade.Dark,
    Phase.Morning: Shade.Medium,
    Phase.Day: Shade.Bright,
    Phase.EarlyEvening: Shade.Medium,
    Phase.Evening: Shade.Dark,
    Phase.Night: Shade.VeryDark,
    Phase.MidNight: Shade.PitchBlack ,
  };

  Shade phaseToShade(Phase phase){
    return _phaseShade[phase]!;
  }
}