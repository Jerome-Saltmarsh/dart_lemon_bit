class NodeOrientation {
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

   static bool isSolid(int value) =>
       value == Solid;

   static bool isHalf(int value) =>
       valuesHalf.contains(value);

   static bool isSlopeCornerInner(int value) =>
       valuesSlopeCornerInner.contains(value);

   static bool isSlopeCornerOuter(int value) =>
       valuesSlopeCornerOuter.contains(value);

   static String getName(int value){
      return {
         None: "None",
         Slope_North: "Slope North",
         Slope_East: "Slope East",
         Slope_South: "Slope South",
         Slope_West: "Slope West",
         Corner_Top: "Corner Top",
         Corner_Right: "Corner Right",
         Corner_Bottom: "Corner Bottom",
         Corner_Left: "Corner Left",
         Solid: "Solid",
         Half_North: "Half North",
         Half_East: "Half East",
         Half_South: "Half South",
         Half_West: "Half West",
         Slope_Inner_North_East: "Slope Inner North-East",
         Slope_Inner_South_East: "Slope Inner South-East",
         Slope_Inner_South_West: "Slope Inner South-West",
         Slope_Inner_North_West: "Slope Inner North-West",
         Slope_Outer_North_East: "Slope Outer North-East",
         Slope_Outer_South_East: "Slope Outer South-East",
         Slope_Outer_South_West: "Slope Outer South-West",
         Slope_Outer_North_West: "Slope Outer North-West",

      }[value] ?? "unknown: $value";
   }
}