
import 'package:bleed_client/cube/camera3d.dart';
import 'package:universal_html/html.dart';

void initCube(){
  document.addEventListener("mousemove", (value){
    if (value is MouseEvent){
      camera3D.rotateCamera(
          value.movement.x.toDouble(),
          value.movement.y.toDouble(),
          1.0
      );
    }
  }, false);
}