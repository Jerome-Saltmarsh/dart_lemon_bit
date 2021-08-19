import 'dart:async';

final StreamController<OnPlayerCreated> onPlayerCreated = StreamController.broadcast();

class OnPlayerCreated {
  final String uuid;
  final int id;
  final double x;
  final double y;
  OnPlayerCreated(this.uuid, this.id, this.x, this.y);
}