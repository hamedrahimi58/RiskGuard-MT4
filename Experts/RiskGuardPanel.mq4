#property strict
#property version "2.0"

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

   RG_SetLabelText(
      RG_PREFIX+"STATUS",
      "Status : READY");

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

void OnChartEvent(
   const int id,
   const long &lparam,
   const double &dparam,
   const string &sparam)
{
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      //--------------------------------------------------
      // BUY
      //--------------------------------------------------
      if(sparam==RG_PREFIX+"BUY")
      {
         RG_SetLabelText(
            RG_PREFIX+"STATUS",
            "Status : Sending BUY...");

         if(RG_Buy())
         {
            RG_SetLabelText(
               RG_PREFIX+"STATUS",
               "Status : BUY Opened");
         }
         else
         {
            RG_SetLabelText(
               RG_PREFIX+"STATUS",
               "Status : BUY Failed");
         }

         return;
      }

      //--------------------------------------------------
      // SELL
      //--------------------------------------------------
      if(sparam==RG_PREFIX+"SELL")
      {
         RG_SetLabelText(
            RG_PREFIX+"STATUS",
            "Status : Sending SELL...");

         if(RG_Sell())
         {
            RG_SetLabelText(
               RG_PREFIX+"STATUS",
               "Status : SELL Opened");
         }
         else
         {
            RG_SetLabelText(
               RG_PREFIX+"STATUS",
               "Status : SELL Failed");
         }

         return;
      }
   }
}