import '../classes.dart';
import '../constants.dart';
import '../enums.dart';
import '../enums/GameEventType.dart';
import '../maths.dart';
import '../settings.dart';
import '../utils.dart';
import 'setCharacterState.dart';

void updateCharacter(Character character) {
  character.x += character.xv;
  character.y += character.yv;
  character.xv *= velocityFriction;
  character.yv *= velocityFriction;

  if (character.y < tilesLeftY) {
    if (-character.x > character.y) {
      character.x = -character.y;
      character.y++;
    } else if (character.x > character.y) {
      character.x = character.y;
      character.y++;
    }
  } else {
    if (character.x > 0) {
      double m = tilesRightX + tilesRightX;
      double d = character.x + character.y;
      if (d > m) {
        character.x = m - character.y;
        character.y--;
      }
    }else{
      double m = tilesRightX + tilesRightX;
      double d = -character.x + character.y;
      if (d > m) {
        character.x = -(m - character.y);
        character.y--;
      }
    }
  }

  switch (character.state) {
    case CharacterState.ChangingWeapon:
      character.stateDuration--;
      if (character.stateDuration <= 0) {
        setCharacterState(character, CharacterState.Aiming);
      }
      break;
    case CharacterState.Aiming:
      if (character.accuracy > 0.05) {
        character.accuracy -= 0.005;
      }
      break;
    case CharacterState.Firing:
      character.stateDuration--;
      if (character.stateDuration <= 0) {
        setCharacterState(character, CharacterState.Aiming);
      }
      break;
    case CharacterState.Reloading:
      character.stateDuration--;
      if (character.stateDuration <= 0) {
        setCharacterState(character, CharacterState.Aiming);
        (character as Player).handgunAmmunition.rounds =
            character.handgunAmmunition.clipSize;
        dispatch(GameEventType.Reloaded, character.x, character.y, 0, 0);
      }
      break;
    case CharacterState.Walking:
      switch (character.direction) {
        case Direction.Up:
          character.y -= character.speed;
          break;
        case Direction.UpRight:
          character.x += velX(piQuarter, character.speed);
          character.y += velY(piQuarter, character.speed);
          break;
        case Direction.Right:
          character.x += character.speed;
          break;
        case Direction.DownRight:
          character.x += velX(piQuarter, character.speed);
          character.y -= velY(piQuarter, character.speed);
          break;
        case Direction.Down:
          character.y += character.speed;
          break;
        case Direction.DownLeft:
          character.x -= velX(piQuarter, character.speed);
          character.y -= velY(piQuarter, character.speed);
          break;
        case Direction.Left:
          character.x -= character.speed;
          break;
        case Direction.UpLeft:
          character.x -= velX(piQuarter, character.speed);
          character.y += velY(piQuarter, character.speed);
          break;
      }
      break;
    case CharacterState.Running:
      double runRatio = character.speed * (1.0 + goldenRatioInverse);
      switch (character.direction) {
        case Direction.Up:
          character.y -= runRatio;
          break;
        case Direction.UpRight:
          character.x += velX(piQuarter, runRatio);
          character.y += velY(piQuarter, runRatio);
          break;
        case Direction.Right:
          character.x += runRatio;
          break;
        case Direction.DownRight:
          character.x += velX(piQuarter, runRatio);
          character.y -= velY(piQuarter, runRatio);
          break;
        case Direction.Down:
          character.y += runRatio;
          break;
        case Direction.DownLeft:
          character.x -= velX(piQuarter, runRatio);
          character.y -= velY(piQuarter, runRatio);
          break;
        case Direction.Left:
          character.x -= runRatio;
          break;
        case Direction.UpLeft:
          character.x -= velX(piQuarter, runRatio);
          character.y += velY(piQuarter, runRatio);
          break;
      }
      break;
  }
}
