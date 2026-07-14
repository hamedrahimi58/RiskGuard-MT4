#ifndef __RG_GUI_MQH__
#define __RG_GUI_MQH__

#include <RG_Settings.mqh>

#include <Core/RG_Defines.mqh>

#include <GUI/RG_Panel.mqh>
#include <GUI/RG_Label.mqh>
#include <GUI/RG_Button.mqh>
#include <GUI/RG_Edit.mqh>

//====================================================
// Create Main GUI
//====================================================
bool RG_CreatePanel()
{
   //--------------------------------------------------
   // Panel
   //--------------------------------------------------
   if(!RG_CreatePanelObject(
      RG_PANEL_NAME,
      PanelX,
      PanelY,
      PanelWidth,
      PanelHeight,
      clrBlack))
      return(false);

   //--------------------------------------------------
   // Title
   //--------------------------------------------------
   RG_CreateLabel(
      RG_PREFIX+"TITLE",
      RG_NAME+" v"+RG_VERSION,
      PanelX+15,
      PanelY+10,
      clrWhite,
      11);

   //--------------------------------------------------
   // Status
   //--------------------------------------------------
   RG_CreateLabel(
      RG_PREFIX+"STATUS",
      "Status : READY",
      PanelX+15,
      PanelY+35,
      clrLime,
      10);

   //--------------------------------------------------
   // Lot
   //--------------------------------------------------
   RG_CreateLabel(
      RG_PREFIX+"LOT_LBL",
      "Lot",
      PanelX+15,
      PanelY+70,
      clrWhite,
      10);

   RG_CreateEdit(
      RG_PREFIX+"LOT",
      DoubleToString(FixedLot,2),
      PanelX+70,
      PanelY+67,
      90,
      20,
      clrWhite,
      clrBlack);

   //--------------------------------------------------
   // SL
   //--------------------------------------------------
   RG_CreateLabel(
      RG_PREFIX+"SL_LBL",
      "SL",
      PanelX+15,
      PanelY+100,
      clrWhite,
      10);

   RG_CreateEdit(
      RG_PREFIX+"SL",
      IntegerToString(StopLoss),
      PanelX+70,
      PanelY+97,
      90,
      20,
      clrWhite,
      clrBlack);

   //--------------------------------------------------
   // TP
   //--------------------------------------------------
   RG_CreateLabel(
      RG_PREFIX+"TP_LBL",
      "TP",
      PanelX+15,
      PanelY+130,
      clrWhite,
      10);

   RG_CreateEdit(
      RG_PREFIX+"TP",
      IntegerToString(TakeProfit),
      PanelX+70,
      PanelY+127,
      90,
      20,
      clrWhite,
      clrBlack);

   //--------------------------------------------------
   // BUY
   //--------------------------------------------------
   RG_CreateButton(
      RG_PREFIX+"BUY",
      "BUY",
      PanelX+180,
      PanelY+65,
      110,
      35,
      clrLime,
      clrBlack);

   //--------------------------------------------------
   // SELL
   //--------------------------------------------------
   RG_CreateButton(
      RG_PREFIX+"SELL",
      "SELL",
      PanelX+180,
      PanelY+110,
      110,
      35,
      clrRed,
      clrWhite);

   return(true);
}

//====================================================
// Delete GUI
//====================================================
void RG_DeletePanel()
{
   RG_DeleteButton(RG_PREFIX+"BUY");
   RG_DeleteButton(RG_PREFIX+"SELL");

   RG_DeleteEdit(RG_PREFIX+"LOT");
   RG_DeleteEdit(RG_PREFIX+"SL");
   RG_DeleteEdit(RG_PREFIX+"TP");

   RG_DeleteLabel(RG_PREFIX+"LOT_LBL");
   RG_DeleteLabel(RG_PREFIX+"SL_LBL");
   RG_DeleteLabel(RG_PREFIX+"TP_LBL");

   RG_DeleteLabel(RG_PREFIX+"TITLE");
   RG_DeleteLabel(RG_PREFIX+"STATUS");

   RG_DeletePanelObject(RG_PANEL_NAME);
}

#endif