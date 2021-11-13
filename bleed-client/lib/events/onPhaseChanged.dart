
import 'package:bleed_client/enums/Phase.dart';
import 'package:bleed_client/watches/ambientLight.dart';

void onPhaseChangedSetAmbientLight(Phase value){
  print("onPhaseChangedSetAmbientLight($value)");
  switch (value) {
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