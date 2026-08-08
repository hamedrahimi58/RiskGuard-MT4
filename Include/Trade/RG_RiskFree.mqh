#ifndef __RG_RISKFREE_MQH__
#define __RG_RISKFREE_MQH__

#include <RG_Settings.mqh>


//====================================================
// RiskGuard MT4
// SINGLE POSITION RISK FREE
//
// - Move SL to Break Even + Offset
// - Keep existing TP
// - Store RiskFree state
// - Compatible with RG_PositionManager
//====================================================


//====================================================
// RiskFree State Key
//====================================================

string RG_RF_StateKey(int ticket)
{
   return(
      "RG_RF_DONE_" +
      IntegerToString(ticket)
   );
}


//====================================================
// Check RiskFree Done
//====================================================

bool RG_IsRiskFreeDone(int ticket)
{
   if(ticket<=0)
      return(false);


   string key =
      RG_RF_StateKey(ticket);


   if(!GlobalVariableCheck(key))
      return(false);


   return(
      GlobalVariableGet(key)>0
   );
}


//====================================================
// Mark RiskFree Done
//====================================================

void RG_MarkRiskFreeDone(int ticket)
{
   if(ticket<=0)
      return;


   GlobalVariableSet(
      RG_RF_StateKey(ticket),
      1.0
   );
}


//====================================================
// Market Order Check
//====================================================

bool RG_RiskFree_IsMarketOrder()
{
   return(
      OrderType()==OP_BUY ||
      OrderType()==OP_SELL
   );
}


//====================================================
// Process One Ticket
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



   double openPrice =
      NormalizeDouble(
         OrderOpenPrice(),
         Digits);



   double trigger =
      RiskFreeTrigger * Point;



   double offset =
      (RiskFreeOffset +
       RiskFreeExtraPoints)
       * Point;



   double newSL = 0;



//====================================================
// BUY
//====================================================

   if(OrderType()==OP_BUY)
   {

      if(Bid-openPrice < trigger)
         return(false);



      newSL =
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



//====================================================
// SELL
//====================================================

   if(OrderType()==OP_SELL)
   {

      if(openPrice-Ask < trigger)
         return(false);



      newSL =
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
// Process All RiskFree
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