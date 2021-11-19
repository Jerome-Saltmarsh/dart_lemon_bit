import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/render/state/bakeMap.dart';
import 'package:bleed_client/render/state/dynamicShading.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/watches/ambientLight.dart';

void setBakeMapToAmbientLight(){
  bakeMap.clear();
  dynamicShading.clear();

  for (int row = 0; row < game.totalRows; row++) {
    List<Shade> _dynamic = [];
    List<Shade> _baked = [];
    dynamicShading.add(_dynamic);
    bakeMap.add(_baked);
    for (int column = 0; column < game.totalColumns; column++) {
      _dynamic.add(ambient);
      _baked.add(ambient);
    }
  }
}
