#ifndef RG_GUI_MQH
#define RG_GUI_MQH

#include <Core/RG_Defines.mqh>

#include <GUI/RG_Theme.mqh>
#include <GUI/RG_Layout.mqh>

#include <GUI/RG_Panel.mqh>
#include <GUI/RG_Label.mqh>
#include <GUI/RG_Button.mqh>
#include <GUI/RG_Edit.mqh>

//====================================================
// Create Main GUI
//====================================================
bool RG_CreatePanel()
{
  Print("NEW GUI LOADED");
  
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
   // LOT
   //=============================
   if(!RG_CreateLabel(
      RG_PREFIX + "LBL_LOT",
      "Lot :",
      RG_MARGIN + 15,
      RG_MARGIN + 70,
      clrWhite,
      10))
      return(false);

   if(!RG_CreateEdit(
      RG_PREFIX + "LOT",
      "0.01",
      RG_MARGIN + 70,
      RG_MARGIN + 67,
      80,
      20,
      clrWhite,
      clrBlack))
      return(false);

   //=============================
   // SL
   //=============================
   if(!RG_CreateLabel(
      RG_PREFIX + "LBL_SL",
      "SL :",
      RG_MARGIN + 15,
      RG_MARGIN + 100,
      clrWhite,
      10))
      return(false);

   if(!RG_CreateEdit(
      RG_PREFIX + "SL",
      "200",
      RG_MARGIN + 70,
      RG_MARGIN + 97,
      80,
      20,
      clrWhite,
      clrBlack))
      return(false);

   //=============================
   // TP
   //=============================
   if(!RG_CreateLabel(
      RG_PREFIX + "LBL_TP",
      "TP :",
      RG_MARGIN + 15,
      RG_MARGIN + 130,
      clrWhite,
      10))
      return(false);

   if(!RG_CreateEdit(
      RG_PREFIX + "TP",
      "400",
      RG_MARGIN + 70,
      RG_MARGIN + 127,
      80,
      20,
      clrWhite,
      clrBlack))
      return(false);

   //=============================
   // Risk
   //=============================
   if(!RG_CreateLabel(
      RG_PREFIX + "LBL_RISK",
      "Risk :",
      RG_MARGIN + 15,
      RG_MARGIN + 160,
      clrWhite,
      10))
      return(false);

   if(!RG_CreateEdit(
      RG_PREFIX + "RISK",
      "1.0",
      RG_MARGIN + 70,
      RG_MARGIN + 157,
      80,
      20,
      clrWhite,
      clrBlack))
      return(false);

   //=============================
   // BUY
   //=============================
   if(!RG_CreateButton(
      RG_PREFIX + "BUY",
      "BUY",
      RG_MARGIN + 170,
      RG_MARGIN + 70,
      100,
      35,
      RG_COLOR_BUY,
      clrBlack))
      return(false);

   //=============================
   // SELL
   //=============================
   if(!RG_CreateButton(
      RG_PREFIX + "SELL",
      "SELL",
      RG_MARGIN + 170,
      RG_MARGIN + 120,
      100,
      35,
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

   RG_DeleteEdit(RG_PREFIX + "LOT");
   RG_DeleteEdit(RG_PREFIX + "SL");
   RG_DeleteEdit(RG_PREFIX + "TP");
   RG_DeleteEdit(RG_PREFIX + "RISK");

   RG_DeleteLabel(RG_PREFIX + "LBL_LOT");
   RG_DeleteLabel(RG_PREFIX + "LBL_SL");
   RG_DeleteLabel(RG_PREFIX + "LBL_TP");
   RG_DeleteLabel(RG_PREFIX + "LBL_RISK");

   RG_DeleteLabel(RG_PREFIX + "TITLE");
   RG_DeleteLabel(RG_PREFIX + "STATUS");

   RG_DeletePanelObject(RG_PANEL_NAME);
}

#endif