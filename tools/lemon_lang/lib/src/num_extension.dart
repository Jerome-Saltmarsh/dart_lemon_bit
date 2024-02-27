
extension NumExtension on num {

  double percentageOf(num that){
     if (that == 0) {
       return 0;
     }
     return this / that;
  }
}