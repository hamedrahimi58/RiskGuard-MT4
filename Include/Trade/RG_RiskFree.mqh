#ifndef __RG_RISKFREE_MQH__
#define __RG_RISKFREE_MQH__

#include <RG_Settings.mqh>
#include <Trade/RG_Broker.mqh>

//====================================================
// Calculate Trading Cost
//====================================================

double RG_GetTradingCost()
{
   double spread = MarketInfo(Symbol(),MODE_SPREAD) * Point;

   double commission = 0;

   return(spread + commission);
}

//====================================================
// Risk Free
//====================================================

bool RG_RiskFree(int ticket)
{
   if(ticket<=0)
      return(false);

   if(!OrderSelect(ticket,SELECT_BY_TICKET))
      return(false);

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(false);

   double cost = RG_GetTradingCost();

   cost += RiskFreeExtraPoints * Point;

   double newSL;

   if(OrderType()==OP_BUY)
      newSL = OrderOpenPrice() + cost;
   else
      newSL = OrderOpenPrice() - cost;

   bool result = OrderModify(
      OrderTicket(),
      OrderOpenPrice(),
      NormalizeDouble(newSL,Digits),
      OrderTakeProfit(),
      0,
      clrNONE);

   if(!result)
   {
      Print(
         "RiskFree Error : ",
         GetLastError());

      return(false);
   }

   Print(
      "RiskFree Applied. Ticket : ",
      ticket);

   return(true);
}

#endif