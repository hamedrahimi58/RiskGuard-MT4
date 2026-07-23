#ifndef __RG_RISK_ENGINE_MQH__
#define __RG_RISK_ENGINE_MQH__

#include <RG_Settings.mqh>
#include <Trade/RG_Broker.mqh>

//====================================================
// Risk Amount
//====================================================
double RG_GetRiskAmount()
{
   return(AccountBalance() * (RiskPercent / 100.0));
}

//====================================================
// Calculate Lot Size
//====================================================
double RG_CalculateRiskLot(const int stopLossPoints)
{
   //--------------------------------------------------
   // Invalid SL
   //--------------------------------------------------
   if(stopLossPoints <= 0)
      return(RG_NormalizeLot(FixedLot));

   //--------------------------------------------------
   // Risk Amount
   //--------------------------------------------------
   double riskMoney = RG_GetRiskAmount();

   //--------------------------------------------------
   // Tick Value
   //--------------------------------------------------
   double tickValue = MarketInfo(Symbol(),MODE_TICKVALUE);

   if(tickValue<=0)
      return(RG_NormalizeLot(FixedLot));

   //--------------------------------------------------
   // Lot
   //--------------------------------------------------
   double lot =
      riskMoney /
      (stopLossPoints * tickValue);

   return(RG_NormalizeLot(lot));
}

#endif