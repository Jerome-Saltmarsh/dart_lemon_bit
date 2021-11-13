
import 'package:bleed_client/render/functions/setAmbientLight.dart';
import 'package:bleed_client/streams/time.dart';
import 'package:bleed_client/variables/phase.dart';

void onTimeChanged(int value){
    Phase _phase2 = getPhase();
    if (phase == _phase2) return;
    // this should also be reactive
    phase = _phase2;
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