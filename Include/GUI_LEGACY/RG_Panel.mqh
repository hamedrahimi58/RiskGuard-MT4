#ifndef __RG_PANEL_MQH__
#define __RG_PANEL_MQH__

//====================================================
// Create Panel
//====================================================
bool RG_CreatePanelObject(
   string name,
   int x,
   int y,
   int width,
   int height,
   color backColor)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);

   if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
      return(false);

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);

   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,backColor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrDimGray);

   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);

   return(true);
}

//====================================================
// Delete Panel
//====================================================
void RG_DeletePanelObject(string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);
}

#endif