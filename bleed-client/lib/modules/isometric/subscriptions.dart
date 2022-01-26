
import 'dart:async';

class IsometricSubscriptions {
  StreamSubscription? onAmbientLightChanged;

  void cancel(){
    print("isometric.subscriptions.cance()");
    onAmbientLightChanged?.cancel();
  }
}