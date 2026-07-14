#ifndef RG_SETTINGS_MQH
#define RG_SETTINGS_MQH

//====================================================
// PANEL
//====================================================

#define RG_PANEL_NAME "RG_PANEL"

input int PanelX = 20;
input int PanelY = 20;

input int PanelWidth  = 300;
input int PanelHeight = 220;


//====================================================
// POSITION SIZE
//====================================================

enum RG_LotMode
{
   LOT_FIXED = 0,
   LOT_RISK  = 1
};

input RG_LotMode LotMode = LOT_FIXED;

input double FixedLot = 0.01;

input double RiskPercent = 1.0;


//====================================================
// STOP LOSS
//====================================================

input bool   UseStopLoss = true;
input int    StopLoss = 200;

#endif