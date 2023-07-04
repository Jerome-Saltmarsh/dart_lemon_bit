import 'package:gamestream_flutter/gamestream/isometric/components/isometric_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_scene.dart';
import 'package:gamestream_flutter/instances/gamestream.dart';

abstract class IsometricRenderer {
  var _index = 0;
  var total = 0;
  var orderRowColumn = 0.0;
  var orderZ = 0;
  var remaining = true;

  final IsometricScene scene;

  IsometricRender get renderer => gamestream.isometric.renderer;

  IsometricRenderer(this.scene);

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
