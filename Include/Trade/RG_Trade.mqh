#ifndef __RG_TRADE_MQH__
#define __RG_TRADE_MQH__

#include <RG_Settings.mqh>
#include <Trade/RG_PositionSizer.mqh>
#include <Trade/RG_Broker.mqh>


int RG_CountOpenPositions()
{
   int count=0;

   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==Symbol())
            count++;
      }
   }

   return(count);
}



bool RG_CheckPositionLimit()
{
   if(RG_CountOpenPositions() >= MaxOpenPositions)
   {
      Print("RiskGuard: Max open positions reached");
      return(false);
   }

   return(true);
}



bool RG_ModifyOrder(
   const int ticket,
   const double sl,
   const double tp)
{
   if(ticket<=0)
      return(false);


   if(!OrderSelect(ticket,SELECT_BY_TICKET))
      return(false);


   bool result=OrderModify(
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
// BUY
//====================================================
int RG_SendBuyOrder()
{

   if(!RG_CheckPositionLimit())
      return(-1);


   RefreshRates();


   double lot=RG_GetVolume();


   if(!RG_CheckVolumeLimit(lot))
      return(-1);



   int ticket=OrderSend(
      Symbol(),
      OP_BUY,
      lot,
      Ask,
      10,
      0,
      0,
      "RiskGuard BUY",
      0,
      0,
      clrLime);



   if(ticket<0)
      return(-1);



   Sleep(500);


   if(OrderSelect(ticket,SELECT_BY_TICKET))
   {

      double sl=0;
      double tp=0;


      if(UseStopLoss)
      {
         sl=OrderOpenPrice()-StopLoss*RG_Point();
         sl=RG_CorrectBuySL(sl,OrderOpenPrice());
      }


      if(UseTakeProfit)
      {
         tp=OrderOpenPrice()+TakeProfit*RG_Point();
      }


      if(sl>0 || tp>0)
         RG_ModifyOrder(ticket,sl,tp);

   }


   return(ticket);
}



//====================================================
// SELL
//====================================================
int RG_SendSellOrder()
{

   if(!RG_CheckPositionLimit())
      return(-1);


   RefreshRates();


   double lot=RG_GetVolume();


   if(!RG_CheckVolumeLimit(lot))
      return(-1);



   int ticket=OrderSend(
      Symbol(),
      OP_SELL,
      lot,
      Bid,
      10,
      0,
      0,
      "RiskGuard SELL",
      0,
      0,
      clrRed);



   if(ticket<0)
      return(-1);



   Sleep(500);



   if(OrderSelect(ticket,SELECT_BY_TICKET))
   {

      double sl=0;
      double tp=0;


      if(UseStopLoss)
      {
         sl=OrderOpenPrice()+StopLoss*RG_Point();
         sl=RG_CorrectSellSL(sl,OrderOpenPrice());
      }


      if(UseTakeProfit)
      {
         tp=OrderOpenPrice()-TakeProfit*RG_Point();
      }


      if(sl>0 || tp>0)
         RG_ModifyOrder(ticket,sl,tp);

   }


   return(ticket);
}



bool RG_Buy()
{
   return(RG_SendBuyOrder()>0);
}



bool RG_Sell()
{
   return(RG_SendSellOrder()>0);
}


#endif