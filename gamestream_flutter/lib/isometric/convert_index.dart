import 'package:gamestream_flutter/isometric/grid.dart';

int convertIndexToZ(int index) =>
    index ~/ gridTotalArea;

int convertIndexToRow(int index) =>
    (index - ((index ~/ gridTotalArea) * gridTotalArea)) ~/ gridTotalColumns;

int convertIndexToColumn(int index) =>
    index - ((convertIndexToZ(index) * gridTotalArea) + (convertIndexToRow(index) * gridTotalColumns));
