#ifndef __RG_TRADE_MQH__
#define __RG_TRADE_MQH__

#include <RG_Settings.mqh>
#include <Trade/RG_PositionSizer.mqh>

//====================================================
// Send BUY Order
//====================================================
int RG_SendBuyOrder()
{
   RefreshRates();

   double lot = RG_GetVolume();

   int ticket = OrderSend(
      Symbol(),
      OP_BUY,
      lot,
      Ask,
      10,
      0,
      0,
      "RiskGuard BUY",
      0,
      0,
      clrLime);

   if(ticket < 0)
   {
      Print("BUY Error : ", GetLastError());
      return(-1);
   }

   Print("BUY Ticket : ", ticket);

   return(ticket);
}

//====================================================
// Send SELL Order
//====================================================
int RG_SendSellOrder()
{
   RefreshRates();

   double lot = RG_GetVolume();

   int ticket = OrderSend(
      Symbol(),
      OP_SELL,
      lot,
      Bid,
      10,
      0,
      0,
      "RiskGuard SELL",
      0,
      0,
      clrRed);

   if(ticket < 0)
   {
      Print("SELL Error : ", GetLastError());
      return(-1);
   }

   Print("SELL Ticket : ", ticket);

   return(ticket);
}

//====================================================
// BUY Wrapper
//====================================================
bool RG_Buy()
{
   return(RG_SendBuyOrder() > 0);
}

//====================================================
// SELL Wrapper
//====================================================
bool RG_Sell()
{
   return(RG_SendSellOrder() > 0);
}

#endif