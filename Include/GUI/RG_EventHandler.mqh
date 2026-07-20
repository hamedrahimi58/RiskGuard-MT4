#ifndef __RG_EVENT_HANDLER_MQH__
#define __RG_EVENT_HANDLER_MQH__

#include <RG_Settings.mqh>
#include <RG_GUI.mqh>
#include <Trade/RG_Trade.mqh>

//====================================================
// Handle GUI Events
//====================================================
void RG_HandleEvent(const RGEvent &evt)
{
   //--------------------------------------------------
   // Button Click
   //--------------------------------------------------
   if(evt.Type==RG_EVENT_BUTTON_CLICK)
   {
      //------------------------------------------------
      // BUY
      //------------------------------------------------
      if(evt.ControlName==RG_PREFIX+"BUY")
      {
         RG_SetLabelText(
            RG_PREFIX+"STATUS",
            "Status : Sending BUY...");

         Print("BUY Button Clicked");

         if(RG_Buy())
         {
            RG_SetLabelText(
               RG_PREFIX+"STATUS",
               "Status : BUY Opened");

            Print("BUY Success");
         }
         else
         {
            RG_SetLabelText(
               RG_PREFIX+"STATUS",
               "Status : BUY Failed");

            Print("BUY Failed");
         }

         return;
      }

      //------------------------------------------------
      // SELL
      //------------------------------------------------
      if(evt.ControlName==RG_PREFIX+"SELL")
      {
         RG_SetLabelText(
            RG_PREFIX+"STATUS",
            "Status : Sending SELL...");

         Print("SELL Button Clicked");

         if(RG_Sell())
         {
            RG_SetLabelText(
               RG_PREFIX+"STATUS",
               "Status : SELL Opened");

            Print("SELL Success");
         }
         else
         {
            RG_SetLabelText(
               RG_PREFIX+"STATUS",
               "Status : SELL Failed");

            Print("SELL Failed");
         }

         return;
      }
   }

   //--------------------------------------------------
   // Input Changed
   //--------------------------------------------------
   if(evt.Type==RG_EVENT_INPUT_CHANGED)
   {
      if(evt.ControlName==RG_PREFIX+"SL")
      {
         Print("SL Changed : ",RG_GetEditText(RG_PREFIX+"SL"));
         return;
      }

      if(evt.ControlName==RG_PREFIX+"TP")
      {
         Print("TP Changed : ",RG_GetEditText(RG_PREFIX+"TP"));
         return;
      }
   }
}

#endif