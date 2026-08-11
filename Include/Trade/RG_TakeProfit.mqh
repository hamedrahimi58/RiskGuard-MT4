#ifndef __RG_TAKEPROFIT_MQH__
#define __RG_TAKEPROFIT_MQH__

#include <RG_Settings.mqh>

//====================================================
// RiskGuard MT4
// SINGLE FINAL TAKE PROFIT
//
// Existing broker TP is authoritative after order open.
// RiskGuard will create/sync a TP only when the order has
// no broker TP yet. This preserves manual MT4 dragging.
//====================================================

#define RG_TP_PREFIX "RGTP_"

string RG_TP_ManualKey(int ticket)
{
   return(
      RG_TP_PREFIX+"MANUAL_"+IntegerToString(ticket)
   );
}

string RG_TP_DoneKey(int ticket)
{
   return(
      RG_TP_PREFIX+"DONE_"+IntegerToString(ticket)
   );
}

void RG_ClearTPState(int ticket)
{
   if(ticket<=0)
      return;

   string key=RG_TP_ManualKey(ticket);

   if(GlobalVariableCheck(key))
      GlobalVariableDel(key);

   key=RG_TP_DoneKey(ticket);

   if(GlobalVariableCheck(key))
      GlobalVariableDel(key);
}

bool RG_TPManualExists(int ticket)
{
   if(ticket<=0)
      return(false);

   return(
      GlobalVariableCheck(
         RG_TP_ManualKey(ticket)
      )
   );
}

double RG_GetManualTPPrice(int ticket)
{
   if(!RG_TPManualExists(ticket))
      return(0);

   double price=
      GlobalVariableGet(
         RG_TP_ManualKey(ticket)
      );

   if(price<=0)
      return(0);

   return(NormalizeDouble(price,Digits));
}

bool RG_IsValidManualTP(int ticket,double price)
{
   if(ticket<=0 || price<=0)
      return(false);

   if(!OrderSelect(ticket,SELECT_BY_TICKET))
      return(false);

   if(OrderType()==OP_BUY)
      return(price>OrderOpenPrice());

   if(OrderType()==OP_SELL)
      return(price<OrderOpenPrice());

   return(false);
}

bool RG_SetManualTPPrice(int ticket,double price)
{
   if(!RG_IsValidManualTP(ticket,price))
      return(false);

   GlobalVariableSet(
      RG_TP_ManualKey(ticket),
      NormalizeDouble(price,Digits)
   );

   return(true);
}

double RG_GetTPLevelPrice(int ticket)
{
   if(ticket<=0)
      return(0);

   if(!OrderSelect(ticket,SELECT_BY_TICKET))
      return(0);

   // Manual RiskGuard TP state, if any, has priority.
   double manual=RG_GetManualTPPrice(ticket);

   if(manual>0 &&
      RG_IsValidManualTP(ticket,manual))
      return(manual);

   if(!UseTakeProfit ||
      TakeProfit<=0)
      return(0);

   double price=0;

   if(OrderType()==OP_BUY)
      price=OrderOpenPrice()+TakeProfit*Point;
   else
   if(OrderType()==OP_SELL)
      price=OrderOpenPrice()-TakeProfit*Point;
   else
      return(0);

   return(NormalizeDouble(price,Digits));
}

bool RG_TPStateExists(int ticket)
{
   if(ticket<=0)
      return(false);

   string key=RG_TP_DoneKey(ticket);

   if(!GlobalVariableCheck(key))
      return(false);

   return(GlobalVariableGet(key)>0);
}

void RG_MarkTPDone(int ticket)
{
   if(ticket<=0)
      return;

   GlobalVariableSet(
      RG_TP_DoneKey(ticket),
      1.0
   );
}

bool RG_IsTPReached(int ticket)
{
   if(ticket<=0)
      return(false);

   if(RG_TPStateExists(ticket))
      return(false);

   if(!OrderSelect(ticket,SELECT_BY_TICKET))
      return(false);

   double target=RG_GetTPLevelPrice(ticket);

   if(target<=0)
      return(false);

   RefreshRates();

   if(OrderType()==OP_BUY)
      return(Bid>=target);

   if(OrderType()==OP_SELL)
      return(Ask<=target);

   return(false);
}

bool RG_CloseAtTakeProfit(int ticket)
{
   if(ticket<=0)
      return(false);

   if(!OrderSelect(ticket,SELECT_BY_TICKET))
      return(false);

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(false);

   double lots=OrderLots();

   if(lots<=0)
      return(false);

   RefreshRates();

   double price=
      (OrderType()==OP_BUY ? Bid : Ask);

   ResetLastError();

   bool result=
      OrderClose(
         ticket,
         lots,
         price,
         3,
         clrNONE
      );

   if(!result)
   {
      Print(
         "RG TakeProfit close failed. Ticket=",
         ticket,
         " Error=",
         GetLastError()
      );

      return(false);
   }

   RG_MarkTPDone(ticket);
   return(true);
}

//====================================================
// Synchronize broker TP
//
// IMPORTANT:
// Never overwrite an existing broker TP.
// This is what allows manual MT4 dragging to persist.
//====================================================

bool RG_SyncBrokerTP(int ticket)
{
   if(ticket<=0)
      return(false);

   if(!OrderSelect(ticket,SELECT_BY_TICKET))
      return(false);

   double target=RG_GetTPLevelPrice(ticket);

   if(target<=0)
      return(false);

   // Existing broker TP is authoritative.
   if(OrderTakeProfit()>0)
      return(true);

   double stopLevel=
      MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;

   RefreshRates();

   bool brokerOK=true;

   if(OrderType()==OP_BUY)
   {
      if(target-Bid<stopLevel)
         brokerOK=false;
   }
   else
   if(OrderType()==OP_SELL)
   {
      if(Ask-target<stopLevel)
         brokerOK=false;
   }
   else
      return(false);

   if(!brokerOK)
      return(false);

   ResetLastError();

   bool modified=
      OrderModify(
         ticket,
         OrderOpenPrice(),
         OrderStopLoss(),
         target,
         0,
         clrNONE
      );

   if(!modified)
   {
      Print(
         "RG TakeProfit OrderModify failed. Ticket=",
         ticket,
         " Error=",
         GetLastError()
      );

      return(false);
   }

   return(true);
}

bool RG_ProcessTakeProfit(int ticket)
{
   if(ticket<=0)
      return(false);

   if(!UseTakeProfit)
      return(false);

   if(!OrderSelect(ticket,SELECT_BY_TICKET))
   {
      RG_ClearTPState(ticket);
      return(false);
   }

   if(OrderSymbol()!=Symbol() ||
      OrderMagicNumber()!=MagicNumber)
      return(false);

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(false);

   if(RG_TPStateExists(ticket))
      return(false);

   // Only creates a broker TP when none exists.
   RG_SyncBrokerTP(ticket);

   if(!RG_IsTPReached(ticket))
      return(false);

   return(
      RG_CloseAtTakeProfit(ticket)
   );
}

void RG_ProcessTakeProfits()
{
   if(!UseTakeProfit)
      return;

   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;

      if(OrderSymbol()!=Symbol())
         continue;

      if(OrderMagicNumber()!=MagicNumber)
         continue;

      if(OrderType()!=OP_BUY &&
         OrderType()!=OP_SELL)
         continue;

      RG_ProcessTakeProfit(
         OrderTicket()
      );
   }
}

#endif
