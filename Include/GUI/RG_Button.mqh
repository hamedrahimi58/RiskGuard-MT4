#ifndef __RG_BUTTON_MQH__
#define __RG_BUTTON_MQH__

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

   if(!ObjectCreate(0,name,OBJ_BUTTON,0,0,0))
      return(false);

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);

   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,backColor);
   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);

   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrDimGray);

   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);

   ObjectSetString(0,name,OBJPROP_TEXT,text);

   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);

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
void RG_SetButtonText(string name,string text)
{
   if(ObjectFind(0,name)>=0)
      ObjectSetString(0,name,OBJPROP_TEXT,text);
}

//====================================================
// Enable / Disable Button
//====================================================
void RG_EnableButton(string name,bool enable)
{
   if(ObjectFind(0,name)>=0)
      ObjectSetInteger(0,name,OBJPROP_STATE,false);
}

#endif