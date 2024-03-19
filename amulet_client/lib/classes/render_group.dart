
import 'package:amulet_client/isometric/components/isometric_component.dart';
import 'package:amulet_client/isometric/components/isometric_images.dart';
import 'package:lemon_engine/lemon_engine.dart';

abstract class RenderGroup with IsometricComponent {
  var _index = 0;
  var total = 0;
  var order = 0.0;
  var remaining = true;

  void renderFunction(LemonEngine lemonEngine, IsometricImages images);
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

  bool renderNext(LemonEngine engine, IsometricImages images) {
    renderFunction(engine, images);
    _index++;
    if (_index >= total) {
      remaining = false;
      return false;
    }
    updateFunction();
    return true;
  }
}
