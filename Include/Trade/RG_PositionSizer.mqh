#ifndef __RG_POSITION_SIZER_MQH__
#define __RG_POSITION_SIZER_MQH__

#include <RG_Settings.mqh>
#include <Trade/RG_Broker.mqh>
#include <GUI/RG_Edit.mqh>
#include <Core/RG_Defines.mqh>

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
   // Future Lot Modes
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