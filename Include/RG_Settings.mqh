#ifndef __RG_SETTINGS_MQH__
#define __RG_SETTINGS_MQH__

//====================================================
// RiskGuard MT4
// RG-029-006
// Settings
//====================================================

//====================================================
// GENERAL
//====================================================

input string RG_SECTION_GENERAL =
   "========== GENERAL ==========";

input int MagicNumber = 29006;

input bool AllowBuy = true;

input bool AllowSell = true;

input int MaxOpenPositions = 1;


//====================================================
// LOT
//====================================================

enum ENUM_RG_LOT_MODE
{
   LOT_FIXED = 0,
   LOT_RISK  = 1
};

input string RG_SECTION_LOT =
   "========== LOT ==========";

input ENUM_RG_LOT_MODE LotMode = LOT_FIXED;

input double FixedLot = 0.01;

input double MaxLot = 100.0;

//====================================================
// RISK ENGINE / PREVIEW
//====================================================

enum ENUM_RG_RISK_MODE
{
   RG_RISK_PERCENT = 0,
   RG_RISK_DOLLAR  = 1,
   RG_RISK_LOT     = 2
};

input ENUM_RG_RISK_MODE DefaultRiskMode = RG_RISK_LOT;
input double RiskValue = 1.0;
input int ATRPeriod = 14;
input double ATRMultiplier = 1.0;
input double InitialRR = 2.0;


//====================================================
// STOP LOSS
//====================================================

input string RG_SECTION_SL =
   "========== STOP LOSS ==========";

input bool UseStopLoss = true;

input int StopLoss = 100;


//====================================================
// SINGLE TAKE PROFIT
//====================================================

input string RG_SECTION_TP =
   "========== SINGLE TAKE PROFIT ==========";

input bool UseTakeProfit = true;

input int TakeProfit = 200;


//====================================================
// RISK FREE
//====================================================

input string RG_SECTION_RISKFREE =
   "========== RISK FREE ==========";

input bool UseRiskFree = true;

input bool AutoRiskFree = true;

input int RiskFreeTrigger = 100;

input int RiskFreeOffset = 0;

input int RiskFreeExtraPoints = 0;


//====================================================
// TRAILING
//====================================================

input string RG_SECTION_TRAILING =
   "========== TRAILING ==========";

input bool UseTrailing = false;

input bool AutoTrailing = false;

input int StartTrailingAfter = 150;

input int TrailingStart = 150;

input int TrailingStop = 100;

input int TrailingStep = 10;


//====================================================
// PANEL
//====================================================

input string RG_SECTION_PANEL =
   "========== PANEL ==========";

input int PanelX = 20;

// When true, the panel is anchored to the right side of the chart
// and MT4 reserves chart-shift space for it.
input bool PanelRightAlign = false;

input int PanelY = 20;

input int PanelWidth = 640;

input int PanelHeight = 840;


//====================================================
// PANEL THEME
//====================================================

#define RG_COLOR_BACKGROUND      C'35,35,35'
#define RG_COLOR_PANEL           C'35,35,35'
#define RG_COLOR_HEADER          C'25,25,25'

#define RG_COLOR_BORDER          clrDimGray

#define RG_COLOR_TEXT            clrWhite
#define RG_COLOR_TITLE           clrWhite

#define RG_COLOR_BUY             clrLime
#define RG_COLOR_SELL            clrTomato
#define RG_COLOR_CLOSE           clrOrange

#define RG_COLOR_SUCCESS         clrLime
#define RG_COLOR_WARNING         clrGold
#define RG_COLOR_ERROR           clrRed

#define RG_COLOR_EDIT_BG         clrBlack
#define RG_COLOR_EDIT_TEXT       clrWhite


//====================================================
// FONT
//====================================================

#define RG_FONT_NAME             "Segoe UI"

#define RG_FONT_TITLE_SIZE       24
#define RG_FONT_STATUS_SIZE      20
#define RG_FONT_LABEL_SIZE       20
#define RG_FONT_BUTTON_SIZE      20


//====================================================
// LAYOUT
//====================================================

#define RG_PADDING               24

#define RG_HEADER_HEIGHT         56
#define RG_STATUS_HEIGHT         48

#define RG_EDIT_WIDTH            180
#define RG_EDIT_HEIGHT           44

#define RG_BUTTON_WIDTH          220
#define RG_BUTTON_HEIGHT         68

#define RG_ROW_SPACING           60


//====================================================
// PREFIX
//====================================================

#define RG_PREFIX "RG_"

#endif