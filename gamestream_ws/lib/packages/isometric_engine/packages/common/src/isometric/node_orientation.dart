

class NodeOrientation {
   static const None = 0;
   static const Slope_North = 1;
   static const Slope_East = 2;
   static const Slope_South = 3;
   static const Slope_West = 4;
   static const Corner_North_West = 5;
   static const Corner_North_East = 6;
   static const Corner_South_East = 7;
   static const Corner_South_West = 8;
   static const Solid = 9;
   static const Half_North = 10;
   static const Half_East = 11;
   static const Half_South = 12;
   static const Half_West = 13;
   static const Slope_Inner_South_West = 14;
   static const Slope_Inner_North_West = 15;
   static const Slope_Inner_North_East = 16;
   static const Slope_Inner_South_East = 17;
   static const Slope_Outer_South_West = 18;
   static const Slope_Outer_North_West = 19;
   static const Slope_Outer_North_East = 20;
   static const Slope_Outer_South_East = 21;
   static const Respawning = 23;
   static const Radial = 26;
   static const Half_Vertical_Top = 27;
   static const Half_Vertical_Center = 28;
   static const Half_Vertical_Bottom = 29;
   static const Column_Top_Left = 30;
   static const Column_Top_Center = 31;
   static const Column_Top_Right = 32;
   static const Column_Center_Left = 33;
   static const Column_Center_Center = 34;
   static const Column_Center_Right = 35;
   static const Column_Bottom_Left = 36;
   static const Column_Bottom_Center = 37;
   static const Column_Bottom_Right = 38;

   static const valuesSlopeSymmetric = [
      Slope_North,
      Slope_East,
      Slope_South,
      Slope_West,
   ];

   static const valuesSlopeCornerInner = [
      Slope_Inner_North_East,
      Slope_Inner_South_East,
      Slope_Inner_South_West,
      Slope_Inner_North_West,
   ];

   static const valuesSlopeCornerOuter = [
      Slope_Outer_North_East,
      Slope_Outer_South_East,
      Slope_Outer_South_West,
      Slope_Outer_North_West,
   ];

   static const valuesHalf = [
      Half_North,
      Half_East,
      Half_South,
      Half_West,
   ];

   static const valuesCorners = [
      Corner_North_East,
      Corner_South_East,
      Corner_South_West,
      Corner_North_West,
   ];

   static const slopeSymmetric = [
     Slope_North,
     Slope_East,
     Slope_South,
     Slope_West,
   ];

   static bool isCorner(int value) =>
       value == Corner_North_East ||
       value == Corner_South_East ||
       value == Corner_South_West ||
       value == Corner_North_West ;

   static bool isEmpty(int value) =>
      value == None;

   static bool isSolid(int value) =>
       value == Solid;
   
   static bool isRadial(int value) =>
       value == Radial;

   static bool isHalf(int value) =>
       value == Half_North ||
       value == Half_East ||
       value == Half_South ||
       value == Half_West ;

   static bool isSlopeCornerInner(int value) =>
       value == Slope_Inner_North_East ||
       value == Slope_Inner_South_East ||
       value == Slope_Inner_South_West ||
       value == Slope_Inner_North_West ;

   static bool isSlopeCornerOuter(int value) =>
       value == Slope_Outer_North_East ||
       value == Slope_Outer_South_East ||
       value == Slope_Outer_South_West ||
       value == Slope_Outer_North_West ;

   
   static bool isHalfVertical(int value) =>
       value == Half_Vertical_Top      ||
       value == Half_Vertical_Bottom   ||
       value == Half_Vertical_Center    ;

   static bool isColumn(int value) =>
       value >= Column_Top_Left        &&
       value <= Column_Bottom_Right     ;


   static String getName(int value) => const {
      None: 'None',
      Slope_North: 'Slope North',
      Slope_East: 'Slope East',
         Slope_South: 'Slope South',
         Slope_West: 'Slope West',
         Corner_North_East: 'Corner Top',
         Corner_South_East: 'Corner Right',
         Corner_South_West: 'Corner Bottom',
         Corner_North_West: 'Corner Left',
         Solid: 'Solid',
         Half_North: 'Half North',
         Half_East: 'Half East',
         Half_South: 'Half South',
         Half_West: 'Half West',
         Slope_Inner_North_East: 'Slope Inner North-East',
         Slope_Inner_South_East: 'Slope Inner South-East',
         Slope_Inner_South_West: 'Slope Inner South-West',
         Slope_Inner_North_West: 'Slope Inner North-West',
         Slope_Outer_North_East: 'Slope Outer North-East',
         Slope_Outer_South_East: 'Slope Outer South-East',
         Slope_Outer_South_West: 'Slope Outer South-West',
         Slope_Outer_North_West: 'Slope Outer North-West',
         Radial: 'Radial',
         Half_Vertical_Top: 'Vertical Half Top',
         Half_Vertical_Center: 'Vertical Half Center',
         Half_Vertical_Bottom: 'Vertical Half Bottom',
         Column_Top_Left: 'Column Top Left',
         Column_Top_Center: 'Column Top Center',
         Column_Top_Right: 'Column Top Right',
         Column_Center_Left: 'Column Center Left',
         Column_Center_Center: 'Column Center Center',
         Column_Center_Right: 'Column Center Right',
         Column_Bottom_Left: 'Column Bottom Left',
         Column_Bottom_Center: 'Column Bottom Center',
         Column_Bottom_Right: 'Column Bottom Right',
   }[value] ?? 'unknown: $value';

