

import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:bleed_client/render/mappers/mapDst.dart';
import 'package:bleed_client/render/mappers/mapSrc.dart';

drawCloud({
  required double x,
  required double y,
}){
  drawAtlas(
      dst: mapDst(x: x, y: y),
      src: mapSrc(
          x: atlas.cloud.x,
          y: atlas.cloud.y,
          width: atlas.cloudSize.x,
          height: atlas.cloudSize.y)
  );
}