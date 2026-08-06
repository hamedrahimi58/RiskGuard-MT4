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
      RG_PREFIX+"FOOTER_PROFIT",
      "P/L : $0.00",
      panelX + 150,
      panelY + 210,
      RG_COLOR_TEXT,
      9);

   return(true);
}


//====================================================
// Floating Profit
//====================================================

double RG_GetFloatingProfit()
{
   double total=0;

   for(int i=OrdersTotal()-1;
       i>=0;
       i--)
   {
      if(!OrderSelect(
         i,
         SELECT_BY_POS,
         MODE_TRADES))
         continue;

      if(OrderSymbol()!=Symbol())
         continue;

      if(OrderType()!=OP_BUY &&
         OrderType()!=OP_SELL)
         continue;

      total+=OrderProfit();
      total+=OrderSwap();
      total+=OrderCommission();
   }

   return(total);
}


//====================================================
// Profit Text
//====================================================

string RG_GetProfitText(
   double value)
{
   if(value>=0)
   {
      return(
         "+$"
         +DoubleToString(
            value,
            2));
   }

   return(
      "-$"
      +DoubleToString(
         MathAbs(value),
         2));
}


//====================================================
// Refresh Footer
//====================================================

void RG_UpdateFooter()
{
   string symbol=
      Symbol();

   int spread=
      (int)MarketInfo(
         symbol,
         MODE_SPREAD);

   double profit=
      RG_GetFloatingProfit();

   RG_SetLabelText(
      RG_PREFIX+"FOOTER_SYMBOL",
      "Symbol : "+symbol);

   RG_SetLabelText(
      RG_PREFIX+"FOOTER_SPREAD",
      "Spread : "
      +IntegerToString(
         spread));

   RG_SetLabelText(
      RG_PREFIX+"FOOTER_OPEN",
      "Open : "
      +IntegerToString(
         OrdersTotal())
      +" / "
      +IntegerToString(
         MaxOpenPositions));

   RG_SetLabelText(
      RG_PREFIX+"FOOTER_PROFIT",
      "P/L : "
      +RG_GetProfitText(
         profit));
}


//====================================================
// Delete Footer
//====================================================

void RG_DeleteFooter()
{
   RG_DeleteLabel(
      RG_PREFIX+"FOOTER_SYMBOL");

   RG_DeleteLabel(
      RG_PREFIX+"FOOTER_SPREAD");

   RG_DeleteLabel(
      RG_PREFIX+"FOOTER_OPEN");

   RG_DeleteLabel(
      RG_PREFIX+"FOOTER_PROFIT");
}


#endif