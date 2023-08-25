
class TeamsRockPaperScissors {
  static const Rock        = 0;
  static const Paper       = 1;
  static const Scissors    = 2;
  
  static String getName(int value){
    return {
       Rock: 'Rock',
       Paper: 'Paper',
       Scissors: 'Scissors',
    } [value] ?? '?';
  }
}