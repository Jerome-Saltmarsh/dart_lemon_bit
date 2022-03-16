import 'package:bleed_common/AbilityType.dart';
import 'package:flutter/material.dart';

Map<AbilityType, DecorationImage> mapAbilityTypeToDecorationImage = {
  AbilityType.Fireball: spellIcon("fireball"),
  AbilityType.Ice_Ring: spellIcon("freeze"),
  AbilityType.Blink: spellIcon("flash"),
  AbilityType.Explosion: spellIcon("explode"),
  AbilityType.Dash: spellIcon("dash"),
  AbilityType.Split_Arrow: spellIcon("split-arrows"),
  AbilityType.Long_Shot: spellIcon("long-shot"),
  AbilityType.Iron_Shield: spellIcon("iron-shield"),
  AbilityType.Brutal_Strike: spellIcon("brutal-strike"),
  AbilityType.Death_Strike: spellIcon("death-strike"),
};

final _DecorationImages decorationImages = _DecorationImages();

class _DecorationImages {
  final orbTopaz = _png('icons/icon-orb-topaz');
  final orbEmerald = _png('icons/icon-orb-emerald');
  final orbRuby = _png('icons/icon-orb-ruby');
  final sword = _png('icons/icon-sword');
  final shield = _png('icons/icon-shield');
  final book = _png('icons/icon-book');
  final edit = _png('icons/icon-edit');
  final play = _png('icons/icon-play');
  final fullscreen = _png('icon fullscreen');
  final google = _png('icons/google_logo');
  final facebook = _png('icons/icon-facebook');
  final royal = _png('icon-battle-royal');
  final mmo = _png('games/game-icon-mmo');
  final heroesLeague = _png('games/game-icon-heroes-league');
  final zombieRoyal = _png('games/game-icon-zombie-royal');
  final profile = _png('icons/icon-profile');
  final cube = _png('games/game-icon-cube-3d');
  final counterStrike = _png('games/game-icon-counter-strike');
  final atlas = _png('games/game-icon-atlas');
  final login = _png('icons/icon-login');
  final settings2 = _png('icons/icon-settings');
}

DecorationImage spellIcon(String name) {
  return _png('spell-icon-$name');
}

DecorationImage _png(String name) {
  return DecorationImage(
    image: AssetImage('images/$name.png'),
  );
}

DecorationImage loadDecorationImage(String name) {
  return DecorationImage(
    image: AssetImage(name),
  );
}

Widget buildImage(String assetName, {
  required double width,
  required double height,
  Color color = Colors.transparent,
  double borderWidth = 0,
  Color borderColor = Colors.white,
  Radius? borderRadius,
}){
  return Container(
    width: width,
    height: height,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(assetName),
      ),
      color: color,
      border: borderWidth > 0
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
      // borderRadius: borderRadius ?? Radius.circular(4),
    ),
  );
}