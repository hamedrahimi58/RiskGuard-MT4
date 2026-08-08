#ifndef __RG_TAKEPROFIT_MQH__
#define __RG_TAKEPROFIT_MQH__

#include <RG_Settings.mqh>

//====================================================
// RiskGuard MT4
// SINGLE FINAL TAKE PROFIT
//
// - One final TP
// - Full position close
// - No partial close
// - No Multi TP
// - Manual TP supported
//====================================================

#define RG_TP_PREFIX "RGTP_"

//====================================================
// Keys
//====================================================

string RG_TP_ManualKey(int ticket)
{
   return(
      RG_TP_PREFIX+
      "MANUAL_"+
      IntegerToString(ticket)
   );
}

string RG_TP_DoneKey(int ticket)
{
   return(
      RG_TP_PREFIX+
      "DONE_"+
      IntegerToString(ticket)
   );
}

//====================================================
// Clear State
//====================================================

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

//====================================================
// Manual TP Exists
//====================================================

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

//====================================================
// Get Manual TP
//====================================================

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

   return(
      NormalizeDouble(
         price,
         Digits
      )
   );
}

//====================================================
// Validate Manual TP
//====================================================

bool RG_IsValidManualTP(
   int ticket,
   double price)
{
   if(ticket<=0 || price<=0)
      return(false);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(false);

   if(OrderType()==OP_BUY)
      return(
         price>OrderOpenPrice()
      );

   if(OrderType()==OP_SELL)
      return(
         price<OrderOpenPrice()
      );

   return(false);
}

//====================================================
// Set Manual TP
//====================================================

bool RG_SetManualTPPrice(
   int ticket,
   double price)
{
   if(ticket<=0 || price<=0)
      return(false);

   if(!RG_IsValidManualTP(
      ticket,
      price))
      return(false);

   GlobalVariableSet(
      RG_TP_ManualKey(ticket),
      NormalizeDouble(
         price,
         Digits
      )
   );

   return(true);
}

//====================================================
// Get Active Final TP
//====================================================

double RG_GetTPLevelPrice(int ticket)
{
   if(ticket<=0)
      return(0);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(0);

   //--------------------------------------------------
   // Manual chart TP has priority
   //--------------------------------------------------

   double manual=
      RG_GetManualTPPrice(ticket);

   if(manual>0 &&
      RG_IsValidManualTP(
         ticket,
         manual))
   {
      return(manual);
   }

   //--------------------------------------------------
   // Default single TP
   //--------------------------------------------------

   if(!UseTakeProfit)
      return(0);

   if(TakeProfit<=0)
      return(0);

   double price=0;

   if(OrderType()==OP_BUY)
   {
      price=
         OrderOpenPrice()+
         TakeProfit*Point;
   }
   else
   if(OrderType()==OP_SELL)
   {
      price=
         OrderOpenPrice()-
         TakeProfit*Point;
   }
   else
   {
      return(0);
   }

   return(
      NormalizeDouble(
         price,
         Digits
      )
   );
}

//====================================================
// TP State
//====================================================

bool RG_TPStateExists(int ticket)
{
   if(ticket<=0)
      return(false);

   string key=
      RG_TP_DoneKey(ticket);

   if(!GlobalVariableCheck(key))
      return(false);

   return(
      GlobalVariableGet(key)>0
   );
}

//====================================================
// Mark TP Done
//====================================================

void RG_MarkTPDone(int ticket)
{
   if(ticket<=0)
      return;

   GlobalVariableSet(
      RG_TP_DoneKey(ticket),
      1.0
   );
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
      return(false);

   double target=
      RG_GetTPLevelPrice(ticket);

   if(target<=0)
      return(false);

   RefreshRates();

   if(OrderType()==OP_BUY)
      return(Bid>=target);

   if(OrderType()==OP_SELL)
      return(Ask<=target);

   return(false);
}

//====================================================
// Full Position Close
//====================================================

bool RG_CloseAtTakeProfit(int ticket)
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

   double lots=
      OrderLots();

   if(lots<=0)
      return(false);

   RefreshRates();

   double price=0;

   if(OrderType()==OP_BUY)
      price=Bid;
   else
      price=Ask;

   // MT4 OrderClose slippage
   int slippage=3;

   ResetLastError();

   bool result=
      OrderClose(
         ticket,
         lots,
         price,
         slippage,
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
// Synchronize Broker TP
//====================================================

bool RG_SyncBrokerTP(int ticket)
{
   if(ticket<=0)
      return(false);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(false);

   double target=
      RG_GetTPLevelPrice(ticket);

   if(target<=0)
      return(false);

   //--------------------------------------------------
   // Manual TP is managed by RiskGuard.
   // Do not overwrite broker TP here.
   //--------------------------------------------------

   if(RG_TPManualExists(ticket))
      return(true);

   double stopLevel=
      MarketInfo(
         Symbol(),
         MODE_STOPLEVEL
      )*Point;

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

   if(!brokerOK)
      return(false);

   if(
      MathAbs(
         OrderTakeProfit()-target
      )<=Point/2.0
   )
   {
      return(true);
   }

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

//====================================================
// Process One Position
//====================================================

bool RG_ProcessTakeProfit(int ticket)
{
   if(ticket<=0)
      return(false);

   if(!UseTakeProfit)
      return(false);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
   {
      RG_ClearTPState(ticket);
      return(false);
   }

   if(OrderSymbol()!=Symbol())
      return(false);

   if(OrderMagicNumber()!=MagicNumber)
      return(false);

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(false);

   if(RG_TPStateExists(ticket))
      return(false);

   //--------------------------------------------------
   // Keep broker-side final TP synchronized
   //--------------------------------------------------

   RG_SyncBrokerTP(ticket);

   //--------------------------------------------------
   // Local TP execution
   //--------------------------------------------------

   if(!RG_IsTPReached(ticket))
      return(false);

   return(
      RG_CloseAtTakeProfit(ticket)
   );
}

//====================================================
// Process All Positions
//====================================================

void RG_ProcessTakeProfits()
{
   if(!UseTakeProfit)
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

      if(OrderType()!=OP_BUY &&
         OrderType()!=OP_SELL)
         continue;

      RG_ProcessTakeProfit(
         OrderTicket()
      );
   }
}

#endif