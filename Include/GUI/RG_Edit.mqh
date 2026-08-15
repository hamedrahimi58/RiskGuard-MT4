#ifndef __RG_EDIT_MQH__
#define __RG_EDIT_MQH__

#include <GUI/RG_Theme.mqh>

#define RG_EDIT_ZORDER 60000

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
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,RG_COLOR_BORDER);

   ObjectSetString(0,name,OBJPROP_FONT,RG_FONT_NAME);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,RG_FONT_LABEL_SIZE);
   ObjectSetInteger(0,name,OBJPROP_ALIGN,ALIGN_LEFT);
   ObjectSetString(0,name,OBJPROP_TEXT,text);

   // OBJ_EDIT must be selectable/selected so MT4 can give it keyboard focus.
   ObjectSetInteger(0,name,OBJPROP_READONLY,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,RG_EDIT_ZORDER);

   return(true);
}

void RG_DeleteEdit(string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);
}

string RG_GetEditText(string name)
{
   if(ObjectFind(0,name)<0)
      return("");

   return(ObjectGetString(0,name,OBJPROP_TEXT));
}

void RG_SetEditText(string name,string text)
{
   if(ObjectFind(0,name)>=0)
      ObjectSetString(0,name,OBJPROP_TEXT,text);
}

#endif
