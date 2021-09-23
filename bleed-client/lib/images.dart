import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/game_engine/game_resources.dart';

_Images images = _Images();

class _Images {
  Image imageCharacter;
  Image zombie;
  Image imageTiles;
  Image imageParticles;
  Image imageHandgun;
  Image imageHandgunAmmo;
  Image imageCollectables;
  Image imageShotgunAmmo;
  Image items;

  Future load() async {
    imageCharacter = await loadImage("images/character.png");
    zombie = await loadImage("images/zombie.png");
    imageTiles = await loadImage("images/tiles.png");
    imageParticles = await loadImage('images/particles.png');
    imageHandgun = await loadImage('images/weapon-handgun.png');
    imageHandgunAmmo = await loadImage('images/handgun-ammo.png');
    imageShotgunAmmo = await loadImage('images/shotgun-ammo.png');
    imageCollectables = await loadImage("images/collectables.png");
    items = await loadImage("images/items.png");
  }
}


