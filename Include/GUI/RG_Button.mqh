#ifndef __RG_BUTTON_MQH__
#define __RG_BUTTON_MQH__

#include <GUI/RG_Theme.mqh>

//====================================================
// Create Button
//====================================================

bool RG_CreateButton(
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

   if(!ObjectCreate(
      0,
      name,
      OBJ_BUTTON,
      0,
      0,
      0))
      return(false);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_XDISTANCE,
      x);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_YDISTANCE,
      y);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_XSIZE,
      width);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_YSIZE,
      height);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_BGCOLOR,
      backColor);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_COLOR,
      textColor);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_BORDER_COLOR,
      RG_COLOR_BORDER);

   //--------------------------------------------------
   // Project Theme Font
   //--------------------------------------------------

   ObjectSetString(
      0,
      name,
      OBJPROP_FONT,
      RG_FONT_NAME);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_FONTSIZE,
      RG_FONT_BUTTON_SIZE);

   ObjectSetString(
      0,
      name,
      OBJPROP_TEXT,
      text);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_SELECTABLE,
      true);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_SELECTED,
      false);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_HIDDEN,
      true);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_BACK,
      false);

   return(true);
}


//====================================================
// Delete Button
//====================================================

void RG_DeleteButton(string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);
}


//====================================================
// Set Button Text
//====================================================

void RG_SetButtonText(
   string name,
   string text)
{
   if(ObjectFind(0,name)>=0)
   {
      ObjectSetString(
         0,
         name,
         OBJPROP_TEXT,
         text);
   }
}


//====================================================
// Enable / Disable Button
//====================================================

void RG_EnableButton(
   string name,
   bool enable)
{
   if(ObjectFind(0,name)>=0)
   {
      ObjectSetInteger(
         0,
         name,
         OBJPROP_STATE,
         false);

      ObjectSetInteger(
         0,
         name,
         OBJPROP_HIDDEN,
         !enable);
   }
}

#endif