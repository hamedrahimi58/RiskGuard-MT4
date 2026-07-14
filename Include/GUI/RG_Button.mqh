//==================================================
// RiskGuard MT4
// RG_Button.mqh
//==================================================

#ifndef __RG_BUTTON_MQH__
#define __RG_BUTTON_MQH__

//--------------------------------------------------
bool RG_CreateButton(
   const string name,
   const string text,
   const int x,
   const int y,
   const int width,
   const int height,
   const color backColor,
   const color textColor)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);

   if(!ObjectCreate(0,name,OBJ_BUTTON,0,0,0))
      return(false);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);

   ObjectSetString(0,name,OBJPROP_TEXT,text);

   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);

   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,backColor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrBlack);

   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_STATE,false);

   ChartRedraw();

   return(true);
}

//--------------------------------------------------
void RG_DeleteButton(const string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);
}

#endif