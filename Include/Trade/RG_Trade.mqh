#ifndef __RG_TRADE_MQH__
#define __RG_TRADE_MQH__

//====================================================
// BUY
//====================================================
bool RG_Buy(double lot=0.01)
{
   RefreshRates();

   double price=Ask;

   int ticket=OrderSend(
      Symbol(),
      OP_BUY,
      lot,
      price,
      10,
      0,
      0,
      "RiskGuard BUY",
      0,
      0,
      clrLime);

   if(ticket<0)
   {
      Print("BUY Error : ",GetLastError());
      return(false);
   }

   Print("BUY Ticket : ",ticket);

   return(true);
}

//====================================================
// SELL
//====================================================
bool RG_Sell(double lot=0.01)
{
   RefreshRates();

   double price=Bid;

   int ticket=OrderSend(
      Symbol(),
      OP_SELL,
      lot,
      price,
      10,
      0,
      0,
      "RiskGuard SELL",
      0,
      0,
      clrRed);

   if(ticket<0)
   {
      Print("SELL Error : ",GetLastError());
      return(false);
   }

   Print("SELL Ticket : ",ticket);

   return(true);
}

#endif