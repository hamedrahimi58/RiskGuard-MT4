#ifndef __RG_INPUTAREA_MQH__
#define __RG_INPUTAREA_MQH__

#include <RG_Settings.mqh>
#include <Core/RG_Defines.mqh>

#include <GUI/RG_Label.mqh>
#include <GUI/RG_Edit.mqh>
#include <GUI/RG_Theme.mqh>

//====================================================
// Create Inputs
//====================================================

bool RG_CreateInputArea(
   int panelX,
   int panelY)
{

   //--------------------------------------------------
   // LOT
   //--------------------------------------------------

   RG_CreateLabel(
      RG_PREFIX+"LOT_LBL",
      "Lot",
      panelX + RG_PADDING,
      panelY + 70,
      RG_COLOR_TEXT,
      RG_FONT_LABEL_SIZE);

   RG_CreateEdit(
      RG_PREFIX+"LOT",
      DoubleToString(RG_RuntimeFixedLot(),2),
      panelX + 70,
      panelY + 67,
      RG_EDIT_WIDTH,
      RG_EDIT_HEIGHT,
      RG_COLOR_TEXT,
      RG_COLOR_EDIT_BG);

   //--------------------------------------------------
   // SL
   //--------------------------------------------------

   RG_CreateLabel(
      RG_PREFIX+"SL_LBL",
      "SL",
      panelX + RG_PADDING,
      panelY + 100,
      RG_COLOR_TEXT,
      RG_FONT_LABEL_SIZE);

   RG_CreateEdit(
      RG_PREFIX+"SL",
      IntegerToString(RG_RuntimeStopLoss()),
      panelX + 70,
      panelY + 97,
      RG_EDIT_WIDTH,
      RG_EDIT_HEIGHT,
      RG_COLOR_TEXT,
      RG_COLOR_EDIT_BG);

   //--------------------------------------------------
   // TP
   //--------------------------------------------------

   RG_CreateLabel(
      RG_PREFIX+"TP_LBL",
      "TP",
      panelX + RG_PADDING,
      panelY + 130,
      RG_COLOR_TEXT,
      RG_FONT_LABEL_SIZE);

   RG_CreateEdit(
      RG_PREFIX+"TP",
      IntegerToString(RG_RuntimeTakeProfit()),
      panelX + 70,
      panelY + 127,
      RG_EDIT_WIDTH,
      RG_EDIT_HEIGHT,
      RG_COLOR_TEXT,
      RG_COLOR_EDIT_BG);

   return(true);

}

//====================================================
// Delete Inputs
//====================================================

void RG_DeleteInputArea()
{

   RG_DeleteEdit(RG_PREFIX+"LOT");
   RG_DeleteEdit(RG_PREFIX+"SL");
   RG_DeleteEdit(RG_PREFIX+"TP");

   RG_DeleteLabel(RG_PREFIX+"LOT_LBL");
   RG_DeleteLabel(RG_PREFIX+"SL_LBL");
   RG_DeleteLabel(RG_PREFIX+"TP_LBL");

}

#endif