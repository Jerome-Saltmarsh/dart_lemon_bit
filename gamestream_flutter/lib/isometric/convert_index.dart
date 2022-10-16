import 'package:gamestream_flutter/game.dart';

int convertIndexToZ(int index) =>
    index ~/ Game.nodesArea;

int convertIndexToRow(int index) =>
    (index - ((index ~/ Game.nodesArea) * Game.nodesArea)) ~/ Game.nodesTotalColumns;

int convertIndexToColumn(int index) =>
    index - ((convertIndexToZ(index) * Game.nodesArea) + (convertIndexToRow(index) * Game.nodesTotalColumns));
