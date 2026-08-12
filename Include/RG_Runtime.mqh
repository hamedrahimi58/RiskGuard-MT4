#ifndef __RG_RUNTIME_MQH__
#define __RG_RUNTIME_MQH__

#include <RG_Settings.mqh>

//====================================================
// RiskGuard MT4
// Runtime state
//
// Runtime is initialized once from Input defaults.
// Preview values are independent from live market ticks.
//
// BUY / SELL = create one frozen preview
// SET        = accept preview + send selected market order
// CANCEL     = clear preview without sending
//====================================================

double g_RG_FixedLot   = 0.0;
ENUM_RG_RISK_MODE g_RG_RiskMode = RG_RISK_LOT;
double g_RG_RiskValue = 0.0;
int    g_RG_StopLoss   = 0;
int    g_RG_TakeProfit = 0;

bool g_RG_RuntimeReady     = false;
bool g_RG_SettingsApplied = false;

int  g_RG_PreviewDirection = 0;
bool g_RG_PreviewActive = false;

double g_RG_PreviewEntry = 0.0;
double g_RG_PreviewSL    = 0.0;
double g_RG_PreviewTP    = 0.0;

bool g_RG_PreviewUsePips = false;

//====================================================
// Init
//====================================================

void RG_RuntimeInit()
{
   // IMPORTANT:
   // Do not re-read Inputs on every trade operation.
   // Runtime values must survive from preview -> SET.
   if(g_RG_RuntimeReady)
      return;

   g_RG_FixedLot   = FixedLot;
   g_RG_RiskMode   = DefaultRiskMode;
   g_RG_RiskValue  = (RiskValue>0.0 ? RiskValue : FixedLot);
   if(g_RG_RiskMode==RG_RISK_LOT && g_RG_RiskValue<=0.0)
      g_RG_RiskValue=FixedLot;
   g_RG_StopLoss   = StopLoss;
   g_RG_TakeProfit = TakeProfit;

   g_RG_RuntimeReady     = true;
   g_RG_SettingsApplied = false;

   g_RG_PreviewDirection = 0;
   g_RG_PreviewActive = false;

   g_RG_PreviewEntry = 0.0;
   g_RG_PreviewSL    = 0.0;
   g_RG_PreviewTP    = 0.0;

   g_RG_PreviewUsePips = false;
}

//====================================================
// Risk mode / value
//====================================================

ENUM_RG_RISK_MODE RG_RuntimeRiskMode()
{
   RG_RuntimeInit();
   return(g_RG_RiskMode);
}

void RG_RuntimeSetRiskMode(ENUM_RG_RISK_MODE mode)
{
   RG_RuntimeInit();
   g_RG_RiskMode=mode;
   if(mode==RG_RISK_LOT && g_RG_RiskValue<=0.0)
      g_RG_RiskValue=FixedLot;
}

double RG_RuntimeRiskValue()
{
   RG_RuntimeInit();
   return(g_RG_RiskValue);
}

void RG_RuntimeSetRiskValue(double value)
{
   RG_RuntimeInit();
   if(value>0.0)
      g_RG_RiskValue=value;
}

//====================================================
// Values
//====================================================

double RG_RuntimeFixedLot()
{
   RG_RuntimeInit();
   return(g_RG_FixedLot);
}

void RG_RuntimeSetFixedLot(double value)
{
   RG_RuntimeInit();

   if(value>0)
      g_RG_FixedLot=value;
}

int RG_RuntimeStopLoss()
{
   RG_RuntimeInit();
   return(g_RG_StopLoss);
}

void RG_RuntimeSetStopLoss(int value)
{
   RG_RuntimeInit();

   if(value>=0)
      g_RG_StopLoss=value;
}

int RG_RuntimeTakeProfit()
{
   RG_RuntimeInit();
   return(g_RG_TakeProfit);
}

void RG_RuntimeSetTakeProfit(int value)
{
   RG_RuntimeInit();

   if(value>=0)
      g_RG_TakeProfit=value;
}

//====================================================
// SET state
//====================================================

bool RG_RuntimeSettingsApplied()
{
   return(g_RG_SettingsApplied);
}

void RG_RuntimeClearSettingsApplied()
{
   g_RG_SettingsApplied=false;
}

//====================================================
// Preview direction
//====================================================

void RG_RuntimeSetPreviewDirection(int direction)
{
   RG_RuntimeInit();

   if(direction==OP_BUY || direction==OP_SELL)
   {
      g_RG_PreviewDirection=direction;
      g_RG_PreviewActive=true;
   }
   else
   {
      RG_RuntimeClearPreview();
   }
}

