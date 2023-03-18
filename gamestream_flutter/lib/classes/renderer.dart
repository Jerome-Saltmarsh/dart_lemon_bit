abstract class Renderer {
  var _index = 0;
  var total = 0;
  var order = 0.0;
  var orderZ = 0;
  var remaining = true;

  void renderFunction();
  void updateFunction();
  int getTotal();

  int get index => _index;

  void reset(){
    total = getTotal();
    _index = 0;
    remaining = total > 0;
    if (remaining){
      updateFunction();
    }
  }

  @override
  String toString(){
    return "$order: $order, orderZ: $orderZ, index: $_index, total: $total";
  }

  Renderer compare(Renderer that){
    if (orderZ < that.orderZ) return this;
    if (orderZ > that.orderZ) return that;
    if (order < that.order) return this;
    return that;
  }

  bool before(Renderer that){
    final thatOrderZ = that.orderZ;
    // if (orderZ < thatOrderZ) return true;
    if (orderZ > thatOrderZ) return false;
    return order < that.order;
  }

  void set index(int value){
    _index = value;
    if (value >= total) {
      remaining = false;
    }
  }

  void end(){
    index = total;
    remaining = false;
  }


  void renderNext() {
    renderFunction();
    _index++;
    if (_index >= total) {
      remaining = false;
      return;
    }
    updateFunction();
  }
}
