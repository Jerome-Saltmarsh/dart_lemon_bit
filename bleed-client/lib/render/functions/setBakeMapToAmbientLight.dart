import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/variables/ambientLight.dart';

void setBakeMapToAmbientLight(){
  render.bakeMap.clear();
  render.dynamicShading.clear();

  for (int column = 0; column < compiledGame.totalColumns; column++) {
    List<Shading> shading = [];
    List<Shading> bakeMap = [];
    render.dynamicShading.add(shading);
    render.bakeMap.add(bakeMap);
    for (int row = 0; row < compiledGame.totalRows; row++) {
      shading.add(ambientLight);
      bakeMap.add(ambientLight);
    }
  }
}
