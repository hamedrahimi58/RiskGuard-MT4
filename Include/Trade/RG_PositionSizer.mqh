#ifndef __RG_POSITION_SIZER_MQH__
#define __RG_POSITION_SIZER_MQH__

#include <RG_Settings.mqh>

//====================================================
// Return Trading Volume
//====================================================
double RG_GetVolume()
{
   switch(LotMode)
   {
      case LOT_FIXED:
         return(NormalizeDouble(FixedLot,2));

      case LOT_RISK:
         // Temporary
         // Risk calculation will be implemented
         // after SL is added.
         return(NormalizeDouble(FixedLot,2));
   }

   return(NormalizeDouble(FixedLot,2));
}

#endif