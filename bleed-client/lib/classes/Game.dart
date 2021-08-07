


import 'Connection.dart';
import 'Images.dart';
import 'Settings.dart';
import 'State.dart';

class Game {
  final Settings settings;
  final State state;
  final Connection connection;
  final Images images;

  Game({this.settings, this.state, this.connection, this.images});
}