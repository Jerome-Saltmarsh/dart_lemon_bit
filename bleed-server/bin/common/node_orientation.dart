

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
   static const Row_1 = 10;
   static const Row_2 = 11;
   static const Column_1 = 12;
   static const Column_2 = 13;
   static const South_West_Inner = 14;
   static const North_West_Inner = 15;
   static const North_East_Inner = 16;
   static const South_East_Inner = 17;
   static const South_West_Outer = 18;
   static const North_West_Outer = 19;
   static const North_East_Outer = 20;
   static const South_East_Outer = 21;
   
   static String getName(int value){
      return {
         None: "None",
         Slope_North: "North",
         Slope_East: "East",
         Slope_South: "South",
         Slope_West: "West",
         Corner_Top: "Corner Top",
         Corner_Right: "Corner Right",
         Corner_Bottom: "Corner Bottom",
         Corner_Left: "Corner Left",
         Solid: "Solid",
         Row_1: "Row 1",
         Row_2: "Row 2",
         Column_1: "Column 1",
         Column_2: "Column 2",
         North_East_Inner: "North East Inner",
         South_East_Inner: "South East Inner",
         South_West_Inner: "South West Inner",
         North_West_Inner: "North West Inner",
         North_East_Outer: "North East Outer",
         South_East_Outer: "South East Outer",
         South_West_Outer: "South West Outer",
         North_West_Outer: "North West Outer",
         
      }[value] ?? "unknown: $value";
   }

   static const valuesSlopeSymetric = [
      Slope_North,
      Slope_East,
      Slope_South,
      Slope_West,
   ];

   static const valuesSlopeCornerInner = [
      North_East_Inner,
      South_East_Inner,
      South_West_Inner,
      North_West_Inner,
   ];

   static const valuesSlopeCornerOuter = [
      North_East_Outer,
      South_East_Outer,
      South_West_Outer,
      North_West_Outer,
   ];

   static const valuesHalf = [
     Row_1,
     Row_2,
     Column_1,
     Column_2,
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