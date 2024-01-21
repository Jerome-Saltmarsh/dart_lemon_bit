import 'package:flutter/material.dart';
import 'expanded.dart';

Widget align({required Widget child, required Alignment alignment}){
  switch (alignment){
    case Alignment.centerRight:
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [child],
      );
    default:
      throw Exception('alignment not implemented: $alignment');
  }
}

Widget alignRight({required Widget child})=> Row(
  children: [
    expanded,
    child,
  ],
);

Widget alignLeft({required Widget child})=> Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    child
  ],
);

Widget alignCenter({required Widget child})=>
    Expanded(
      child: Center(
        child: child,
      ),
    );

