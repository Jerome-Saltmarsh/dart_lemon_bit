import 'package:flutter/material.dart';
import 'package:lemon_atlas/sprites/sprite.dart';
import 'package:lemon_atlas/sprites/style.dart';
import 'package:lemon_atlas/ui/sprite_app.dart';


void main() async {
  runApp(
      AmuletSprites(
      sprite: Sprite(),
      style: Style(),
    )
  );
}



