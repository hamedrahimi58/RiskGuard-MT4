#ifndef __RG_POSITION_CLOSER_MQH__
#define __RG_POSITION_CLOSER_MQH__

#include <RG_Settings.mqh>

//====================================================
// Position Closer
//====================================================

//----------------------------------------------------
// Close One Position
//----------------------------------------------------

bool RG_ClosePosition(int ticket)
{
   if(ticket <= 0)
      return(false);

   if(!OrderSelect(ticket,SELECT_BY_TICKET))
   {
      Print(
         "ClosePosition : OrderSelect Failed. Ticket = ",
         ticket);

      return(false);
   }

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(false);

   RefreshRates();

   double closePrice;

   if(OrderType()==OP_BUY)
      closePrice = Bid;
   else
      closePrice = Ask;

   bool result = OrderClose(
      OrderTicket(),
      OrderLots(),
      NormalizeDouble(closePrice,Digits),
      10,
      clrNONE);

   if(!result)
   {
      Print(
         "ClosePosition Error : ",
         GetLastError());

      return(false);
   }

   Print(
      "Position Closed. Ticket : ",
      ticket);

   return(true);
}
//----------------------------------------------------
// Close All Positions
//----------------------------------------------------

bool RG_CloseAll()
{
   bool result = false;

   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;

      if(OrderSymbol()!=Symbol())
         continue;

      if(OrderType()!=OP_BUY &&
         OrderType()!=OP_SELL)
         continue;

      if(RG_ClosePosition(OrderTicket()))
         result = true;
   }

   if(result)
      Print("Close All Completed.");
   else
      Print("Close All : No Position Closed.");

   return(result);
}

//----------------------------------------------------
// Close Buy Positions
//----------------------------------------------------

bool RG_CloseBuy()
{
   return(false);
}

//----------------------------------------------------
// Close Sell Positions
//----------------------------------------------------

bool RG_CloseSell()
{
   return(false);
}

#endif