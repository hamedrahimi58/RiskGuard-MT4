#ifndef __RG_TAKEPROFIT_MQH__
#define __RG_TAKEPROFIT_MQH__

#include <RG_Settings.mqh>
#include <Trade/RG_PositionCloser.mqh>

//====================================================
// RiskGuard MT4
// RG-029
// Take Profit Engine
//
// Features
// - Single TP
// - Multi TP
// - TP1 / TP2 / TP3
// - Manual TP price
// - Manual TP movement persistence
// - Partial close based on INITIAL lots
// - State protection
// - No EA event handlers in this file
//====================================================


//====================================================
// Internal State Keys
//====================================================

string RG_TPStateKey(
   int ticket,
   int level)
{
   return(
      "RG_TP_"
      + IntegerToString(ticket)
      + "_L"
      + IntegerToString(level));
}


//====================================================
// Manual TP Price Key
//====================================================

string RG_TPManualPriceKey(
   int ticket,
   int level)
{
   return(
      "RG_TP_"
      + IntegerToString(ticket)
      + "_MANUAL_"
      + IntegerToString(level));
}


//====================================================
// Initial Lots Key
//====================================================

string RG_TPInitialLotsKey(
   int ticket)
{
   return(
      "RG_TP_"
      + IntegerToString(ticket)
      + "_INITIAL_LOTS");
}


//====================================================
// Take Profit Enabled
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
// Multi Take Profit Enabled
//====================================================

bool RG_IsMultiTakeProfitEnabled()
{
   if(!UseMultiTakeProfit)
      return(false);

   if(TP1Points<=0 &&
      TP2Points<=0 &&
      TP3Points<=0)
      return(false);

   return(true);
}


//====================================================
// Get Configured TP Points
//====================================================

int RG_GetTPLevelPoints(
   int level)
{
   if(level==1)
      return(TP1Points);

   if(level==2)
      return(TP2Points);

   if(level==3)
      return(TP3Points);

   return(0);
}


//====================================================
// TP Close Percent
//====================================================

double RG_GetTPLevelClosePercent(
   int level)
{
   if(level==1)
      return(TP1ClosePercent);

   if(level==2)
      return(TP2ClosePercent);

   if(level==3)
      return(TP3ClosePercent);

   return(0);
}


//====================================================
// TP Level Configured
//====================================================

bool RG_IsTPLevelConfigured(
   int level)
{
   if(level<1 || level>3)
      return(false);

   int points=
      RG_GetTPLevelPoints(level);

   double percent=
      RG_GetTPLevelClosePercent(level);

   if(points<=0)
      return(false);

   if(percent<=0)
      return(false);

   if(percent>100)
      return(false);

   return(true);
}


//====================================================
// Calculate Default TP Price
//====================================================

double RG_GetDefaultTPLevelPrice(
   int ticket,
   int level)
{
   if(ticket<=0)
      return(0);

   if(level<1 || level>3)
      return(0);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(0);

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(0);

   int points=
      RG_GetTPLevelPoints(level);

   if(points<=0)
      return(0);

   double price=0;

   if(OrderType()==OP_BUY)
   {
      price=
         OrderOpenPrice()
         + points*Point;
   }
   else
   {
      price=
         OrderOpenPrice()
         - points*Point;
   }

   return(
      NormalizeDouble(
         price,
         Digits));
}


//====================================================
// Get Manual TP Price
//====================================================

