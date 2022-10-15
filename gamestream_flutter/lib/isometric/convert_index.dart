import 'package:gamestream_flutter/game_state.dart';

int convertIndexToZ(int index) =>
    index ~/ GameState.nodesArea;

int convertIndexToRow(int index) =>
    (index - ((index ~/ GameState.nodesArea) * GameState.nodesArea)) ~/ GameState.nodesTotalColumns;

int convertIndexToColumn(int index) =>
    index - ((convertIndexToZ(index) * GameState.nodesArea) + (convertIndexToRow(index) * GameState.nodesTotalColumns));
