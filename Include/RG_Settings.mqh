#ifndef __RG_SETTINGS_MQH__
#define __RG_SETTINGS_MQH__

//====================================================
// Panel Position
//====================================================
input int PanelX = 20;
input int PanelY = 20;

//====================================================
// Panel Size
//====================================================
input int PanelWidth  = 320;
input int PanelHeight = 230;

//====================================================
// Trading
//====================================================
input double FixedLot = 0.01;

input bool UseStopLoss = true;
input int  StopLoss    = 200;

input bool UseTakeProfit = false;
input int  TakeProfit    = 400;

//====================================================
// Risk
//====================================================
input double RiskPercent = 1.0;

#endif