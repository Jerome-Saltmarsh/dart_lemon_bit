
const targetSize = 0.4224;
const double manSize = 64.0;
const double manStrikeSize = 96.0;
const manScale = 0.66;
const manRenderSize = manSize * manScale;
const manRenderStrikeSize = manStrikeSize * manScale;
const manRenderStrikeSizeHalf = manStrikeSize * manScale * 0.5;
const manRenderSizeHalf = manRenderSize * 0.5;

// scale
// 0.64 * 0.66 == 0.4224
// 0.98 * X == 0.4224
// X = 0.4224 / 0.98
// X = 0.44936

// 0.4224


double calculateScale(double size){
  return targetSize / size;
}