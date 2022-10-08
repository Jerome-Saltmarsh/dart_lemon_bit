import 'package:gamestream_flutter/isometric/grid.dart';

int convertIndexToZ(int index) =>
    index ~/ nodesArea;

int convertIndexToRow(int index) =>
    (index - ((index ~/ nodesArea) * nodesArea)) ~/ nodesTotalColumns;

int convertIndexToColumn(int index) =>
    index - ((convertIndexToZ(index) * nodesArea) + (convertIndexToRow(index) * nodesTotalColumns));
