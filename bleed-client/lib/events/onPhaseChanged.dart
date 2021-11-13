
import 'package:bleed_client/enums/Phase.dart';
import 'package:bleed_client/watches/ambientLight.dart';

void updateAmbientLight(Phase phase){
  print("onPhaseChangedSetAmbientLight($phase)");
  switch (phase) {
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
    case Phase.MidNight:
      setAmbientLightPitchBlack();
      break;
  }
}