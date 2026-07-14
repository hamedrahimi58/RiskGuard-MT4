#ifndef __RG_POSITION_SIZER_MQH__
#define __RG_POSITION_SIZER_MQH__

#include <RG_Settings.mqh>
#include <Trade/RG_Broker.mqh>

//====================================================
// Return Trading Volume
//====================================================
double RG_GetVolume()
{
   double lot = FixedLot;

   switch(LotMode)
   {
      case LOT_FIXED:
         lot = FixedLot;
         break;

      case LOT_RISK:
         // Temporary
         // Real calculation will be added
         // after Risk Engine is completed.
         lot = FixedLot;
         break;
   }

   return(RG_NormalizeLot(lot));
}

#endif