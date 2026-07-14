#ifndef __RG_TRADE_MQH__
#define __RG_TRADE_MQH__

#include <RG_Settings.mqh>
#include <Trade/RG_PositionSizer.mqh>

//====================================================
// Modify Order
//====================================================
bool RG_ModifyOrder(
   const int ticket,
   const double sl,
   const double tp)
{
   if(ticket <= 0)
   
      return(false);

   if(!OrderSelect(ticket,SELECT_BY_TICKET))
   {
      Print("OrderSelect Error : ",GetLastError());
      return(false);
   }

   bool result = OrderModify(
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

   double lot   = RG_GetVolume();
   double price = Ask;

   int ticket = OrderSend(
      Symbol(),
      OP_BUY,
      lot,
      price,
      10,
      0,
      0,
      "RiskGuard BUY",
      0,
      0,
      clrLime);

   if(ticket < 0)
   {
      Print("BUY Error : ",GetLastError());
      return(-1);
   }

   Print("BUY Ticket : ",ticket);

   // ECN StopLoss
   if(UseStopLoss)
   {
      if(OrderSelect(ticket,SELECT_BY_TICKET))
      {
         double sl = NormalizeDouble(
            OrderOpenPrice() - StopLoss * Point,
            Digits);

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

   double lot   = RG_GetVolume();
   double price = Bid;

   int ticket = OrderSend(
      Symbol(),
      OP_SELL,
      lot,
      price,
      10,
      0,
      0,
      "RiskGuard SELL",
      0,
      0,
      clrRed);

   if(ticket < 0)
   {
      Print("SELL Error : ",GetLastError());
      return(-1);
   }

   Print("SELL Ticket : ",ticket);

   // ECN StopLoss
   if(UseStopLoss)
   {
      if(OrderSelect(ticket,SELECT_BY_TICKET))
      {
         double sl = NormalizeDouble(
            OrderOpenPrice() + StopLoss * Point,
            Digits);

         RG_ModifyOrder(ticket,sl,0);
      }
   }

   return(ticket);
}

//====================================================
// BUY Wrapper
//====================================================
bool RG_Buy()
{
   return(RG_SendBuyOrder()>0);
}

//====================================================
// SELL Wrapper
//====================================================
bool RG_Sell()
{
   return(RG_SendSellOrder()>0);
}

#endif