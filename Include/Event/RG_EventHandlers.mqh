#ifndef __RG_EVENTHANDLERS_MQH__
#define __RG_EVENTHANDLERS_MQH__

//====================================================
// Includes
//====================================================

#include <Trade/RG_Trade.mqh>
#include <Trade/RG_ProtectionManager.mqh>
#include <Trade/RG_RiskFree.mqh>
#include <Trade/RG_PositionCloser.mqh>

#include <RG_GUI.mqh>

//====================================================
// BUY
//====================================================

void RG_OnBuy()
{
   RG_SetLabelText(RG_PREFIX+"STATUS","Status : Sending BUY...");

   Print("BUY Button Clicked");

   if(RG_Buy())
   {
      RG_SetLabelText(RG_PREFIX+"STATUS","Status : BUY Opened");
      Print("BUY Success");
   }
   else
   {
      RG_SetLabelText(RG_PREFIX+"STATUS","Status : BUY Failed");
      Print("BUY Failed");
   }
}

//====================================================
// SELL
//====================================================

void RG_OnSell()
{
   RG_SetLabelText(RG_PREFIX+"STATUS","Status : Sending SELL...");

   Print("SELL Button Clicked");

   if(RG_Sell())
   {
      RG_SetLabelText(RG_PREFIX+"STATUS","Status : SELL Opened");
      Print("SELL Success");
   }
   else
   {
      RG_SetLabelText(RG_PREFIX+"STATUS","Status : SELL Failed");
      Print("SELL Failed");
   }
}

//====================================================
// BREAK EVEN
//====================================================

void RG_OnBreakEven()
{
   bool result=false;

   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;

      if(OrderSymbol()!=Symbol())
         continue;

      if(OrderType()!=OP_BUY &&
         OrderType()!=OP_SELL)
         continue;

      if(RG_BreakEven(OrderTicket()))
         result=true;
   }

   if(result)
   {
      RG_SetLabelText(RG_PREFIX+"STATUS","Status : Break Even Applied");
      Print("Break Even Applied");
   }
   else
   {
      RG_SetLabelText(RG_PREFIX+"STATUS","Status : Break Even Failed");
      Print("Break Even Failed");
   }
}

//====================================================
// RISK FREE
//====================================================

void RG_OnRiskFree()
{
   bool result=false;

   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;

      if(OrderSymbol()!=Symbol())
         continue;

      if(OrderType()!=OP_BUY &&
         OrderType()!=OP_SELL)
         continue;

      if(RG_RiskFree(OrderTicket()))
         result=true;
   }

   if(result)
   {
      RG_SetLabelText(RG_PREFIX+"STATUS","Status : Risk Free Applied");
      Print("Risk Free Applied");
   }
   else
   {
      RG_SetLabelText(RG_PREFIX+"STATUS","Status : Risk Free Failed");
      Print("Risk Free Failed");
   }
}

//====================================================
// CLOSE ALL
//====================================================

void RG_OnCloseAll()
{
   Print("Close All Handler");

   if(RG_CloseAll())
   {
      RG_SetLabelText(
         RG_PREFIX+"STATUS",
         "Status : All Positions Closed");

      Print("All Positions Closed");
   }
   else
   {
      RG_SetLabelText(
         RG_PREFIX+"STATUS",
         "Status : Close All Failed");

      Print("Close All Failed");
   }
}

//====================================================
// TRAILING
//====================================================

void RG_OnTrailing()
{
   Print("Trailing Handler");

   RG_SetLabelText(
      RG_PREFIX+"STATUS",
      "Status : Trailing");
}

#endif