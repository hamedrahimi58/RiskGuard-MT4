#ifndef __RG_POSITION_CLOSER_MQH__
#define __RG_POSITION_CLOSER_MQH__

#include <RG_Settings.mqh>

//====================================================
// Position Closer
// RG-028-004
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

   double closePrice = 0;

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
// Close Partial Position
//----------------------------------------------------

bool RG_ClosePartial(
   int ticket,
   double lots)
{
   if(ticket <= 0)
      return(false);

   if(lots <= 0)
      return(false);

   if(!OrderSelect(ticket,SELECT_BY_TICKET))
   {
      Print(
         "ClosePartial : OrderSelect Failed. Ticket = ",
         ticket);

      return(false);
   }

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(false);

   double currentLots = OrderLots();

   if(currentLots <= 0)
      return(false);

   //--------------------------------------------------
   // Never close more than current volume
   //--------------------------------------------------

   if(lots > currentLots)
      lots = currentLots;

   double minLot =
      MarketInfo(
         OrderSymbol(),
         MODE_MINLOT);

   double lotStep =
      MarketInfo(
         OrderSymbol(),
         MODE_LOTSTEP);

   if(lotStep <= 0)
      lotStep = 0.01;

   if(minLot <= 0)
      minLot = lotStep;

   //--------------------------------------------------
   // Normalize to broker lot step
   //--------------------------------------------------

   lots =
      MathFloor(
         lots/lotStep + 0.0000001)
      *lotStep;

   lots =
      NormalizeDouble(
         lots,
         2);

   if(lots <= 0)
      return(false);

   //--------------------------------------------------
   // Full close if requested volume equals position
   //--------------------------------------------------

   if(lots >= currentLots)
      return(RG_ClosePosition(ticket));

   //--------------------------------------------------
   // Remaining volume must be valid
   //--------------------------------------------------

   double remainingLots =
      currentLots - lots;

   if(remainingLots < minLot)
   {
      Print(
         "ClosePartial : Invalid remaining volume. Ticket = ",
         ticket);

      return(false);
   }

   RefreshRates();

   double closePrice = 0;

   if(OrderType()==OP_BUY)
      closePrice = Bid;
   else
      closePrice = Ask;

   //--------------------------------------------------
   // Execute Partial Close
   //--------------------------------------------------

   ResetLastError();

   bool result = OrderClose(
      OrderTicket(),
      lots,
      NormalizeDouble(closePrice,Digits),
      10,
      clrNONE);

   if(!result)
   {
      Print(
         "ClosePartial Error : ",
         GetLastError(),
         " Ticket : ",
         ticket,
         " Lots : ",
         DoubleToString(lots,2));

      return(false);
   }

   Print(
      "Partial Position Closed. Ticket : ",
      ticket,
      " Lots : ",
      DoubleToString(lots,2));

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
   bool result = false;

   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;

      if(OrderSymbol()!=Symbol())
         continue;

      if(OrderType()!=OP_BUY)
         continue;

      if(RG_ClosePosition(OrderTicket()))
         result = true;
   }

   return(result);
}


//----------------------------------------------------
// Close Sell Positions
//----------------------------------------------------

bool RG_CloseSell()
{
   bool result = false;

   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;

      if(OrderSymbol()!=Symbol())
         continue;

      if(OrderType()!=OP_SELL)
         continue;

      if(RG_ClosePosition(OrderTicket()))
         result = true;
   }

   return(result);
}

#endif