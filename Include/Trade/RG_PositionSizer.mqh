#ifndef __RG_POSITION_SIZER_MQH__
#define __RG_POSITION_SIZER_MQH__

#include <RG_Settings.mqh>
#include <RG_Runtime.mqh>
#include <Trade/RG_Broker.mqh>
#include <GUI/RG_Edit.mqh>
#include <Core/RG_Defines.mqh>

//====================================================
// RiskGuard MT4
// Position Sizer
//
// Architecture:
// input       -> default configuration
// RG_Runtime  -> live runtime configuration
// PositionSizer -> consumes runtime values
//
// Fixed Lot:
// - Editable from GUI
// - Runtime value is used
//
// Risk Lot:
// - Reserved for future risk engine
//====================================================


//====================================================
// Check Max Lot Limit
//====================================================

bool RG_CheckVolumeLimit(double lot)
{
   if(lot<=0)
      return(false);

   if(lot>MaxLot)
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
// Read GUI Lot
//====================================================

double RG_ReadGUILot()
{
   string txt=
      RG_GetEditText(
         RG_PREFIX+"LOT"
      );

   if(StringLen(txt)<=0)
      return(0);

   double lot=
      StrToDouble(txt);

   if(lot<=0)
      return(0);

   return(lot);
}


//====================================================
// Return Trading Volume
//====================================================

double RG_GetVolume()
{
   //--------------------------------------------------
   // Ensure runtime state exists
   //--------------------------------------------------

   RG_RuntimeInit();


   //--------------------------------------------------
   // Start with runtime Fixed Lot
   //--------------------------------------------------

   double lot=
      RG_RuntimeFixedLot();


   //--------------------------------------------------
   // Lot Mode
   //--------------------------------------------------

   switch(LotMode)
   {
      //------------------------------------------------
      // Fixed Lot
      //------------------------------------------------

      case LOT_FIXED:
      {
         // Runtime value is authoritative.
         break;
      }


      //------------------------------------------------
      // Risk Lot
      //------------------------------------------------

      case LOT_RISK:
      {
         // Risk engine is intentionally not implemented
         // at this stage.
         //
         // Keep the runtime fixed-lot value as fallback
         // until the dedicated risk engine is introduced.
         break;
      }


      //------------------------------------------------
      // Unknown
      //------------------------------------------------

      default:
      {
         break;
      }
   }


   //--------------------------------------------------
   // Validate
   //--------------------------------------------------

   if(lot<=0)
      return(0);


   //--------------------------------------------------
   // Max configured lot
   //--------------------------------------------------

   if(!RG_CheckVolumeLimit(lot))
      return(0);


   //--------------------------------------------------
   // Broker normalization
   //--------------------------------------------------

   lot=
      RG_NormalizeLot(lot);


   //--------------------------------------------------
   // Re-check after normalization
   //--------------------------------------------------

   if(lot<=0)
      return(0);

   if(!RG_CheckVolumeLimit(lot))
      return(0);


   return(lot);
}


//====================================================
// Calculate Preview Lot from Risk Mode + SL distance
//====================================================

double RG_CalculatePreviewLot(
   int orderType,
   double entry,
   double sl)
{
   if(entry<=0 || sl<=0) return(0);
   if(orderType!=OP_BUY && orderType!=OP_SELL) return(0);

   double distance=MathAbs(entry-sl);
   double tickSize=MarketInfo(Symbol(),MODE_TICKSIZE);
   double tickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   if(distance<=0 || tickSize<=0 || tickValue<=0) return(0);

   double riskMoney=0.0;
   ENUM_RG_RISK_MODE mode=RG_RuntimeRiskMode();
   double riskValue=RG_RuntimeRiskValue();

   if(mode==RG_RISK_PERCENT)
      riskMoney=AccountEquity()*(riskValue/100.0);
   else if(mode==RG_RISK_DOLLAR)
      riskMoney=riskValue;
   else
      return(RG_NormalizeLot(riskValue));

   if(riskMoney<=0) return(0);

   double moneyPerLot=(distance/tickSize)*tickValue;
   if(moneyPerLot<=0) return(0);

   double lot=riskMoney/moneyPerLot;
   lot=RG_NormalizeLot(lot);

   if(lot<=0) return(0);
   if(MaxLot>0 && lot>MaxLot) lot=RG_NormalizeLot(MaxLot);

   return(lot);
}


//====================================================
// Calculate Stop Loss Price
//
// Returns:
// 0 = no SL
//
// Uses runtime SL value.
//====================================================

double RG_GetStopLossPrice(
   int orderType,
   double openPrice
)
{
   if(openPrice<=0)
      return(0);


   int stopLossPoints=
      RG_RuntimeStopLoss();


   if(stopLossPoints<=0)
      return(0);


   double distance=
      stopLossPoints*
      RG_Point();


   if(distance<=0)
      return(0);


   double sl=0;


   //--------------------------------------------------
   // BUY
   //--------------------------------------------------

   if(orderType==OP_BUY)
   {
      sl=
         openPrice-
         distance;

      sl=
         RG_CorrectBuySL(
            sl,
            openPrice
         );
   }


   //--------------------------------------------------
   // SELL
   //--------------------------------------------------

   else
   if(orderType==OP_SELL)
   {
      sl=
         openPrice+
         distance;

      sl=
         RG_CorrectSellSL(
            sl,
            openPrice
         );
   }


   //--------------------------------------------------
   // Unsupported order
   //--------------------------------------------------

   else
   {
      return(0);
   }


   if(sl<=0)
      return(0);


   return(
      RG_NormalizePrice(sl)
   );
}


//====================================================
// Calculate Take Profit Price
//
// Returns:
// 0 = no TP
//
// Uses runtime TP value.
//====================================================

double RG_GetTakeProfitPrice(
   int orderType,
   double openPrice
)
{
   if(openPrice<=0)
      return(0);


   if(!UseTakeProfit)
      return(0);


   int takeProfitPoints=
      RG_RuntimeTakeProfit();


   if(takeProfitPoints<=0)
      return(0);


   double distance=
      takeProfitPoints*
      RG_Point();


   if(distance<=0)
      return(0);


   double tp=0;


   //--------------------------------------------------
   // BUY
   //--------------------------------------------------

   if(orderType==OP_BUY)
   {
      tp=
         openPrice+
         distance;
   }


   //--------------------------------------------------
   // SELL
   //--------------------------------------------------

   else
   if(orderType==OP_SELL)
   {
      tp=
         openPrice-
         distance;
   }


   //--------------------------------------------------
   // Unsupported
   //--------------------------------------------------

   else
   {
      return(0);
   }


   if(tp<=0)
      return(0);


   return(
      RG_NormalizePrice(tp)
   );
}


//====================================================
// Apply GUI Runtime Settings
//
// This function is intentionally public so the EA
// event layer can call it after CHARTEVENT_OBJECT_ENDEDIT.
//====================================================

bool RG_PositionSizerApplyGUI()
{
   string lotText=
      RG_GetEditText(
         RG_PREFIX+"LOT"
      );

   string slText=
      RG_GetEditText(
         RG_PREFIX+"SL"
      );

   string tpText=
      RG_GetEditText(
         RG_PREFIX+"TP"
      );


   return(
      RG_RuntimeApplyGUI(
         lotText,
         slText,
         tpText
      )
   );
}


#endif