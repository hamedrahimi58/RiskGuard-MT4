#ifndef __RG_POSITION_MANAGER_MQH__
#define __RG_POSITION_MANAGER_MQH__

#include <RG_Settings.mqh>


//====================================================
// Close One Position
//====================================================
bool RG_ClosePosition(int ticket)
{
   if(ticket<=0)
      return(false);


   if(!OrderSelect(ticket,SELECT_BY_TICKET))
   {
      Print("Close Select Error : ",GetLastError());
      return(false);
   }


   RefreshRates();


   double price=0;


   if(OrderType()==OP_BUY)
      price=Bid;


   if(OrderType()==OP_SELL)
      price=Ask;


   bool result=OrderClose(
      ticket,
      OrderLots(),
      price,
      10,
      clrNONE);


   if(!result)
   {
      Print("Close Error : ",GetLastError());
      return(false);
   }


   return(true);
}



//====================================================
// Close All Symbol Positions
//====================================================
void RG_CloseAllPositions()
{

   for(int i=OrdersTotal()-1;i>=0;i--)
   {

      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {

         if(OrderSymbol()!=Symbol())
            continue;


         RG_ClosePosition(OrderTicket());

      }

   }

}



//====================================================
// Count Positions
//====================================================
int RG_PositionCount()
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


#endif