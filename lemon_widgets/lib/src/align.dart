import 'package:flutter/material.dart';

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
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    child
  ],
);

Widget alignLeft({required Widget child})=> Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    child
  ],
);

