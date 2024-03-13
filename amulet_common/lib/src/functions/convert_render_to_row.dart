

import '../consts/node_size.dart';

int convertRenderToRow(double x, double y, double z) => (x + y + z) ~/ Node_Size;