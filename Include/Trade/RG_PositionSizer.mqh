#ifndef __RG_POSITION_SIZER_MQH__
#define __RG_POSITION_SIZER_MQH__

#include <RG_Settings.mqh>
#include <Trade/RG_Broker.mqh>
#include <Trade/RG_RiskEngine.mqh>
#include <GUI/RG_Edit.mqh>
#include <Core/RG_Defines.mqh>

//====================================================
// Return Trading Volume
//====================================================
double RG_GetVolume()
{
   //--------------------------------------------------
   // Fixed Lot
   //--------------------------------------------------
   if(LotMode == LOT_FIXED)
   {
      double lot = FixedLot;

      string txt = RG_GetEditText(RG_PREFIX+"LOT");

      if(StringLen(txt) > 0)
      {
         double guiLot = StrToDouble(txt);

         if(guiLot > 0)
            lot = guiLot;
      }

      return(RG_NormalizeLot(lot));
   }

   //--------------------------------------------------
   // Risk Lot
   //--------------------------------------------------
   if(LotMode == LOT_RISK)
   {
      return(RG_CalculateRiskLot(StopLoss));
   }

   //--------------------------------------------------
   // Fallback
   //--------------------------------------------------
   return(RG_NormalizeLot(FixedLot));
}

#endif