
import 'dart:async';

class IsometricSubscriptions {
  StreamSubscription? onAmbientChanged;

  void cancel(){
    print("isometric.subscriptions.cance()");
    onAmbientChanged?.cancel();
  }
}