   static double getGradient(int orientation, double x, double y) {
     switch (orientation) {
       case Solid:
         return 1.0;
       case Slope_North:
         return 1.0 - x;
       case Slope_East:
         return 1.0 - y;
       case Slope_South:
         return x;
       case Slope_West:
         return y;
       case Corner_North_East:
         if (x < 0.33) return 1.0;
         if (y < 0.33) return 1.0;
         return 0;
       case Corner_South_East:
         if (x > 0.66) return 1.0;
         if (y < 0.33) return 1.0;
         return 0;
       case Corner_South_West:
         if (x > 0.66) return 1.0;
         if (y > 0.66) return 1.0;
         return 0;
       case Corner_North_West:
         if (x < 0.33) return 1.0;
         if (y > 0.66) return 1.0;
         return 0;
       case Half_North:
         if (x < 0.33) return 1.0;
         return 0;
       case Half_East:
         if (y < 0.33) return 1.0;
         return 0;
       case Half_South:
         if (x > 0.66) return 1.0;
         return 0;
       case Half_West:
         if (y > 0.66) return 1.0;
         return 0;
       case Slope_Inner_North_East: // Grass Edge Bottom
         final total = x + y;
         if (total < 1) return 1;
         return 1 - (total - 1);
       case Slope_Inner_South_East: // Grass Edge Left
         final tX = (x - y);
         if (tX > 0) return 1;
         return 1 + tX;
       case Slope_Inner_South_West: // Grass Edge Top
         final total = x + y;
         if (total > 1) return 1;
         return total;
       case Slope_Inner_North_West: // Grass Edge Right
         final tX = (x - y);
         if (tX < 0) return 1;
         return 1 - tX;
       case Slope_Outer_North_East: // Grass Slope Top
         final total = x + y;
         if (total > 1) return 0;
         return 1.0 - total;
       case Slope_Outer_South_East: // Grass Slope Left
         final tX = (x - y);
         if (tX < 0) return 0;
         return tX;
       case Slope_Outer_South_West: // Grass Slope Bottom
         final total = x + y;
         if (total < 1) return 0;
         return total - 1;
       case Slope_Outer_North_West: // Grass Slope Right
         final ratio = (y - x);
         if (ratio < 0) return 0;
         return ratio;
       case Radial:
         const radius = 0.25;
         if  ((0.5 - x).abs() > radius) return 0;
         if  ((0.5 - y).abs() > radius) return 0;
         return 1.0;
       case Half_Vertical_Top:
         return 1.00;
       case Half_Vertical_Center:
         return 0.66;
       case Half_Vertical_Bottom:
         return 0.33;
       case Column_Top_Left:
         if (x > 0.33) return 0;
         if (y < 0.66) return 0;
         return 1;
       case Column_Top_Center:
         if (x > 0.33) return 0;
         if (y < 0.33) return 0;
         if (y > 0.66) return 0;
         return 1;
       case Column_Top_Right:
         if (x > 0.33) return 0;
         if (y > 0.33) return 0;
         return 1;
       case Column_Center_Right:
         if (x < 0.33) return 0;
         if (x > 0.66) return 0;
         if (y > 0.33) return 0;
         return 1;
       case Column_Center_Center:
         if (x < 0.33) return 0;
         if (y < 0.33) return 0;
         if (x > 0.66) return 0;
         if (y > 0.66) return 0;
         return 1;
       case Column_Center_Left:
         if (x < 0.33) return 0;
         if (x > 0.66) return 0;
         if (y < 0.66) return 0;
         return 1;
       case Column_Bottom_Right:
         if (x < 0.66) return 0;
         if (y > 0.33) return 0;
         return 1;
       case Column_Bottom_Center:
         if (x < 0.66) return 0;
         if (y < 0.33) return 0;
         if (y > 0.66) return 0;
         return 1;
       case Column_Bottom_Left:
         if (x < 0.66) return 0;
         if (y < 0.66) return 0;
         return 1;
       default:
         return 0;
     }
   }
}

