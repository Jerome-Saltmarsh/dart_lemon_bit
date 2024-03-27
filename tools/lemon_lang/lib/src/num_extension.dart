
extension NumExtension on num {

  double percentageOf(num that){
     if (that == 0) {
       return 0;
     }
     return this / that;
  }

  T atLeast<T extends num>(T value){
    if (T is double){
      return value < this ? toDouble() as T: value;
    }
    if (T is int){
      return value < this ? toInt() as T: value;
    }
    return value < this ? this as T : value;
  }

  T atMost<T extends num>(T value){
    if (T is double){
      return value > this ? toDouble() as T: value;
    }
    if (T is int){
      return value > this ? toInt() as T: value;
    }
    return value > this ? this as T : value;
  }

  String get toStringSigned => this > 0 ? '+$this' : this.toString();
}