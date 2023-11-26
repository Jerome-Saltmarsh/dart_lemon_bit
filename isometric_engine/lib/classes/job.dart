class GameJob {
  int duration;
  late int remaining;
  Function action;
  bool repeat;
  var available = false;

  GameJob(this.duration, this.action, {this.repeat = false}) {
    remaining = duration;
  }
}
