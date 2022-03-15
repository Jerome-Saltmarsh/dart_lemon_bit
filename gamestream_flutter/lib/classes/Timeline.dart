class Timeline {
  int _frame = 0;
  int rate = 8;
  int frame = 1;

  void update(){
    _frame++;
    if (_frame % rate == 0){
      frame++;
    }
  }
}