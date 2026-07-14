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
// Stop Level
//====================================================
int RG_StopLevel()
{
   return((int)MarketInfo(Symbol(),MODE_STOPLEVEL));
}

//====================================================
// Freeze Level
//====================================================
int RG_FreezeLevel()
{
   return((int)MarketInfo(Symbol(),MODE_FREEZELEVEL));
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
// Tick Value
//====================================================
double RG_TickValue()
{
   return(MarketInfo(Symbol(),MODE_TICKVALUE));
}

//====================================================
// Tick Size
//====================================================
double RG_TickSize()
{
   return(MarketInfo(Symbol(),MODE_TICKSIZE));
}

//====================================================
// Normalize Price
//====================================================
double RG_NormalizePrice(double price)
{
   return(NormalizeDouble(price,RG_Digits()));
}

//====================================================
// Normalize Lot
//====================================================
double RG_NormalizeLot(double lot)
{
   double step=RG_LotStep();

   lot=MathFloor(lot/step)*step;

   if(lot<RG_MinLot())
      lot=RG_MinLot();

   if(lot>RG_MaxLot())
      lot=RG_MaxLot();

   return(NormalizeDouble(lot,2));
}

#endif