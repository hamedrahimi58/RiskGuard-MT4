#ifndef __RG_GUI_V2_MQH__
#define __RG_GUI_V2_MQH__

#include "RG_Window.mqh"
#include "RG_Label.mqh"

//--------------------------------------------------
// Names
//--------------------------------------------------
#define RGV2_WINDOW   "RGV2_WINDOW"
#define RGV2_TITLE    "RGV2_TITLE"
#define RGV2_STATUS   "RGV2_STATUS"

//--------------------------------------------------
// Create GUI
//--------------------------------------------------
bool RG_CreateGUIV2(
   const int x,
   const int y,
   const int width,
   const int height)
{
   if(!RG_CreateWindow(
      RGV2_WINDOW,
      x,
      y,
      width,
      height,
      clrBlack))
      return(false);

   RG_CreateLabelV2(
      RGV2_TITLE,
      "RiskGuard",
      x+15,
      y+10,
      clrWhite,
      11);

   RG_CreateLabelV2(
      RGV2_STATUS,
      "Status : READY",
      x+15,
      y+35,
      clrLime,
      10);

   return(true);
}

//--------------------------------------------------
// Delete GUI
//--------------------------------------------------
void RG_DeleteGUIV2()
{
   RG_DeleteLabelV2(RGV2_TITLE);
   RG_DeleteLabelV2(RGV2_STATUS);

   RG_DeleteWindow(RGV2_WINDOW);
}

#endif