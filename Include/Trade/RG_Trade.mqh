#ifndef __RG_BROKER_MQH__
#define __RG_BROKER_MQH__

//====================================================
// Broker Digits
//====================================================
int RG_Digits()
{
   return((int)MarketInfo(Symbol(),MODE_DIGITS));
}

//====================================================
// Broker Point
//====================================================
double RG_Point()
{
   return(MarketInfo(Symbol(),MODE_POINT));
}

//====================================================
// Stop Level (Points)
//====================================================
int RG_StopLevel()
{
   return((int)MarketInfo(Symbol(),MODE_STOPLEVEL));
}

//====================================================
// Freeze Level (Points)
//====================================================
int RG_FreezeLevel()
{
   return((int)MarketInfo(Symbol(),MODE_FREEZELEVEL));
}

//====================================================
// Stop Level Price Distance
//====================================================
double RG_StopLevelPrice()
{
   return(RG_StopLevel()*RG_Point());
}

//====================================================
// Normalize Price
//====================================================
double RG_NormalizePrice(double price)
{
   return(NormalizeDouble(price,RG_Digits()));
}

//====================================================
// Minimum Lot
//====================================================
double RG_MinLot()
{
   return(MarketInfo(Symbol(),MODE_MINLOT));
}

//====================================================
// Maximum Lot
//====================================================
double RG_MaxLot()
{
   return(MarketInfo(Symbol(),MODE_MAXLOT));
}

//====================================================
// Lot Step
//====================================================
double RG_LotStep()
{
   return(MarketInfo(Symbol(),MODE_LOTSTEP));
}

//====================================================
// Normalize Lot
//====================================================
double RG_NormalizeLot(double lot)
{
   double step = RG_LotStep();

   lot = MathFloor(lot/step)*step;

   if(lot < RG_MinLot())
      lot = RG_MinLot();

   if(lot > RG_MaxLot())
      lot = RG_MaxLot();

   return(NormalizeDouble(lot,2));
}

//====================================================
// Correct BUY StopLoss
//====================================================
double RG_CorrectBuySL(double sl,double openPrice)
{
   double minDistance = RG_StopLevelPrice();

   if(openPrice-sl < minDistance)
      sl = openPrice-minDistance;

   return(RG_NormalizePrice(sl));
}

//====================================================
// Correct SELL StopLoss
//====================================================
double RG_CorrectSellSL(double sl,double openPrice)
{
   double minDistance = RG_StopLevelPrice();

   if(sl-openPrice < minDistance)
      sl = openPrice+minDistance;

   return(RG_NormalizePrice(sl));
}

#endif