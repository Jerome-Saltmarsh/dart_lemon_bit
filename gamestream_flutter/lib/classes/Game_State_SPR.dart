
class GameStateSPR {
  static var totalPlayers = 0;
  static final players = List.generate(100, (index) => SPRPlayer());
}

class SPRPlayer {
  var x = 0.0;
  var y = 0.0;
}
