class InputMode {
  static const Touch = 0;
  static const Keyboard = 1;

  static String getName(int value){
    if (value == Touch) return 'touch';
    if (value == Keyboard) return 'keyboard';
    return 'unknown($value)';
  }
}