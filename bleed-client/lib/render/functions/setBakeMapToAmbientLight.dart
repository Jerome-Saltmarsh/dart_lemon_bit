import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/render/state/bakeMap.dart';
import 'package:bleed_client/render/state/dynamicShading.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/variables/ambientLight.dart';

void setBakeMapToAmbientLight(){
  bakeMap.clear();
  dynamicShading.clear();

  for (int column = 0; column < compiledGame.totalColumns; column++) {
    List<Shading> _dynamic = [];
    List<Shading> _baked = [];
    dynamicShading.add(_dynamic);
    bakeMap.add(_baked);
    for (int row = 0; row < compiledGame.totalRows; row++) {
      _dynamic.add(ambientLight);
      _baked.add(ambientLight);
    }
  }
}
