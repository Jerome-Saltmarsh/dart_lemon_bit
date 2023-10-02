

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';
import 'package:gamestream_flutter/gamestream/ui/constants/height.dart';

class GSTextField extends StatelessWidget {

  final String title;
  final TextEditingController controller;
  final bool autoFocus;

  const GSTextField({
    super.key,
    required this.controller,
    required this.title,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return IsometricBuilder(
      builder: (context, components) {
        final style = components.style;
        return Column(
          children: [
            Text(title, style: style.textFieldTitleStyle),
            height4,
            Container(
              color: Colors.white12,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                autofocus: true,
                controller: controller,
                cursorColor: style.textFieldCursorColor,
                style: style.textFieldStyle,
                decoration: style.textFieldDecoration,
                autocorrect: autoFocus,
              ),
            ),
          ],
        );
      }
    );
  }
}