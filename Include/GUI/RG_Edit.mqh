#ifndef __RG_EDIT_MQH__
#define __RG_EDIT_MQH__

//====================================================
// Create Edit Box
//====================================================
bool RG_CreateEdit(
   string name,
   string text,
   int x,
   int y,
   int width,
   int height,
   color backColor,
   color textColor)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);

   if(!ObjectCreate(0,name,OBJ_EDIT,0,0,0))
      return(false);

   //--------------------------------------------------
   // Position
   //--------------------------------------------------
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

   //--------------------------------------------------
   // Size
   //--------------------------------------------------
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);

   //--------------------------------------------------
   // Colors
   //--------------------------------------------------
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,backColor);
   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrSilver);

   //--------------------------------------------------
   // Font
   //--------------------------------------------------
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);

   //--------------------------------------------------
   // Text
   //--------------------------------------------------
   ObjectSetString(0,name,OBJPROP_TEXT,text);

   //--------------------------------------------------
   // Interactive Properties
   //--------------------------------------------------
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);

   ObjectSetInteger(0,name,OBJPROP_READONLY,false);

   ObjectSetInteger(0,name,OBJPROP_BACK,false);

   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);

   ObjectSetInteger(0,name,OBJPROP_ZORDER,0);

   ChartRedraw();

   return(true);
}

//====================================================
// Delete Edit Box
//====================================================
void RG_DeleteEdit(string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);
}

//====================================================
// Get Edit Text
//====================================================
string RG_GetEditText(string name)
{
   if(ObjectFind(0,name)<0)
      return("");

   return(ObjectGetString(0,name,OBJPROP_TEXT));
}

//====================================================
// Set Edit Text
//====================================================
void RG_SetEditText(
   string name,
   string text)
{
   if(ObjectFind(0,name)>=0)
      ObjectSetString(0,name,OBJPROP_TEXT,text);
}

#endif