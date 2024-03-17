

import 'package:amulet_flutter/isometric/consts/height.dart';
import 'package:flutter/material.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

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

    final focusNode = FocusNode();
    focusNode.addListener(() {
      // if (focusNode.hasFocus) {
      //   components.engine.disableKeyEventHandler();
      // } else {
      //   components.engine.enableKeyEventHandler();
      // }
    });
    return OnDisposed(
      action: focusNode.dispose,
      child: Column(
        children: [
          // Text(title, style: style.textFieldTitleStyle),
          height4,
          Container(
            color: Colors.white12,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              autofocus: true,
              focusNode: focusNode,
              controller: controller,
              cursorColor: Colors.white70,
              autocorrect: autoFocus,
            ),
          ),
        ],
      ),
    );

  }
}