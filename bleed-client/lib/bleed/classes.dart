import 'dart:ui';

class SpriteSheet {
  int frames;
  int columns;
  int rows;
  Image image;
  List<Rect> _rects;
  double _frameWidth;
  double _frameHeight;

  double get frameWidth => _frameWidth;
  double get frameHeight => _frameHeight;

  Rect getRect(int frame) => _rects[frame];

  SpriteSheet(this.frames, this.image, this.columns, this.rows) {
    _frameWidth = image.width / columns;
    _frameHeight = image.height / rows;
    _rects = [];
    for(int row = 0; row < rows; row++){
      for(int column = 0; column < columns; column++){
        _rects.add(Rect.fromLTWH(
          column * _frameWidth, row * _frameHeight, _frameWidth, _frameHeight));
      }
    }
  }
}

class SpriteAnimation {
  SpriteSheet sprite;
  int currentFrame = 0;
  double x;
  double y;
  double scale;

  Rect get rect => sprite.getRect(currentFrame);
  bool get finished => currentFrame >= sprite.frames;

  SpriteAnimation(this.sprite, this.x, this.y, {this.scale = 1.0});

  void nextFrame(){
    currentFrame++;
  }
}
