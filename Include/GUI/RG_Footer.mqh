#ifndef __RG_FOOTER_MQH__
#define __RG_FOOTER_MQH__

#include <Core/RG_Defines.mqh>
#include <RG_Settings.mqh>

#include <GUI/RG_Label.mqh>
#include <GUI/RG_Theme.mqh>

//====================================================
// Create Footer
//====================================================

bool RG_CreateFooter(
   int panelX,
   int panelY)
{

   RG_CreateLabel(
      RG_PREFIX+"FOOTER_SYMBOL",
      "Symbol : ---",
      panelX + RG_PADDING,
      panelY + 195,
      RG_COLOR_TEXT,
      9);

   RG_CreateLabel(
      RG_PREFIX+"FOOTER_SPREAD",
      "Spread : ---",
      panelX + RG_PADDING,
      panelY + 210,
      RG_COLOR_TEXT,
      9);

   RG_CreateLabel(
      RG_PREFIX+"FOOTER_OPEN",
      "Open : 0 / "+IntegerToString(MaxOpenPositions),
      panelX + 150,
      panelY + 195,
      RG_COLOR_TEXT,
      9);

   RG_CreateLabel(
      RG_PREFIX+"FOOTER_LOT",
      "Max Lot : "+DoubleToString(MaxLot,2),
      panelX + 150,
      panelY + 210,
      RG_COLOR_TEXT,
      9);

   return(true);

}

//====================================================
// Refresh Footer
//====================================================

void RG_UpdateFooter()
{

   string symbol = Symbol();

   int spread = (int)MarketInfo(symbol,MODE_SPREAD);

   RG_SetLabelText(
      RG_PREFIX+"FOOTER_SYMBOL",
      "Symbol : "+symbol);

   RG_SetLabelText(
      RG_PREFIX+"FOOTER_SPREAD",
      "Spread : "+IntegerToString(spread));

   RG_SetLabelText(
      RG_PREFIX+"FOOTER_OPEN",
      "Open : "+
      IntegerToString(OrdersTotal())+
      " / "+
      IntegerToString(MaxOpenPositions));

}

//====================================================
// Delete Footer
//====================================================

void RG_DeleteFooter()
{

   RG_DeleteLabel(RG_PREFIX+"FOOTER_SYMBOL");
   RG_DeleteLabel(RG_PREFIX+"FOOTER_SPREAD");
   RG_DeleteLabel(RG_PREFIX+"FOOTER_OPEN");
   RG_DeleteLabel(RG_PREFIX+"FOOTER_LOT");

}

#endif