#ifndef __RG_RISKFREE_MQH__
#define __RG_RISKFREE_MQH__

#include <RG_Settings.mqh>

//====================================================
// RiskGuard MT4
// RISK FREE
//
// Automatic RF:
//   waits for RiskFreeTrigger
//
// Manual RF:
//   position-row RF button applies BE + configured
//   RiskFree offset immediately, without the trigger.
//
// RiskFree state is stored per ticket.
//====================================================

string RG_RF_StateKey(int ticket)
{
   return(
      "RG_RF_DONE_"+IntegerToString(ticket)
   );
}

bool RG_IsRiskFreeDone(int ticket)
{
   if(ticket<=0)
      return(false);

   string key=RG_RF_StateKey(ticket);

   if(!GlobalVariableCheck(key))
      return(false);

   return(GlobalVariableGet(key)>0);
}

void RG_MarkRiskFreeDone(int ticket)
{
   if(ticket<=0)
      return;

   GlobalVariableSet(
      RG_RF_StateKey(ticket),
      1.0
   );
}

bool RG_RiskFree_IsMarketOrder()
{
   return(
      OrderType()==OP_BUY ||
      OrderType()==OP_SELL
   );
}

//====================================================
// Calculate manual RF target
//====================================================

bool RG_RiskFree_GetManualTarget(
   int ticket,
   double &newSL)
{
   newSL=0.0;

   if(ticket<=0)
      return(false);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(false);

   if(OrderSymbol()!=Symbol() ||
      OrderMagicNumber()!=MagicNumber)
      return(false);

   if(!RG_RiskFree_IsMarketOrder())
      return(false);

   RefreshRates();

   double openPrice=
      NormalizeDouble(
         OrderOpenPrice(),
         Digits);

   double offset=
      (RiskFreeOffset+
       RiskFreeExtraPoints)*
      Point;

   if(OrderType()==OP_BUY)
   {
      newSL=
         NormalizeDouble(
            openPrice+offset,
            Digits);

      if(newSL>=Bid)
         return(false);
   }
   else
   {
      newSL=
         NormalizeDouble(
            openPrice-offset,
            Digits);

      if(newSL<=Ask)
         return(false);
   }

   return(true);
}

//====================================================
// Manual RiskFree
//
// Does NOT require RiskFreeTrigger.
//====================================================

bool RG_ApplyManualRiskFree(int ticket)
{
   if(ticket<=0)
      return(false);

   if(!UseRiskFree)
      return(false);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(false);

   if(OrderSymbol()!=Symbol() ||
      OrderMagicNumber()!=MagicNumber)
      return(false);

   if(!RG_RiskFree_IsMarketOrder())
      return(false);

   if(RG_IsRiskFreeDone(ticket))
      return(true);

   double newSL=0.0;

   if(!RG_RiskFree_GetManualTarget(
      ticket,newSL))
   {
      Print(
         "RG Manual RF: target is not currently valid. Ticket=",
         ticket,
         " Bid=",
         DoubleToString(Bid,Digits),
         " Ask=",
         DoubleToString(Ask,Digits)
      );

      return(false);
   }

   double stopLevel=
      MarketInfo(
         OrderSymbol(),
         MODE_STOPLEVEL)*
      MarketInfo(
         OrderSymbol(),
         MODE_POINT);

   double freezeLevel=
      MarketInfo(
         OrderSymbol(),
         MODE_FREEZELEVEL)*
      MarketInfo(
         OrderSymbol(),
         MODE_POINT);

   double minDistance=
      MathMax(stopLevel,freezeLevel);

   if(OrderType()==OP_BUY)
   {
      if(Bid-newSL<minDistance)
      {
         Print(
            "RG Manual RF: broker stop/freeze distance prevents RF. Ticket=",
            ticket
         );

         return(false);
      }

      if(OrderStopLoss()>0 &&
         OrderStopLoss()>=newSL)
      {
         RG_MarkRiskFreeDone(ticket);
         return(true);
      }
   }
   else
   {
      if(newSL-Ask<minDistance)
      {
         Print(
            "RG Manual RF: broker stop/freeze distance prevents RF. Ticket=",
            ticket
         );

         return(false);
      }

      if(OrderStopLoss()>0 &&
         OrderStopLoss()<=newSL)
      {
         RG_MarkRiskFreeDone(ticket);
         return(true);
      }
   }

   ResetLastError();

   if(!OrderModify(
      ticket,
      OrderOpenPrice(),
      newSL,
      OrderTakeProfit(),
      0,
      clrNONE))
   {
      int error=GetLastError();

      Print(
         "RG Manual RF failed. Ticket=",
         ticket,
         " Error=",
         error,
         " NewSL=",
         DoubleToString(newSL,Digits)
      );

      return(false);
   }

   RG_MarkRiskFreeDone(ticket);

   return(true);
}

//====================================================
// Automatic RiskFree for one ticket
//====================================================

bool RG_ProcessRiskFreeTicket(int ticket)
{
   if(ticket<=0)
      return(false);

   if(!UseRiskFree)
      return(false);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(false);

   if(!RG_RiskFree_IsMarketOrder())
      return(false);

   if(RG_IsRiskFreeDone(ticket))
      return(false);

   RefreshRates();

   double openPrice=
      NormalizeDouble(
         OrderOpenPrice(),
         Digits);

   double trigger=
      RiskFreeTrigger*Point;

   double offset=
      (RiskFreeOffset+
       RiskFreeExtraPoints)*
      Point;

   double newSL=0.0;

   if(OrderType()==OP_BUY)
   {
      if(Bid-openPrice<trigger)
         return(false);

      newSL=
         NormalizeDouble(
            openPrice+offset,
            Digits);

      if(OrderStopLoss()>0 &&
         OrderStopLoss()>=newSL)
      {
         RG_MarkRiskFreeDone(ticket);
         return(false);
      }

      if(newSL>=Bid)
         return(false);

      ResetLastError();

      if(!OrderModify(
         ticket,
         openPrice,
         newSL,
         OrderTakeProfit(),
         0,
         clrNONE))
      {
         Print(
            "RG RiskFree BUY failed. Ticket=",
            ticket,
            " Error=",
            GetLastError()
         );

         return(false);
      }

      RG_MarkRiskFreeDone(ticket);
      return(true);
   }

   if(OrderType()==OP_SELL)
   {
      if(openPrice-Ask<trigger)
         return(false);

      newSL=
         NormalizeDouble(
            openPrice-offset,
            Digits);

      if(OrderStopLoss()>0 &&
         OrderStopLoss()<=newSL)
      {
         RG_MarkRiskFreeDone(ticket);
         return(false);
      }

      if(newSL<=Ask)
         return(false);

      ResetLastError();

      if(!OrderModify(
         ticket,
         openPrice,
         newSL,
         OrderTakeProfit(),
         0,
         clrNONE))
      {
         Print(
            "RG RiskFree SELL failed. Ticket=",
            ticket,
            " Error=",
            GetLastError()
         );

         return(false);
      }

      RG_MarkRiskFreeDone(ticket);
      return(true);
   }

   return(false);
}

//====================================================
// Process All Automatic RiskFree
//====================================================

void RG_ProcessRiskFree()
{
   if(!UseRiskFree)
      return;

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

      if(OrderMagicNumber()!=MagicNumber)
         continue;

      if(!RG_RiskFree_IsMarketOrder())
         continue;

      RG_ProcessRiskFreeTicket(
         OrderTicket()
      );
   }
}

#endif
