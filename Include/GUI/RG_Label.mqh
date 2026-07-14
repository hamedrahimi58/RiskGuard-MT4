//==================================================
// RiskGuard MT4
// File : RG_Label.mqh
//==================================================

#ifndef __RG_LABEL_MQH__
#define __RG_LABEL_MQH__

//--------------------------------------------------
// Create Label
//--------------------------------------------------
bool RG_CreateLabel(
   const string name,
   const string text,
   const int x,
   const int y,
   const color textColor,
   const int fontSize)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);

   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
      return(false);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontSize);

   ObjectSetString(0,name,OBJPROP_FONT,"Tahoma");
   ObjectSetString(0,name,OBJPROP_TEXT,text);

   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);

   return(true);
}

//--------------------------------------------------
// Delete Label
//--------------------------------------------------
void RG_DeleteLabel(const string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);
}

#endif