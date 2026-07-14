#ifndef RG_GUI_MQH
#define RG_GUI_MQH

#include <Core/RG_Defines.mqh>

#include <GUI/RG_Theme.mqh>
#include <GUI/RG_Layout.mqh>

#include <GUI/RG_Panel.mqh>
#include <GUI/RG_Label.mqh>
#include <GUI/RG_Button.mqh>

//====================================================
// Create Main GUI
//====================================================
bool RG_CreatePanel()
{
   //=============================
   // Main Panel
   //=============================
   if(!RG_CreatePanelObject(
      RG_PANEL_NAME,
      RG_MARGIN,
      RG_MARGIN,
      RG_PANEL_WIDTH,
      RG_PANEL_HEIGHT,
      RG_COLOR_PANEL))
      return(false);

   //=============================
   // Title
   //=============================
   if(!RG_CreateLabel(
      RG_PREFIX + "TITLE",
      RG_NAME,
      RG_MARGIN + 15,
      RG_MARGIN + 10,
      RG_COLOR_TITLE,
      12))
      return(false);

   //=============================
   // Status
   //=============================
   if(!RG_CreateLabel(
      RG_PREFIX + "STATUS",
      "Status : READY",
      RG_MARGIN + 15,
      RG_MARGIN + 35,
      RG_COLOR_SUCCESS,
      10))
      return(false);

   //=============================
   // BUY
   //=============================
   if(!RG_CreateButton(
      RG_PREFIX + "BUY",
      "BUY",
      RG_MARGIN + 15,
      RG_MARGIN + 70,
      90,
      30,
      RG_COLOR_BUY,
      clrBlack))
      return(false);

   //=============================
   // SELL
   //=============================
   if(!RG_CreateButton(
      RG_PREFIX + "SELL",
      "SELL",
      RG_MARGIN + 115,
      RG_MARGIN + 70,
      90,
      30,
      RG_COLOR_SELL,
      clrWhite))
      return(false);

   return(true);
}

//====================================================
// Delete GUI
//====================================================
void RG_DeletePanel()
{
   RG_DeleteButton(RG_PREFIX + "BUY");
   RG_DeleteButton(RG_PREFIX + "SELL");

   RG_DeleteLabel(RG_PREFIX + "TITLE");
   RG_DeleteLabel(RG_PREFIX + "STATUS");

   RG_DeletePanelObject(RG_PANEL_NAME);
}

#endif