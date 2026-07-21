#ifndef __RG_TRADE_SETTINGS_MQH__
#define __RG_TRADE_SETTINGS_MQH__

//====================================================
// Trade Settings
//====================================================

struct RGTradeSettings
{
   double FixedLot;

   int StopLoss;
   int TakeProfit;

   bool UseStopLoss;
   bool UseTakeProfit;
};

//====================================================
// Global Settings
//====================================================

RGTradeSettings RGTradeConfig;

#endif