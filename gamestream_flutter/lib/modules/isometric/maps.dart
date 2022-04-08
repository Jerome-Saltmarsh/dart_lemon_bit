import 'package:bleed_common/ItemType.dart';
import 'package:bleed_common/enums/Shade.dart';
import 'package:lemon_math/Vector2.dart';

import 'atlas.dart';
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
    Phase.Early_Morning: Shade.Dark,
    Phase.Morning: Shade.Medium,
    Phase.Day: Shade.Bright,
    Phase.Early_Evening: Shade.Medium,
    Phase.Evening: Shade.Dark,
    Phase.Night: Shade.Very_Dark,
    Phase.MidNight: Shade.Pitch_Black ,
  };

  int phaseToShade(Phase phase){
    return _phaseShade[phase]!;
  }

  Phase hourToPhase(int hour) {
    if (hour < 2) return Phase.MidNight;
    if (hour < 4) return Phase.Night;
    if (hour < 6) return Phase.Early_Morning;
    if (hour < 10) return Phase.Morning;
    if (hour < 16) return Phase.Day;
    if (hour < 18) return Phase.Early_Evening;
    if (hour < 20) return Phase.Evening;
    return Phase.Night;
  }

  final itemAtlas = <ItemType, Vector2>{
    ItemType.Handgun: atlas.items.handgun,
    ItemType.Shotgun: atlas.items.shotgun,
    ItemType.Health: atlas.items.health,
    ItemType.Orb_Emerald: atlas.items.emerald,
    ItemType.Orb_Ruby: atlas.items.orbRed,
    ItemType.Orb_Topaz: atlas.items.orbTopaz,
  };
}