
import 'package:gamestream_flutter/gamestream/isometric/components/mixins/isometric_component.dart';

abstract class RenderGroup with IsometricComponent {
  var _index = 0;
  var total = 0;
  var order = 0.0;
  var remaining = true;

  void renderFunction();
  void updateFunction();
  int getTotal();

  int get index => _index;

  void reset(){
    total = getTotal();
    _index = 0;
    remaining = total > 0;
    if (remaining){
      updateFunction();
    }
  }

  void set index(int value){
    _index = value;
    if (value >= total) {
      remaining = false;
    }
  }

  void end(){
    index = total;
    remaining = false;
  }

  void renderNext() {
    renderFunction();
    _index++;
    if (_index >= total) {
      remaining = false;
      return;
    }
    updateFunction();
  }
}