double RG_GetManualTPPrice(
   int ticket,
   int level)
{
   if(ticket<=0)
      return(0);

   if(level<1 || level>3)
      return(0);

   string key=
      RG_TPManualPriceKey(
         ticket,
         level);

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
// Validate TP Price Direction
//====================================================

bool RG_IsValidTPPrice(
   int ticket,
   double price)
{
   if(ticket<=0)
      return(false);

   if(price<=0)
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
// Set Manual TP Price
//
// This is called by the chart visualization when
// trader manually moves a TP line.
//
// IMPORTANT:
// This does NOT modify the broker TP.
// It only stores the trader-selected target used
// by the Multi TP engine.
//====================================================

bool RG_SetManualTPPrice(
   int ticket,
   int level,
   double price)
{
   if(ticket<=0)
      return(false);

   if(level<1 || level>3)
      return(false);

   if(price<=0)
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

   string key=
      RG_TPManualPriceKey(
         ticket,
         level);

   GlobalVariableSet(
      key,
      price);

   return(true);
}


//====================================================
// Clear Manual TP Price
//====================================================

void RG_ClearManualTPPrice(
   int ticket,
   int level)
{
   if(ticket<=0)
      return;

   if(level<1 || level>3)
      return;

   string key=
      RG_TPManualPriceKey(
         ticket,
         level);

   if(GlobalVariableCheck(key))
      GlobalVariableDel(key);
}


//====================================================
// Clear All Manual TP Prices
//====================================================

void RG_ClearAllManualTPPrices(
   int ticket)
{
   if(ticket<=0)
      return;

   for(int level=1;level<=3;level++)
   {
      RG_ClearManualTPPrice(
         ticket,
         level);
   }
}


//====================================================
// TP Level Price
//
// Priority:
// 1. Manual TP price
// 2. Default TP price
//
// This is intentionally NOT based on OrderTakeProfit()
// because Multi TP must be independently controllable.
//====================================================

double RG_GetTPLevelPrice(
   int ticket,
   int level)
{
   if(ticket<=0)
      return(0);

   if(level<1 || level>3)
      return(0);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(0);

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(0);

   //--------------------------------------------------
   // Manual target
   //--------------------------------------------------

   double manualPrice=
      RG_GetManualTPPrice(
         ticket,
         level);

   if(manualPrice>0)
   {
      if(RG_IsValidTPPrice(
         ticket,
         manualPrice))
      {
         return(manualPrice);
      }

      //------------------------------------------------
      // Invalid manual value -> remove it
      //------------------------------------------------

      RG_ClearManualTPPrice(
         ticket,
         level);
   }

   //--------------------------------------------------
   // Default target
   //--------------------------------------------------

   return(
      RG_GetDefaultTPLevelPrice(
         ticket,
         level));
}


//====================================================
// TP Level Reached
//====================================================

bool RG_IsTPLevelReached(
   int ticket,
   int level)
{
   if(ticket<=0)
      return(false);

   if(!RG_IsTPLevelConfigured(level))
      return(false);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(false);

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(false);

   double target=
      RG_GetTPLevelPrice(
         ticket,
         level);

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
// State Exists
//====================================================

bool RG_TPStateExists(
   int ticket,
   int level)
{
   if(ticket<=0)
      return(false);

   if(level<1 || level>3)
      return(false);

   string key=
      RG_TPStateKey(
         ticket,
         level);

   if(!GlobalVariableCheck(key))
      return(false);

   return(
      GlobalVariableGet(key)>0);
}


//====================================================
// Mark TP Completed
//====================================================

void RG_MarkTPCompleted(
   int ticket,
   int level)
{
   if(ticket<=0)
      return;

   if(level<1 || level>3)
      return;

   GlobalVariableSet(
      RG_TPStateKey(
         ticket,
         level),
      1.0);
}


//====================================================
// Clear TP State
//====================================================

void RG_ClearTPState(
   int ticket)
{
   if(ticket<=0)
      return;

   for(int level=1;level<=3;level++)
   {
      string stateKey=
         RG_TPStateKey(
            ticket,
            level);

      if(GlobalVariableCheck(stateKey))
         GlobalVariableDel(stateKey);

      string manualKey=
         RG_TPManualPriceKey(
            ticket,
            level);

      if(GlobalVariableCheck(manualKey))
         GlobalVariableDel(manualKey);
   }

   string initialKey=
      RG_TPInitialLotsKey(ticket);

   if(GlobalVariableCheck(initialKey))
      GlobalVariableDel(initialKey);
}


//====================================================
// Store Initial Lots
//====================================================

bool RG_StoreInitialLots(
   int ticket)
{
   if(ticket<=0)
      return(false);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(false);

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(false);

   string key=
      RG_TPInitialLotsKey(ticket);

   if(GlobalVariableCheck(key))
      return(true);

   double lots=
      OrderLots();

   if(lots<=0)
      return(false);

   GlobalVariableSet(
      key,
      lots);

   return(true);
}


//====================================================
// Get Initial Lots
//====================================================

double RG_GetInitialLots(
   int ticket)
{
   if(ticket<=0)
      return(0);

   string key=
      RG_TPInitialLotsKey(ticket);

   if(GlobalVariableCheck(key))
   {
      double lots=
         GlobalVariableGet(key);

      if(lots>0)
         return(lots);
   }

   //--------------------------------------------------
   // First access
   //--------------------------------------------------

   if(!RG_StoreInitialLots(ticket))
      return(0);

   if(!GlobalVariableCheck(key))
      return(0);

   return(
      GlobalVariableGet(key));
}


//====================================================
// Partial Close Lots
//
// All percentages are calculated from INITIAL lots.
//====================================================

double RG_GetPartialCloseLots(
   int ticket,
   int level)
{
   if(ticket<=0)
      return(0);

   if(!RG_IsTPLevelConfigured(level))
      return(0);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(0);

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(0);

   double currentLots=
      OrderLots();

   if(currentLots<=0)
      return(0);

   double initialLots=
      RG_GetInitialLots(ticket);

   if(initialLots<=0)
      return(0);

   double percent=
      RG_GetTPLevelClosePercent(level);

   if(percent<=0)
      return(0);

   if(percent>100)
      percent=100;

   //--------------------------------------------------
   // Calculate from INITIAL volume
   //--------------------------------------------------

   double closeLots=
      initialLots*
      percent/
      100.0;

   double minLot=
      MarketInfo(
         OrderSymbol(),
         MODE_MINLOT);

   double lotStep=
      MarketInfo(
         OrderSymbol(),
         MODE_LOTSTEP);

   if(lotStep<=0)
      lotStep=0.01;

   if(minLot<=0)
      minLot=lotStep;

   //--------------------------------------------------
   // Normalize DOWN
   //--------------------------------------------------

   closeLots=
      MathFloor(
         closeLots/
         lotStep+
         0.0000001)
      *lotStep;

   //--------------------------------------------------
   // Never close more than current lots
   //--------------------------------------------------

   if(closeLots>currentLots)
      closeLots=currentLots;

   //--------------------------------------------------
   // TP3 closes remaining position
   //--------------------------------------------------

   if(level==3)
      closeLots=currentLots;

   //--------------------------------------------------
   // Normalize
   //--------------------------------------------------

   closeLots=
      NormalizeDouble(
         closeLots,
         2);

   if(closeLots<=0)
      return(0);

   //--------------------------------------------------
   // Prevent invalid remaining volume
   //--------------------------------------------------

   double remainingLots=
      currentLots-closeLots;

   if(remainingLots>0 &&
      remainingLots<minLot)
   {
      closeLots=currentLots;
   }

   return(
      NormalizeDouble(
         closeLots,
         2));
}


//====================================================
// Execute TP Level
//====================================================

bool RG_ExecuteTPLevel(
   int ticket,
   int level)
{
   if(ticket<=0)
      return(false);

   if(level<1 || level>3)
      return(false);

   //--------------------------------------------------
   // Already completed
   //--------------------------------------------------

   if(RG_TPStateExists(
      ticket,
      level))
      return(false);

   //--------------------------------------------------
   // Position must exist
   //--------------------------------------------------

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

   //--------------------------------------------------
   // Check target
   //--------------------------------------------------

   if(!RG_IsTPLevelReached(
      ticket,
      level))
      return(false);

   //--------------------------------------------------
   // Calculate close lots
   //--------------------------------------------------

   double closeLots=
      RG_GetPartialCloseLots(
         ticket,
         level);

   if(closeLots<=0)
   {
      Print(
         "RG TP Execution Skipped. Ticket=",
         ticket,
         " Level=",
         level,
         " InvalidLots.");

      return(false);
   }

   //--------------------------------------------------
   // Execute
   //--------------------------------------------------

   if(!RG_ClosePartial(
      ticket,
      closeLots))
   {
      Print(
         "RG TP Execution Failed. Ticket=",
         ticket,
         " Level=",
         level);

      return(false);
   }

   //--------------------------------------------------
   // Mark ONLY after successful close
   //--------------------------------------------------

   RG_MarkTPCompleted(
      ticket,
      level);

   Print(
      "RG TP Execution Completed. Ticket=",
      ticket,
      " Level=",
      level,
      " ClosedLots=",
      DoubleToString(
         closeLots,
         2));

   //--------------------------------------------------
   // If position no longer exists,
   // clean all state.
   //--------------------------------------------------

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
   {
      RG_ClearTPState(ticket);
   }

   return(true);
}


//====================================================
// Process Take Profit
//====================================================

bool RG_ProcessTakeProfit(
   int ticket)
{
   if(ticket<=0)
      return(false);

   if(!RG_IsMultiTakeProfitEnabled())
      return(false);

   //--------------------------------------------------
   // Position exists?
   //--------------------------------------------------

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

   //--------------------------------------------------
   // Store initial volume once
   //--------------------------------------------------

   if(RG_GetInitialLots(ticket)<=0)
      return(false);

   bool result=false;

   //--------------------------------------------------
   // Process in sequence
   //--------------------------------------------------

   for(int level=1;level<=3;level++)
   {
      if(!RG_IsTPLevelConfigured(level))
         continue;

      if(RG_TPStateExists(
         ticket,
         level))
         continue;

      if(RG_ExecuteTPLevel(
         ticket,
         level))
      {
         result=true;

         //------------------------------------------------
         // Position may have been fully closed
         //------------------------------------------------

         if(!OrderSelect(
            ticket,
            SELECT_BY_TICKET))
         {
            break;
         }

         if(OrderLots()<=0)
            break;
      }
   }

   return(result);
}


//====================================================
// Process All Take Profits
//====================================================

void RG_ProcessTakeProfits()
{
   if(!RG_IsMultiTakeProfitEnabled())
      return;

   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(
         i,
         SELECT_BY_POS,
         MODE_TRADES))
         continue;

      if(OrderSymbol()!=Symbol())
         continue;

      if(OrderType()!=OP_BUY &&
         OrderType()!=OP_SELL)
         continue;

      int ticket=
         OrderTicket();

      RG_ProcessTakeProfit(ticket);
   }
}


#endif