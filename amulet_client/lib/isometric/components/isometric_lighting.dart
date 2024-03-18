
import 'package:amulet_client/packages/lemon_components.dart';
import 'package:lemon_math/src.dart';

class IsometricLighting implements Updatable {
  var emissionAlphaCharacter = 125;
  var torchEmissionIntensityColored = 0.0;
  var torchEmissionIntensityAmbient = 1.0;
  var torchEmissionStart = 0.75;
  var torchEmissionEnd = 1.0;
  var torchEmissionVal = 0.061;
  var torchEmissionT = 0.0;

  var rainAmbienceLight = 10;
  var rainAmbientHeavy = 20;

  void onComponentUpdate(){
    if (torchEmissionVal == 0) return;
    torchEmissionT += torchEmissionVal;

    if (
      torchEmissionT < torchEmissionStart ||
      torchEmissionT > torchEmissionEnd
    ) {
      torchEmissionT = torchEmissionT.clamp(torchEmissionStart, torchEmissionEnd);
      torchEmissionVal = -torchEmissionVal;
    }

    torchEmissionIntensityAmbient = interpolate(
      torchEmissionStart,
      torchEmissionEnd,
      torchEmissionT,
    );

    torchEmissionIntensityColored = torchEmissionIntensityAmbient - 0.2;
  }
}