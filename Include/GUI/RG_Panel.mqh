//==================================================
// RiskGuard MT4
// File : RG_Panel.mqh
//==================================================

#ifndef __RG_PANEL_MQH__
#define __RG_PANEL_MQH__

//--------------------------------------------------
// Create Panel
//--------------------------------------------------
bool RG_CreatePanelObject(
   const string name,
   const int x,
   const int y,
   const int width,
   const int height,
   const color backColor)
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
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);

   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);

   return(true);
}

//--------------------------------------------------
// Delete Panel
//--------------------------------------------------
void RG_DeletePanelObject(const string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);
}

#endif