#ifndef __RG_WINDOW_MQH__
#define __RG_WINDOW_MQH__

//====================================================
// Create Window
//====================================================
bool RG_CreateWindow(
   const string name,
   const int x,
   const int y,
   const int width,
   const int height,
   const color backColor,
   const color borderColor=clrDimGray)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);

   if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
      return(false);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);

   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,backColor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,borderColor);

   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);

   return(true);
}

//====================================================
// Delete Window
//====================================================
void RG_DeleteWindow(const string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);
}

//====================================================
// Show Window
//====================================================
void RG_ShowWindow(const string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
}

//====================================================
// Hide Window
//====================================================
void RG_HideWindow(const string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
}

#endif