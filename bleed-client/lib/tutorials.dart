
import 'package:bleed_client/common.dart';
import 'package:bleed_client/state.dart';

int _tutorialIndex = 0;

Tut get tutorial => _tutorials[_tutorialIndex];
bool get tutorialsFinished => _tutorialIndex >= _tutorials.length;

void tutorialNext(){
  _tutorialIndex++;
}

abstract class Tutorial {
  String getText();
  bool getFinished();
}

typedef Get<T> = T Function();

class Tut {
  Get<String> getText;
  Get<bool> getFinished;

  Tut(this.getText, this.getFinished);
}

List<Tut> _tutorials = [
  Tut(() => "Walk: W,A,S,D", () => requestCharacterState == characterStateWalking),
  Tut(() => "Shoot: Space", () => requestCharacterState == characterStateFiring),
  Tut(() => "Reload: R", () => requestCharacterState == characterStateReloading),
  Tut(() => "Sprint: Left Shift + (WASD)", () => requestCharacterState == characterStateRunning),
];
