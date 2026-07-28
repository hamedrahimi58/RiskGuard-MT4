#ifndef __RG_POSITION_SIZER_MQH__
#define __RG_POSITION_SIZER_MQH__

#include <RG_Settings.mqh>
#include <Trade/RG_Broker.mqh>
#include <Core/RG_Defines.mqh>


//====================================================
// Check Maximum Lot Limit
//====================================================
bool RG_CheckVolumeLimit(double lot)
{

   if(lot > MaxLot)
   {
      Print(
         "RiskGuard: Lot limit exceeded. Requested: ",
         DoubleToString(lot,2),
         " Max: ",
         DoubleToString(MaxLot,2)
      );

      return(false);
   }


   return(true);
}



//====================================================
// Return Trading Volume
//====================================================
double RG_GetVolume()
{

   double lot = FixedLot;



   //--------------------------------------------------
   // Lot Modes
   //--------------------------------------------------

   switch(LotMode)
   {

      case LOT_FIXED:
         break;


      case LOT_RISK:

         // Risk Engine will be implemented later.

         break;

   }



   return(RG_NormalizeLot(lot));
}



#endif