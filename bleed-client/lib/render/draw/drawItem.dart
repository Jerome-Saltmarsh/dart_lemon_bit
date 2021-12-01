import 'dart:typed_data';

import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/mappers/mapDst.dart';
import 'package:bleed_client/state.dart';

import 'drawAtlas.dart';

Float32List _src = Float32List(4);

void drawItem(Item item){
  int frame = drawFrame % 8;
  _src[0] = atlas.items.x * frame * 64.0;
  _src[1] = atlas.items.y;
  _src[2] = _src[0] + 64;
  _src[3] = _src[1]  + 64;
  drawAtlas(mapDst(x: item.x - 32, y: item.y - 32), _src);
}