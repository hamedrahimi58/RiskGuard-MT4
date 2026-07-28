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

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);

   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,backColor);
   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrSilver);

   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);

   ObjectSetString(0,name,OBJPROP_TEXT,text);

   ObjectSetInteger(0,name,OBJPROP_BACK,false);

   //==================================================
   // IMPORTANT
   //==================================================
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);

   // Edit must NOT be hidden
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);

   // Edit must NOT be read only
   #ifdef OBJPROP_READONLY
      ObjectSetInteger(0,name,OBJPROP_READONLY,false);
   #endif

   // Keep object above panel
   ObjectSetInteger(0,name,OBJPROP_ZORDER,100);

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