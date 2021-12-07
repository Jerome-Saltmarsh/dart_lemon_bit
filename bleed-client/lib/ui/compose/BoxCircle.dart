import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BoxCircle extends StatelessWidget {

  final ValueNotifier<double> percentage;
  final double size;

  BoxCircle(this.size, this.percentage);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BoxPainter(percentage),
      ),
    );
  }
}

class _BoxPainter extends CustomPainter {
  final ValueNotifier<double> percentage;
  final Paint _paint = Paint();

  _BoxPainter(this.percentage) : super(repaint: percentage){
    _paint.color = Colors.white;
  }

  @override
  void paint(Canvas _canvas, Size _size) {
    _canvas.drawLine(Offset(0, 0), Offset(_size.width, _size.height), _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
