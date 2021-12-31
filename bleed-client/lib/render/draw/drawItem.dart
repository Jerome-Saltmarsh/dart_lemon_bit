import 'dart:typed_data';

import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/mappers/mapDst.dart';
import 'package:bleed_client/render/mappers/mapSrc.dart';
import 'package:bleed_client/state.dart';

import 'drawAtlas.dart';

void drawItem(Item item){
  drawAtlas(
      dst: mapDst(x: item.x - 32, y: item.y - 32),
      src: mapSrc(x: atlas.items.x, y: atlas.items.y),
  );
}