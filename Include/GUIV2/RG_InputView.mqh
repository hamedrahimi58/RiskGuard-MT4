#ifndef __RG_INPUT_VIEW_MQH__
#define __RG_INPUT_VIEW_MQH__

//====================================================
// Create Input
//====================================================
bool RG_CreateInputV2(
   const string name,
   const string text,
   const int x,
   const int y,
   const int width,
   const int height,
   const color backColor=clrWhite,
   const color textColor=clrBlack)
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
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrDimGray);

   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);

   ObjectSetString(0,name,OBJPROP_TEXT,text);

   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);

   return(true);
}

//====================================================
// Delete Input
//====================================================
void RG_DeleteInputV2(const string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);
}

//====================================================
// Set Text
//====================================================
void RG_SetInputTextV2(
   const string name,
   const string text)
{
   if(ObjectFind(0,name)>=0)
      ObjectSetString(0,name,OBJPROP_TEXT,text);
}

//====================================================
// Get Text
//====================================================
string RG_GetInputTextV2(const string name)
{
   if(ObjectFind(0,name)<0)
      return("");

   return(ObjectGetString(0,name,OBJPROP_TEXT));
}

//====================================================
// Set Position
//====================================================
void RG_SetInputPositionV2(
   const string name,
   const int x,
   const int y)
{
   if(ObjectFind(0,name)<0)
      return;

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
}

//====================================================
// Set Size
//====================================================
void RG_SetInputSizeV2(
   const string name,
   const int width,
   const int height)
{
   if(ObjectFind(0,name)<0)
      return;

   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
}

//====================================================
// Show / Hide
//====================================================
void RG_ShowInputV2(const string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
}

void RG_HideInputV2(const string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
}

//====================================================
// Enable / Disable
//====================================================
void RG_EnableInputV2(const string name,bool enable=true)
{
   if(ObjectFind(0,name)<0)
      return;

   ObjectSetInteger(0,name,OBJPROP_READONLY,!enable);
}

#endif // __RG_INPUT_VIEW_MQH__