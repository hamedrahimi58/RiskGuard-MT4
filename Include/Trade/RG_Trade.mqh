#ifndef __RG_TRADE_MQH__
#define __RG_TRADE_MQH__

#include <RG_Settings.mqh>
#include <Trade/RG_PositionSizer.mqh>
#include <Trade/RG_Broker.mqh>
#include <Trade/RG_PositionManager.mqh>

//====================================================
// MODIFY ORDER
//====================================================

bool RG_ModifyOrder(
   const int ticket,
   const double sl,
   const double tp)
{
   if(ticket<=0)
      return(false);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(false);

   ResetLastError();

   bool result=
      OrderModify(
         OrderTicket(),
         OrderOpenPrice(),
         sl,
         tp,
         0,
         clrNONE
      );

   if(!result)
   {
      Print(
         "RiskGuard Modify Error : ",
         GetLastError()
      );

      return(false);
   }

   return(true);
}


//====================================================
// APPLY INITIAL PROTECTION
//====================================================

bool RG_ApplyInitialProtection(
   int ticket)
{
   if(ticket<=0)
      return(false);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(false);

   double sl=0;
   double tp=0;

   //--------------------------------------------------
   // BUY
   //--------------------------------------------------

   if(OrderType()==OP_BUY)
   {
      if(UseStopLoss &&
         StopLoss>0)
      {
         sl=
            OrderOpenPrice()-
            StopLoss*RG_Point();

         sl=
            RG_CorrectBuySL(
               sl,
               OrderOpenPrice()
            );
      }

      if(UseTakeProfit &&
         TakeProfit>0)
      {
         tp=
            OrderOpenPrice()+
            TakeProfit*RG_Point();
      }
   }


   //--------------------------------------------------
   // SELL
   //--------------------------------------------------

   else
   if(OrderType()==OP_SELL)
   {
      if(UseStopLoss &&
         StopLoss>0)
      {
         sl=
            OrderOpenPrice()+
            StopLoss*RG_Point();

         sl=
            RG_CorrectSellSL(
               sl,
               OrderOpenPrice()
            );
      }

      if(UseTakeProfit &&
         TakeProfit>0)
      {
         tp=
            OrderOpenPrice()-
            TakeProfit*RG_Point();
      }
   }

   else
   {
      return(false);
   }


   //--------------------------------------------------
   // Nothing to modify
   //--------------------------------------------------

   if(sl<=0 &&
      tp<=0)
      return(true);


   return(
      RG_ModifyOrder(
         ticket,
         sl,
         tp
      )
   );
}


//====================================================
// BUY
//====================================================

int RG_SendBuyOrder()
{
   if(!RG_CheckPositionLimit())
      return(-1);

   RefreshRates();

   double lot=
      RG_GetVolume();

   if(!RG_CheckVolumeLimit(lot))
      return(-1);


   ResetLastError();

   int ticket=
      OrderSend(
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
         clrLime
      );


   if(ticket<0)
   {
      Print(
         "RiskGuard BUY OrderSend Error : ",
         GetLastError()
      );

      return(-1);
   }


   Sleep(500);


   if(!RG_ApplyInitialProtection(ticket))
   {
      Print(
         "RiskGuard BUY protection failed. Ticket=",
         ticket
      );
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

   double lot=
      RG_GetVolume();

   if(!RG_CheckVolumeLimit(lot))
      return(-1);


   ResetLastError();

   int ticket=
      OrderSend(
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
         clrRed
      );


   if(ticket<0)
   {
      Print(
         "RiskGuard SELL OrderSend Error : ",
         GetLastError()
      );

      return(-1);
   }


   Sleep(500);


   if(!RG_ApplyInitialProtection(ticket))
   {
      Print(
         "RiskGuard SELL protection failed. Ticket=",
         ticket
      );
   }


   return(ticket);
}


//====================================================
// BUY SHORTCUT
//====================================================

bool RG_Buy()
{
   return(
      RG_SendBuyOrder()>0
   );
}


//====================================================
// SELL SHORTCUT
//====================================================

bool RG_Sell()
{
   return(
      RG_SendSellOrder()>0
   );
}

#endif