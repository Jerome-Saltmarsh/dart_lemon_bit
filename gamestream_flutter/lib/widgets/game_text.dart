
import 'package:flutter/material.dart';

class GameText extends StatelessWidget {
  final dynamic value;
  final double size;
  final Function? onPressed;
  final double? height;
  final bool italic = false;
  final bool bold = false;
  final bool underline = false;
  final Color color;
  final String? family;
  final TextAlign? align;

  GameText(this.value, {
        this.size = 18,
        this.onPressed,
        this.color = Colors.white,
        this.family,
        this.align,
        this.height,
  });

  @override
  Widget build(BuildContext context) {
      final _text = Text(
          value.toString(),
          textAlign: align,
          style: TextStyle(
              color: color,
              fontSize: size,
              decoration: underline ? TextDecoration.underline : TextDecoration.none,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontFamily: family,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              height: height
          )
      );

      if (onPressed == null) return _text;

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: _text,
          onTap: (){
            onPressed!();
          },
        ),
      );
  }
}