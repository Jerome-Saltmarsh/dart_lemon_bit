


import 'package:gamestream_flutter/isometric/grid.dart';

import '../../network/send_client_request.dart';

void increaseCanvasSizeZ(){
  sendClientRequestSetCanvasSize(gridTotalZ + 1, gridTotalRows, gridTotalColumns);
}