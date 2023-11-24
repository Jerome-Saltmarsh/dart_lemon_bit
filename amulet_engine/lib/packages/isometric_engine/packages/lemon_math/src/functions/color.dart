

int aRGBToColor(int alpha, int red, int green, int blue) =>
    (alpha & 0xff) << 24 |
    (red & 0xff) << 16 |
    (green & 0xff) << 8 |
    (blue & 0xff);

int setAlpha({required int color, required int alpha}) {
    assert (alpha >= 0 && alpha <= 255);
    return (color & 0x00FFFFFF) | (alpha << 24);
}

int getAlpha(int color) => (color & 0xFF000000) >> 24;

int getRed(int color) => (color & 0x00FF0000) >> 16;

int getGreen(int color) => (color & 0x0000FF00) >> 8;

int getBlue(int color) => color & 0x000000FF;

int getRGB(int color) =>
    (getRed(color) << 16) |
    (getGreen(color) << 8) |
    getBlue(color);





