#ifndef __RG_TAKEPROFIT_MQH__
#define __RG_TAKEPROFIT_MQH__

#include <RG_Settings.mqh>
#include <Trade/RG_PositionCloser.mqh>

//====================================================
// RiskGuard MT4
// RG-029
// SINGLE TAKE PROFIT ENGINE
//
// - One TP only
// - Full position close
// - One-time execution
// - Manual TP movement persistence
// - No Multi TP
// - No partial close
//====================================================


//====================================================
// State Key
//====================================================

string RG_TPStateKey(int ticket)
{
   return(
      "RG_TP_"+
      IntegerToString(ticket));
}


//====================================================
// Manual TP Key
//====================================================

string RG_TPManualPriceKey(int ticket)
{
   return(
      "RG_TP_"+
      IntegerToString(ticket)+
      "_MANUAL");
}


//====================================================
// TP Enabled
//====================================================

bool RG_IsTakeProfitEnabled()
{
   if(!UseTakeProfit)
      return(false);

   if(TakeProfit<=0)
      return(false);

   return(true);
}


//====================================================
// Default TP
//====================================================

double RG_GetDefaultTPPrice(int ticket)
{
   if(ticket<=0)
      return(0);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(0);

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(0);

   double price=0;

   if(OrderType()==OP_BUY)
   {
      price=
         OrderOpenPrice()+
         TakeProfit*Point;
   }
   else
   {
      price=
         OrderOpenPrice()-
         TakeProfit*Point;
   }

   return(
      NormalizeDouble(
         price,
         Digits));
}


//====================================================
// Manual TP
//====================================================

double RG_GetManualTPPrice(int ticket)
{
   if(ticket<=0)
      return(0);

   string key=
      RG_TPManualPriceKey(ticket);

   if(!GlobalVariableCheck(key))
      return(0);

   double price=
      GlobalVariableGet(key);

   if(price<=0)
      return(0);

   return(
      NormalizeDouble(
         price,
         Digits));
}


//====================================================
// Validate TP Direction
//====================================================

bool RG_IsValidTPPrice(
   int ticket,
   double price)
{
   if(ticket<=0 ||
      price<=0)
      return(false);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(false);

   if(OrderType()==OP_BUY)
   {
      if(price<=OrderOpenPrice())
         return(false);
   }

   if(OrderType()==OP_SELL)
   {
      if(price>=OrderOpenPrice())
         return(false);
   }

   return(true);
}


//====================================================
// Set Manual TP
//====================================================

bool RG_SetManualTPPrice(
   int ticket,
   double price)
{
   if(ticket<=0 ||
      price<=0)
      return(false);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(false);

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(false);

   price=
      NormalizeDouble(
         price,
         Digits);

   if(!RG_IsValidTPPrice(
      ticket,
      price))
      return(false);

   GlobalVariableSet(
      RG_TPManualPriceKey(ticket),
      price);

   return(true);
}


//====================================================
// Clear Manual TP
//====================================================

void RG_ClearManualTPPrice(int ticket)
{
   if(ticket<=0)
      return;

   string key=
      RG_TPManualPriceKey(ticket);

   if(GlobalVariableCheck(key))
      GlobalVariableDel(key);
}


//====================================================
// Active TP Price
//
// Manual TP has priority.
// Otherwise configured TP is used.
//====================================================

double RG_GetTPPrice(int ticket)
{
   if(ticket<=0)
      return(0);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(0);

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(0);

   double manual=
      RG_GetManualTPPrice(ticket);

   if(manual>0)
   {
      if(RG_IsValidTPPrice(
         ticket,
         manual))
      {
         return(manual);
      }

      RG_ClearManualTPPrice(ticket);
   }

   return(
      RG_GetDefaultTPPrice(ticket));
}


//====================================================
// TP State
//====================================================

bool RG_TPStateExists(int ticket)
{
   if(ticket<=0)
      return(false);

   string key=
      RG_TPStateKey(ticket);

   if(!GlobalVariableCheck(key))
      return(false);

   return(
      GlobalVariableGet(key)>0);
}


//====================================================
// Mark TP Completed
//====================================================

void RG_MarkTPCompleted(int ticket)
{
   if(ticket<=0)
      return;

   GlobalVariableSet(
      RG_TPStateKey(ticket),
      1.0);
}


//====================================================
// Clear TP State
//====================================================

void RG_ClearTPState(int ticket)
{
   if(ticket<=0)
      return;

   string key=
      RG_TPStateKey(ticket);

   if(GlobalVariableCheck(key))
      GlobalVariableDel(key);

   RG_ClearManualTPPrice(ticket);
}


//====================================================
// TP Reached
//====================================================

bool RG_IsTPReached(int ticket)
{
   if(ticket<=0)
      return(false);

   if(RG_TPStateExists(ticket))
      return(false);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
   {
      RG_ClearTPState(ticket);
      return(false);
   }

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(false);

   double target=
      RG_GetTPPrice(ticket);

   if(target<=0)
      return(false);

   RefreshRates();

   if(OrderType()==OP_BUY)
   {
      if(Bid>=target)
         return(true);
   }

   if(OrderType()==OP_SELL)
   {
      if(Ask<=target)
         return(true);
   }

   return(false);
}


//====================================================
// Execute Single TP
//
// IMPORTANT:
// The complete current position is closed.
// No partial close.
// No second execution.
//====================================================

bool RG_ExecuteTakeProfit(int ticket)
{
   if(ticket<=0)
      return(false);

   if(RG_TPStateExists(ticket))
      return(false);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
   {
      RG_ClearTPState(ticket);
      return(false);
   }

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(false);

   if(!RG_IsTPReached(ticket))
      return(false);

   double lots=
      OrderLots();

   if(lots<=0)
      return(false);

   if(!RG_ClosePartial(
      ticket,
      lots))
   {
      Print(
         "RG Single TP Execution Failed. Ticket=",
         ticket);

      return(false);
   }

   // Mark completed immediately after successful close.
   RG_MarkTPCompleted(ticket);

   Print(
      "RG Single TP Execution Completed. Ticket=",
      ticket,
      " ClosedLots=",
      DoubleToString(
         lots,
         2));

   // Position is normally gone here.
   // Keep state cleanup consistent.
   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
   {
      RG_ClearTPState(ticket);
   }

   return(true);
}


//====================================================
// Process TP
//====================================================

bool RG_ProcessTakeProfit(int ticket)
{
   if(ticket<=0)
      return(false);

   if(!RG_IsTakeProfitEnabled())
      return(false);

   if(!RG_TPStateExists(ticket))
   {
      if(!OrderSelect(
         ticket,
         SELECT_BY_TICKET))
      {
         RG_ClearTPState(ticket);
         return(false);
      }

      if(OrderType()!=OP_BUY &&
         OrderType()!=OP_SELL)
         return(false);
   }

   return(
      RG_ExecuteTakeProfit(ticket));
}


//====================================================
// Process All TPs
//====================================================

void RG_ProcessTakeProfits()
{
   if(!RG_IsTakeProfitEnabled())
      return;

   for(int i=OrdersTotal()-1;
       i>=0;
       i--)
   {
      if(!OrderSelect(
         i,
         SELECT_BY_POS,
         MODE_TRADES))
      {
         continue;
      }

      if(OrderSymbol()!=Symbol())
         continue;

      if(OrderType()!=OP_BUY &&
         OrderType()!=OP_SELL)
      {
         continue;
      }

      int ticket=
         OrderTicket();

      RG_ProcessTakeProfit(ticket);
   }
}

#endif