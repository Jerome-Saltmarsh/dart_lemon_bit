
class Positioned {
  double _x;
  double y;
  Positioned(this._x, this.y);

  double get x => _x;

  set x(double value){
    // if (value.isNaN){
    //   throw Exception();
    // }
    _x = value;
  }
}