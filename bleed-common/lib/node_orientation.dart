class NodeOrientation {
   /// none collidable nodes such as empty space and rain
   static const None = 0;
   static const Slope_North = 1;
   static const Slope_East = 2;
   static const Slope_South = 3;
   static const Slope_West = 4;
   static const Corner_Left = 5;
   static const Corner_Top = 6;
   static const Corner_Right = 7;
   static const Corner_Bottom = 8;
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
   static const Destroyed = 22;
   static const Respawning = 23;
   static const Tree_Top = 24;
   static const Tree_Bottom = 25;
   static const Radial = 26;

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
      Corner_Top,
      Corner_Right,
      Corner_Bottom,
      Corner_Left,
   ];

   static bool isSlopeSymmetric(int value) =>
       valuesSlopeSymmetric.contains(value);

   static bool isCorner(int value) =>
       valuesCorners.contains(value);

   static bool isEmpty(int value) =>
      value == None;

   static bool isSolid(int value) =>
       value == Solid;

   static bool isHalf(int value) =>
       valuesHalf.contains(value);

   static bool isSlopeCornerInner(int value) =>
       valuesSlopeCornerInner.contains(value);

   static bool isSlopeCornerOuter(int value) =>
       valuesSlopeCornerOuter.contains(value);

   static String getName(int value) => {
         None: 'None',
         Slope_North: 'Slope North',
         Slope_East: 'Slope East',
         Slope_South: 'Slope South',
         Slope_West: 'Slope West',
         Corner_Top: 'Corner Top',
         Corner_Right: 'Corner Right',
         Corner_Bottom: 'Corner Bottom',
         Corner_Left: 'Corner Left',
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
   }[value] ?? 'unknown: $value';

   static double getGradient(int orientation, double x, double y) {
     switch (orientation) {
       case Solid:
         return 1;
       case Radial:
         const radius = 0.25;
         if  ((0.5 - x).abs() > radius) return 0;
         if  ((0.5 - y).abs() > radius) return 0;
         return 1.0;
       case Slope_North:
         return 1 - x;
       case Slope_East:
         return 1 - y;
       case Slope_South:
         return x;
       case Slope_West:
         return y;
       case Corner_Top:
         if (x < 0.5) return 1.0;
         if (y < 0.5) return 1.0;
         return 0;
       case Corner_Right:
         if (x > 0.5) return 1.0;
         if (y < 0.5) return 1.0;
         return 0;
       case Corner_Bottom:
         if (x > 0.5) return 1.0;
         if (y > 0.5) return 1.0;
         return 0;
       case Corner_Left:
         if (x < 0.5) return 1.0;
         if (y > 0.5) return 1.0;
         return 0;
       case Half_North:
         if (x < 0.5) return 1.0;
         return 0;
       case Half_East:
         if (y < 0.5) return 1.0;
         return 0;
       case Half_South:
         if (x > 0.5) return 1.0;
         return 0;
       case Half_West:
         if (y > 0.5) return 1.0;
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
       default:
         throw Exception(
             'node_orientation.getGradient(orientation: ${getName(orientation)}, x: $x, y: $y'
         );
     }
   }
}

