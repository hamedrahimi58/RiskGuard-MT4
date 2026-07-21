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
   if(stopLossPoints <= 0)
      return(RGTradeConfig.FixedLot);

   double riskMoney = RG_GetRiskAmount();

   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);

   if(tickValue <= 0)
      return(RGTradeConfig.FixedLot);

   double lot =
      riskMoney /
      (stopLossPoints * tickValue);

   return(RG_NormalizeLot(lot));
}

#endif