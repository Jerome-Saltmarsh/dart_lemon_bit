
import 'package:typedef/json.dart';

import '../classes/Player.dart';

enum Trigger {
  OnItemCollected,
  OnItemCollected_Health,
  OnPlayerDeath
}

class GameActionIncreasePlayerHealth extends GameAction {

  final int amount;

  GameActionIncreasePlayerHealth(this.amount);

  @override
  void perform(Map<String, dynamic> data) {
    if (data.containsKey('player')){
      throw Exception("data.player is null");
    }
    final player = data['player'] as Player;
    player.health += amount;
  }
}

abstract class GameAction {
  void perform(Json data);
}

class GameTrigger {
  final Trigger trigger;
  final List<GameAction> actions;

  GameTrigger(this.trigger, this.actions);

  void perform(Map<String, dynamic> data){
    actions.forEach((action) {
      action.perform(data);
    });
  }
}

