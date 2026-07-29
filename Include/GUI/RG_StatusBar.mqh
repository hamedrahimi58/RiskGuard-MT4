#ifndef __RG_STATUSBAR_MQH__
#define __RG_STATUSBAR_MQH__

#include <GUI/RG_Label.mqh>
#include <GUI/RG_Theme.mqh>
#include <Core/RG_Defines.mqh>

//====================================================
// Create Status Bar
//====================================================
bool RG_CreateStatusBar(
   int panelX,
   int panelY)
{
   return RG_CreateLabel(
      RG_PREFIX+"STATUS",
      "Status : READY",
      panelX + RG_PADDING,
      panelY + 35,
      RG_COLOR_SUCCESS,
      RG_FONT_STATUS_SIZE);
}

//====================================================
// READY
//====================================================
void RG_StatusReady()
{
   RG_SetLabelText(
      RG_PREFIX+"STATUS",
      "Status : READY");

   ObjectSetInteger(
      0,
      RG_PREFIX+"STATUS",
      OBJPROP_COLOR,
      RG_COLOR_SUCCESS);
}

//====================================================
// BUY
//====================================================
void RG_StatusBuying()
{
   RG_SetLabelText(
      RG_PREFIX+"STATUS",
      "Status : Sending BUY...");

   ObjectSetInteger(
      0,
      RG_PREFIX+"STATUS",
      OBJPROP_COLOR,
      RG_COLOR_WARNING);
}

//====================================================
// SELL
//====================================================
void RG_StatusSelling()
{
   RG_SetLabelText(
      RG_PREFIX+"STATUS",
      "Status : Sending SELL...");

   ObjectSetInteger(
      0,
      RG_PREFIX+"STATUS",
      OBJPROP_COLOR,
      RG_COLOR_WARNING);
}

//====================================================
// ERROR
//====================================================
void RG_StatusError(string text)
{
   RG_SetLabelText(
      RG_PREFIX+"STATUS",
      text);

   ObjectSetInteger(
      0,
      RG_PREFIX+"STATUS",
      OBJPROP_COLOR,
      RG_COLOR_ERROR);
}

//====================================================
// SUCCESS
//====================================================
void RG_StatusSuccess(string text)
{
   RG_SetLabelText(
      RG_PREFIX+"STATUS",
      text);

   ObjectSetInteger(
      0,
      RG_PREFIX+"STATUS",
      OBJPROP_COLOR,
      RG_COLOR_SUCCESS);
}

//====================================================
// Delete
//====================================================
void RG_DeleteStatusBar()
{
   RG_DeleteLabel(RG_PREFIX+"STATUS");
}

#endif