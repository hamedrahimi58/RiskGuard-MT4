#ifndef __RG_POSITION_SIZER_MQH__
#define __RG_POSITION_SIZER_MQH__

#include <RG_Settings.mqh>
#include <Trade/RG_Broker.mqh>
#include <GUI/RG_Edit.mqh>
#include <Core/RG_Defines.mqh>


//====================================================
// Check Max Lot Limit
//====================================================
bool RG_CheckVolumeLimit(double lot)
{
   if(lot > MaxLot)
   {
      Print("RiskGuard: Lot limit exceeded. Requested: ",
            DoubleToString(lot,2),
            " Max: ",
            DoubleToString(MaxLot,2));

      return(false);
   }

   return(true);
}



//====================================================
// Return Trading Volume
//====================================================
double RG_GetVolume()
{

   //--------------------------------------------------
   // Read Lot From GUI
   //--------------------------------------------------
   double lot = FixedLot;


   string txt = RG_GetEditText(RG_PREFIX+"LOT");


   if(StringLen(txt) > 0)
   {
      double guiLot = StrToDouble(txt);

      if(guiLot > 0)
         lot = guiLot;
   }



   //--------------------------------------------------
   // Lot Modes
   //--------------------------------------------------
   switch(LotMode)
   {
      case LOT_FIXED:
         break;


      case LOT_RISK:
         // Risk Engine later
         break;
   }



   //--------------------------------------------------
   // Normalize
   //--------------------------------------------------
   lot = RG_NormalizeLot(lot);


   return(lot);
}


#endif