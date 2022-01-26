import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/modules/isometric/state.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/functions/emitLight.dart';
import 'package:bleed_client/render/functions/mapTilesToSrcAndDst.dart';
import 'package:bleed_client/render/state/tilesSrc.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/watches/ambientLight.dart';

class IsometricActions {

  IsometricState get _state => modules.isometric.state;

  void applyDynamicShadeToTileSrc() {
    final _size = 48.0;
    int i = 0;
    final dynamicShading = _state.dynamicShading;
    for (int row = 0; row < game.totalRows; row++) {
      for (int column = 0; column < game.totalColumns; column++) {
        Shade shade = dynamicShading[row][column];
        tilesSrc[i + 1] = atlas.tiles.y + shade.index * _size; // top
        tilesSrc[i + 3] = tilesSrc[i + 1] + _size; // bottom
        i += 4;
      }
    }
  }

  void setBakeMapToAmbientLight(){
    print("isometric.actions.setBakeMapToAmbientLight()()");
    _state.bakeMap.clear();
    for (int row = 0; row < game.totalRows; row++) {
      final List<Shade> _baked = [];
      _state.bakeMap.add(_baked);
      for (int column = 0; column < game.totalColumns; column++) {
        _baked.add(_state.ambient.value);
      }
    }
  }

  void setDynamicMapToAmbientLight(){
    print("isometric.actions.setDynamicMapToAmbientLight()");
    _state.dynamicShading.clear();
    for (int row = 0; row < game.totalRows; row++) {
      final List<Shade> _dynamic = [];
      modules.isometric.state.dynamicShading.add(_dynamic);
      for (int column = 0; column < game.totalColumns; column++) {
        _dynamic.add(modules.isometric.state.ambient.value);
      }
    }
  }

  void applyEnvironmentObjectsToBakeMapping(){
    for (EnvironmentObject env in modules.isometric.state.environmentObjects){
      if (env.type == ObjectType.Torch){
        emitLightHigh(modules.isometric.state.bakeMap, env.x, env.y);
        continue;
      }
      if (env.type == ObjectType.House01){
        emitLightLow(modules.isometric.state.bakeMap, env.x, env.y);
        continue;
      }
      if (env.type == ObjectType.House02){
        emitLightLow(modules.isometric.state.bakeMap, env.x, env.y);
        continue;
      }
    }
  }


  void resetDynamicShadesToBakeMap() {
    final dynamicShading = modules.isometric.state.dynamicShading;
    for (int row = 0; row < dynamicShading.length; row++) {
      for (int column = 0; column < dynamicShading[0].length; column++) {
        dynamicShading[row][column] = modules.isometric.state.bakeMap[row][column];
      }
    }
  }

  void updateTileRender(){
    print("actions.updateTileRender()");
    setBakeMapToAmbientLight();
    setDynamicMapToAmbientLight();
    mapTilesToSrcAndDst();
  }
}