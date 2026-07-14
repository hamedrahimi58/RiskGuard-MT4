#ifndef __RG_TRADE_MQH__
#define __RG_TRADE_MQH__

#include <RG_Settings.mqh>
#include <Trade/RG_PositionSizer.mqh>
#include <Trade/RG_Broker.mqh>

//====================================================
// Modify Order
//====================================================
bool RG_ModifyOrder(
   const int ticket,
   const double sl,
   const double tp)
{
   if(ticket<=0)
      return(false);

   if(!OrderSelect(ticket,SELECT_BY_TICKET))
   {
      Print("OrderSelect Error : ",GetLastError());
      return(false);
   }

   RefreshRates();

   bool result=OrderModify(
      OrderTicket(),
      OrderOpenPrice(),
      sl,
      tp,
      0,
      clrNONE);

   if(!result)
   {
      Print("Modify Error : ",GetLastError());
      return(false);
   }

   return(true);
}

//====================================================
// Send BUY
//====================================================
int RG_SendBuyOrder()
{
   RefreshRates();

   double lot=RG_GetVolume();

   int ticket=OrderSend(
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

   if(ticket<0)
   {
      Print("BUY Error : ",GetLastError());
      return(-1);
   }

   if(UseStopLoss)
   {
      Sleep(500);

      RefreshRates();

      if(OrderSelect(ticket,SELECT_BY_TICKET))
      {
         double sl=OrderOpenPrice()-StopLoss*RG_Point();

         sl=RG_CorrectBuySL(sl,OrderOpenPrice());

         RG_ModifyOrder(ticket,sl,0);
      }
   }

   return(ticket);
}

//====================================================
// Send SELL
//====================================================
int RG_SendSellOrder()
{
   RefreshRates();

   double lot=RG_GetVolume();

   int ticket=OrderSend(
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

   if(ticket<0)
   {
      Print("SELL Error : ",GetLastError());
      return(-1);
   }

   if(UseStopLoss)
   {
      Sleep(500);

      RefreshRates();

      if(OrderSelect(ticket,SELECT_BY_TICKET))
      {
         double sl=OrderOpenPrice()+StopLoss*RG_Point();

         sl=RG_CorrectSellSL(sl,OrderOpenPrice());

         RG_ModifyOrder(ticket,sl,0);
      }
   }

   return(ticket);
}

//====================================================
// BUY
//====================================================
bool RG_Buy()
{
   return(RG_SendBuyOrder()>0);
}

//====================================================
// SELL
//====================================================
bool RG_Sell()
{
   return(RG_SendSellOrder()>0);
}

#endif