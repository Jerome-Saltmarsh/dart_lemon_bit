import 'package:flutter/cupertino.dart';

// Constants
const _orbSize = 20.0;

// Instance
final resources = _Resources();

// Classes
class _Resources {
  final _Icons icons = _Icons();
}

class _Icons {
  final topaz = _image("orb-topaz", width: _orbSize, height: _orbSize);
  final emerald = _image("orb-emerald", width: _orbSize, height: _orbSize);
  final ruby = _image("orb-ruby", width: _orbSize, height: _orbSize);
  final sword = _image("sword");
  final shield = _image("shield");
  final book = _image("book");
  final staffWooden = _image("staff-wooden");
  final staffBlue = _image("staff-blue");
  final staffGolden = _image("staff-golden");
  final bookRed = _image("book-red");
  final unknown = _image("unknown");
  final armourStandard = _image("armour-standard");
  final helmetSteel = _image("helmet-steel");
  final empty = _image("slot-empty");
  final _SwordIcons swords = _SwordIcons();
  final _BowIcons bows = _BowIcons();
  final _PotionIcons potions = _PotionIcons();
}

class _PotionIcons {
  final red = _image('potion-red');
}

class _SwordIcons {
  final wooden = _image("sword-wooden");
  final iron = _image("sword-iron");
}

class _BowIcons {
  final wooden = _image("bow-wooden");
  final green = _image("bow-green");
  final gold = _image("bow-gold");
}

// Functions
Widget _image(String fileName, {
  double? width,
  double? height,
  double borderWidth = 1,
  Color? color,
  Color? borderColor,
  BorderRadius? borderRadius,
}) {
  return Container(
    width: width,
    height: height,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('images/icons/icon-$fileName.png'),
      ),
      color: color,
      border: borderWidth > 0 && borderColor != null
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
      borderRadius: borderRadius,
    ),
  );
}
