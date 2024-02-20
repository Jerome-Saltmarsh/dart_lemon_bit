


import '../consts/node_size.dart';

int convertRenderToColumn(double x, double y, double z) => (y - x + z) ~/ Node_Size;