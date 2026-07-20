#ifndef __RG_EVENT_HANDLER_MQH__
#define __RG_EVENT_HANDLER_MQH__

#include "RG_Events.mqh"

//====================================================
// Handle GUI Event
//====================================================
bool RG_HandleEvent(const RGEvent &evt)
{
   if(!RG_HasEvent(evt))
      return(false);

   switch(evt.Type)
   {
      //------------------------------------------------
      // Button Click
      //------------------------------------------------
      case RG_EVENT_BUTTON_CLICK:
      {
         return(true);
      }

      //------------------------------------------------
      // Input Changed
      //------------------------------------------------
      case RG_EVENT_INPUT_CHANGED:
      {
         return(true);
      }

      //------------------------------------------------
      // Input Focus
      //------------------------------------------------
      case RG_EVENT_INPUT_FOCUS:
      {
         return(true);
      }

      //------------------------------------------------
      // Input Unfocus
      //------------------------------------------------
      case RG_EVENT_INPUT_UNFOCUS:
      {
         return(true);
      }

      default:
         break;
   }

   return(false);
}

#endif