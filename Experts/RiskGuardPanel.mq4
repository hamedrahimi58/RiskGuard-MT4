#property strict
#property version "1.0"

//====================================================
// Includes
//====================================================

#include <RG_Settings.mqh>
#include <RG_GUI.mqh>
#include <Trade/RG_Trade.mqh>

//====================================================
// Initialization
//====================================================

int OnInit()
{
   if(!RG_CreatePanel())
      return(INIT_FAILED);

   Print("RiskGuard MT4 Started");

   return(INIT_SUCCEEDED);
}

//====================================================
// Deinitialization
//====================================================

void OnDeinit(const int reason)
{
   RG_DeletePanel();
}

//====================================================
// Tick
//====================================================

void OnTick()
{
}

//====================================================
// Chart Events
//====================================================

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if(id != CHARTEVENT_OBJECT_CLICK)
      return;

   //--------------------------------------------------
   // BUY
   //--------------------------------------------------
   if(sparam == RG_PREFIX + "BUY")
   {
      RG_Buy();
      return;
   }

   //--------------------------------------------------
   // SELL
   //--------------------------------------------------
   if(sparam == RG_PREFIX + "SELL")
   {
      RG_Sell();
      return;
   }
}