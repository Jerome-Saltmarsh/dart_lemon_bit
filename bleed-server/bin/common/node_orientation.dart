

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
   static const Half_Row_1 = 10;
   static const Half_Row_2 = 11;
   static const Half_Column_1 = 12;
   static const Half_Column_2 = 13;
   static const Slope_Inner_South_West = 14;
   static const Slope_Inner_North_West = 15;
   static const Slope_Inner_North_East = 16;
   static const Slope_Inner_South_East = 17;
   static const Slope_Outer_South_West = 18;
   static const Slope_Outer_North_West = 19;
   static const Slope_Outer_North_East = 20;
   static const Slope_Outer_South_East = 21;
   
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
         Half_Row_1: "Half Row 1",
         Half_Row_2: "Half Row 2",
         Half_Column_1: "Half Column 1",
         Half_Column_2: "Half Column 2",
         Slope_Inner_North_East: "Slope Inner North East",
         Slope_Inner_South_East: "Slope Inner South East",
         Slope_Inner_South_West: "Slope Inner South West",
         Slope_Inner_North_West: "Slope Inner North West",
         Slope_Outer_North_East: "Slope Outer North East",
         Slope_Outer_South_East: "Slope Outer East",
         Slope_Outer_South_West: "Slope Outer West",
         Slope_Outer_North_West: "Slope Outer West",
         
      }[value] ?? "unknown: $value";
   }

   static const valuesSlopeSymetric = [
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
      Half_Row_1,
      Half_Row_2,
      Half_Column_1,
      Half_Column_2,
   ];

   static const valuesCorners = [
      Corner_Top,
      Corner_Right,
      Corner_Bottom,
      Corner_Left,
   ];

   static bool isSlope(int value) =>
      value == Slope_North ||
      value == Slope_East ||
      value == Slope_South ||
      value == Slope_West ;

   static bool isCorner(int value) =>
       value == Corner_Top ||
       value == Corner_Right ||
       value == Corner_Bottom ||
       value == Corner_Left ;
}