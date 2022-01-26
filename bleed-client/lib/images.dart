import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';

final _Images images = _Images();
const int _totalImages = 3;

Watch<int> _imagesLoaded = Watch(0, onChanged: (int value){
  core.state.download.value =  value / _totalImages;
});

Map<ObjectType, int> environmentObjectIndex = {
  ObjectType.Rock: 0,
  ObjectType.Grave: 1,
  ObjectType.Tree_Stump: 2,
  ObjectType.Rock_Small: 3,
  ObjectType.LongGrass: 4,
  ObjectType.Torch: 0,
  ObjectType.Tree01: 0,
  ObjectType.House01: 0,
  ObjectType.House02: 1,
  ObjectType.Palisade: 0,
  ObjectType.Palisade_H: 1,
  ObjectType.Palisade_V: 2,
  ObjectType.MystEmitter: 0,
  ObjectType.Rock_Wall: 0,
};

class _Images {
  late Image atlas;

  Future<Image> _png(String fileName) async {
    Image image = await loadImage('images/$fileName.png');
    _imagesLoaded.value++;
    return image;
  }

  Future load() async {
    atlas = await _png("atlas");
  }
}


