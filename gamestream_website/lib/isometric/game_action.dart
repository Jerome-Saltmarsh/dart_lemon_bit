

import 'package:lemon_engine/engine.dart';

final gameActions = <GameAction>[];

void runAction({required int duration, required Function action}){
   _getInstance().set(action: action, duration: duration);
}

GameAction _getInstance(){
   for (final gameAction in gameActions){
      if (gameAction.active) continue;
      return gameAction;
   }
   final newInstance = GameAction();
   gameActions.add(newInstance);
   return newInstance;
}

void updateGameActions(){
  for (final gameAction in gameActions){
      gameAction.update();
  }
}

class GameAction {
   late int end;
   late Function action;
   var active = false;

   void update(){
      if (!active) return;
      if (end > engine.frame) return;
      action();
      active = false;
   }

   void set({required Function action, required int duration}) {
      assert (duration >= 0);
      this.action = action;
      this.end = engine.frame + duration;
      this.active = true;
   }
}