#ifndef __RG_POSITION_MANAGER_MQH__
#define __RG_POSITION_MANAGER_MQH__

#include <RG_Settings.mqh>
#include <Trade/RG_PositionSizer.mqh>
#include <Core/RG_Defines.mqh>

//====================================================
// Position Manager
//====================================================

//----------------------------------------------------
// Count Open Positions
//----------------------------------------------------
int RG_CountOpenPositions()
{
   int count = 0;

   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;

      if(OrderSymbol()!=Symbol())
         continue;

      count++;
   }

   return(count);
}

//----------------------------------------------------
// Check Position Limit
//----------------------------------------------------
bool RG_CheckPositionLimit()
{
   if(RG_CountOpenPositions() >= MaxOpenPositions)
   {
      Print("RiskGuard: Maximum open positions reached.");
      return(false);
   }

   return(true);
}

//----------------------------------------------------
// Validate New Position
//----------------------------------------------------
bool RG_CanOpenPosition(double lot)
{
   if(!RG_CheckPositionLimit())
      return(false);

   if(!RG_CheckVolumeLimit(lot))
      return(false);

   return(true);
}

#endif