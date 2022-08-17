import 'package:flutter/cupertino.dart';

final icons = _Icons();

class _Icons {
  final google = buildIcon('google');
  final facebook = buildIcon('facebook');
  final sword = buildIcon("sword");
  final shield = buildIcon("shield");
  final unknown = buildIcon("unknown");
  final empty = buildIcon("slot-empty");
  final bag = buildIcon("bag");
  final bagGray = buildIcon("bag-gray");
  final boots = buildIcon('boots');
  final arrowSkull = buildIcon('arrow-skull');
  final crossbow = buildIcon('crossbow');
  final arrows = buildIcon('arrows');
  final armour = _ArmourIcons();
  final swords = _SwordIcons();
  final bows = _BowIcons();
  final potions = _PotionIcons();
  final heads = _HeadIcons();
  final trinkets = _Trinkets();
  final staffs = _StaffIcons();
  final books = _IconsBooks();
  final firearms = _IconsFirearms();
  final resources = _IconsResources();
  final structures = _IconsStructures();
  final symbols = _IconsSymbols();
}


class _IconsSymbols {
  final plus = buildIcon("plus");
  final plusTransparent = buildIcon("plus-transparent");
  final fullscreenEnter = buildIcon('fullscreen-enter');
  final fullscreenExit = buildIcon('fullscreen-exit');
  final soundEnabled = buildIcon('sound-enabled');
  final soundDisabled = buildIcon('sound-disabled');
  final home = buildIcon('home');
  final upgrade = buildIcon("upgrade");
  final upgradeTransparent = buildIcon("upgrade-transparent");
}

class _IconsResources {
  final wood = buildIcon("wood", width: 32, height: 32);
  final stone = buildIcon("stone", width: 32, height: 32);
  final gold = buildIcon("gold", width: 32, height: 32);
}

class _IconsStructures {
  final palisade = buildIcon("structure-palisade", width: 32, height: 32);
  final tower = buildIcon("structure-tower", width: 32, height: 32);
  final torch = buildIcon("structure-torch", width: 32, height: 32);
}

class _IconsFirearms {
  final handgun = buildIcon("handgun");
  final shotgun = buildIcon("shotgun");
}

class _IconsBooks {
  final grey = buildIcon("book-grey");
  final red = buildIcon("book-red");
  final blue = buildIcon("book-blue");
}

class _StaffIcons {
  final wooden = buildIcon("staff-wooden");
  final blue = buildIcon("staff-blue");
  final golden = buildIcon("staff-golden");
}

class _ArmourIcons {
  final padded = buildIcon('armour-padded');
  final standard = buildIcon("armour-standard");
  final magic = buildIcon("armour-magic");
}

class _Trinkets {
  final goldenNecklace = buildIcon('necklace');
}

class _HeadIcons {
  final steel = buildIcon("helmet-steel");
  final magic = buildIcon("magic-hat");
  final rogue = buildIcon("hat-rogue");
}

class _PotionIcons {
  final red = buildIcon('potion-red');
  final blue = buildIcon('potion-blue');
}

class _SwordIcons {
  final wooden = buildIcon("sword-wooden");
  final woodenGray = buildIcon("sword-wooden-gray");
  final iron = buildIcon("sword-iron");
  final pickaxe = buildIcon("pickaxe");
  final pickaxeGray = buildIcon("pickaxe-gray");
  final axe = buildIcon("axe");
  final axeGray = buildIcon("axe-gray");
  final hammer = buildIcon("hammer");
  final hammerGray = buildIcon("hammer-gray");
}

class _BowIcons {
  final wooden = buildIcon("bow-wooden");
  final woodenGray = buildIcon("bow-wooden-gray");
  final green = buildIcon("bow-green");
  final gold = buildIcon("bow-gold");
}

// Functions
Widget buildIcon(String fileName, {
  double width = 32,
  double height = 32,
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
