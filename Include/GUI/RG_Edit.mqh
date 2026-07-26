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
   if(ObjectFind(name)>=0)
      ObjectDelete(name);

   ResetLastError();

   if(!ObjectCreate(name,OBJ_EDIT,0,0,0))
   {
      Print("Create Edit Failed : ",name,
            " Error=",GetLastError());
      return(false);
   }

   ObjectSet(name,OBJPROP_XDISTANCE,x);
   ObjectSet(name,OBJPROP_YDISTANCE,y);

   ObjectSet(name,OBJPROP_XSIZE,width);
   ObjectSet(name,OBJPROP_YSIZE,height);

   ObjectSet(name,OBJPROP_BGCOLOR,backColor);
   ObjectSet(name,OBJPROP_COLOR,textColor);
   ObjectSet(name,OBJPROP_BORDER_COLOR,clrSilver);

   ObjectSetText(
      name,
      text,
      10,
      "Arial",
      textColor);

   ObjectSet(name,OBJPROP_BACK,false);
   ObjectSet(name,OBJPROP_HIDDEN,false);
   ObjectSet(name,OBJPROP_SELECTABLE,true);
   ObjectSet(name,OBJPROP_SELECTED,false);

   Print("Edit Created : ",name);

   return(true);
}

//====================================================
// Delete Edit
//====================================================
void RG_DeleteEdit(string name)
{
   if(ObjectFind(name)>=0)
      ObjectDelete(name);
}

//====================================================
// Get Text
//====================================================
string RG_GetEditText(string name)
{
   if(ObjectFind(name)<0)
      return("");

   return(ObjectGetString(0,name,OBJPROP_TEXT));
}

//====================================================
// Set Text
//====================================================
void RG_SetEditText(
   string name,
   string text)
{
   if(ObjectFind(name)>=0)
      ObjectSetString(0,name,OBJPROP_TEXT,text);
}

#endif