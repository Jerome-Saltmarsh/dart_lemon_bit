
import 'dart:async';

class IsometricSubscriptions {
  StreamSubscription? onAmbientChanged;

  void cancelAll(){
    print("isometric.subscriptions.cancelAll()");
    onAmbientChanged?.cancel();
  }
}