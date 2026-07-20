#ifndef __RG_LABEL_V2_MQH__
#define __RG_LABEL_V2_MQH__

//====================================================
// Create Label
//====================================================
bool RG_CreateLabelV2(
   const string name,
   const string text,
   const int x,
   const int y,
   const color textColor,
   const int fontSize=10,
   const string fontName="Arial")
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);

   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
      return(false);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

   ObjectSetString(0,name,OBJPROP_TEXT,text);

   ObjectSetString(0,name,OBJPROP_FONT,fontName);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontSize);

   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);

   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);

   return(true);
}

//====================================================
// Delete Label
//====================================================
void RG_DeleteLabelV2(const string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);
}

//====================================================
// Set Label Text
//====================================================
void RG_SetLabelTextV2(
   const string name,
   const string text)
{
   if(ObjectFind(0,name)>=0)
      ObjectSetString(0,name,OBJPROP_TEXT,text);
}

//====================================================
// Set Label Color
//====================================================
void RG_SetLabelColorV2(
   const string name,
   const color textColor)
{
   if(ObjectFind(0,name)<0)
      return;

   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
}

//====================================================
// Show / Hide
//====================================================
void RG_ShowLabelV2(const string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
}

void RG_HideLabelV2(const string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
}

#endif