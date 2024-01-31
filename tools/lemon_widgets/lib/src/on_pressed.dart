
import 'package:flutter/material.dart';

Widget onPressed({
  required Widget child,
  Function? action,
  Function? onRightClick,
  Function? onEnter,
  Function? onExit,
  dynamic hint,
}) {
  final widget = MouseRegion(
      onEnter: onEnter == null ? null : (event) => onEnter(),
      onExit: onExit == null ? null : (event) => onExit(),
      cursor: action != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: child,
          onSecondaryTap: onRightClick != null ? (){
            onRightClick.call();
          } : null,
          onTap: (){
            if (action == null) return;
            action();
          }
      ));

  if (hint == null) return widget;

  return Tooltip(
    message: hint.toString(),
    child: widget,
  );
}

