
double parabola(double x) =>
    x < 0.5
        ? x / 0.5
        : (1.0 - ((x - 0.5) / 0.5));