bool RG_RuntimePreviewActive()
{
   return(g_RG_PreviewActive);
}

int RG_RuntimePreviewDirection()
{
   return(g_RG_PreviewDirection);
}

//====================================================
// Preview prices
//====================================================

void RG_RuntimeSetPreviewPrices(
   double entry,
   double sl,
   double tp)
{
   RG_RuntimeInit();

   g_RG_PreviewEntry = entry;
   g_RG_PreviewSL    = sl;
   g_RG_PreviewTP    = tp;
}

double RG_RuntimePreviewEntry()
{
   return(g_RG_PreviewEntry);
}

double RG_RuntimePreviewSL()
{
   return(g_RG_PreviewSL);
}

double RG_RuntimePreviewTP()
{
   return(g_RG_PreviewTP);
}

//====================================================
// Preview input mode
//
// false = absolute PRICE fields
// true  = PIPS distance fields for SL / TP
// Entry is always an absolute price.
//====================================================

void RG_RuntimeSetPreviewUsePips(bool usePips)
{
   g_RG_PreviewUsePips=usePips;
}

bool RG_RuntimePreviewUsePips()
{
   return(g_RG_PreviewUsePips);
}

//====================================================
// Clear preview
//====================================================

void RG_RuntimeClearPreview()
{
   g_RG_PreviewDirection=0;
   g_RG_PreviewActive=false;

   g_RG_PreviewEntry=0.0;
   g_RG_PreviewSL=0.0;
   g_RG_PreviewTP=0.0;

   g_RG_SettingsApplied=false;
}

//====================================================
// Apply preview values
//
// The stored preview prices are the decision snapshot.
// Runtime SL/TP points are derived from that snapshot and
// are later used by the market-order protection layer.
//
// IMPORTANT:
// A market order executes at the actual market price at
// SET time. Therefore the stored distances are preserved
// from the preview decision rather than forcing a stale
// preview entry price onto a market order.
//====================================================

bool RG_RuntimeApplyPreview(
   double lot,
   double entry,
   double sl,
   double tp)
{
   RG_RuntimeInit();

   if(lot<=0)
      return(false);

   int direction=g_RG_PreviewDirection;

   if(direction!=OP_BUY && direction!=OP_SELL)
      return(false);

   if(entry<=0)
      return(false);

   if(UseStopLoss)
   {
      if(sl<=0)
         return(false);

      if(direction==OP_BUY && sl>=entry)
         return(false);

      if(direction==OP_SELL && sl<=entry)
         return(false);
   }
   else
   {
      sl=0.0;
   }

   if(UseTakeProfit)
   {
      if(tp<=0)
         return(false);

      if(direction==OP_BUY && tp<=entry)
         return(false);

      if(direction==OP_SELL && tp>=entry)
         return(false);
   }
   else
   {
      tp=0.0;
   }

   double point=MarketInfo(Symbol(),MODE_POINT);

   if(point<=0)
      return(false);

   int slPoints=0;
   int tpPoints=0;

   if(UseStopLoss)
      slPoints=(int)MathRound(MathAbs(entry-sl)/point);

   if(UseTakeProfit)
      tpPoints=(int)MathRound(MathAbs(tp-entry)/point);

   if(UseStopLoss && slPoints<=0)
      return(false);

   if(UseTakeProfit && tpPoints<=0)
      return(false);

   g_RG_FixedLot=lot;
   g_RG_StopLoss=slPoints;
   g_RG_TakeProfit=tpPoints;

   g_RG_PreviewEntry=entry;
   g_RG_PreviewSL=sl;
   g_RG_PreviewTP=tp;

   g_RG_SettingsApplied=true;

   return(true);
}

//====================================================
// Legacy-compatible GUI apply
//
// Kept for compatibility with existing modules.
// These values are interpreted as POINT distances.
//====================================================

bool RG_RuntimeApplyGUI(
   string lotText,
   string slText,
   string tpText)
{
   RG_RuntimeInit();

   if(StringLen(lotText)>0)
   {
      double lot=StrToDouble(lotText);

      if(lot>0)
         g_RG_FixedLot=lot;
   }

   if(StringLen(slText)>0)
   {
      int sl=(int)StringToInteger(slText);

      if(sl>=0)
         g_RG_StopLoss=sl;
   }

   if(StringLen(tpText)>0)
   {
      int tp=(int)StringToInteger(tpText);

      if(tp>=0)
         g_RG_TakeProfit=tp;
   }

   g_RG_SettingsApplied=true;
   return(true);
}

#endif
