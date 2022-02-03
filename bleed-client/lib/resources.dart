import 'package:flutter/cupertino.dart';

// Constants
const _orbSize = 20.0;

// Instance
final resources = _Resources();

// Classes
class _Resources {
  final _Icons icons = _Icons();
  final _Directories directories = _Directories();
}

class _Directories {
  final images = "images";
  final icons = "images/icons";
}

class _Icons {
  final topaz = _image("orb-topaz", width: _orbSize, height: _orbSize);
  final emerald = _image("orb-emerald", width: _orbSize, height: _orbSize);
  final ruby = _image("orb-ruby", width: _orbSize, height: _orbSize);
  final sword = _image("sword");
  final shield = _image("shield");
  final book = _image("book");
  final woodenSword = _image("wooden-sword");
  final ironSword = _image("iron-sword");
  final unknown = _image("unknown");
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
