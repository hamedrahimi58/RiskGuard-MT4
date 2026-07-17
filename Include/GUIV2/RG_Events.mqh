#ifndef __RG_EVENTS_V2_MQH__
#define __RG_EVENTS_V2_MQH__

//====================================================
// Event Types
//====================================================
enum ENUM_RG_EVENT
{
   RG_EVENT_NONE = 0,
   RG_EVENT_BUTTON_CLICK,
   RG_EVENT_INPUT_CHANGED,
   RG_EVENT_INPUT_FOCUS,
   RG_EVENT_INPUT_UNFOCUS
};

//====================================================
// Event Structure
//====================================================
struct RGEvent
{
   ENUM_RG_EVENT Type;
   string        ControlName;
};

//====================================================
// Clear Event
//====================================================
void RG_ClearEvent(RGEvent &evt)
{
   evt.Type = RG_EVENT_NONE;
   evt.ControlName = "";
}

//====================================================
// Button Click
//====================================================
void RG_SetButtonClickEvent(RGEvent &evt,const string controlName)
{
   evt.Type = RG_EVENT_BUTTON_CLICK;
   evt.ControlName = controlName;
}

//====================================================
// Input Changed
//====================================================
void RG_SetInputChangedEvent(RGEvent &evt,const string controlName)
{
   evt.Type = RG_EVENT_INPUT_CHANGED;
   evt.ControlName = controlName;
}

//====================================================
// Input Focus
//====================================================
void RG_SetInputFocusEvent(RGEvent &evt,const string controlName)
{
   evt.Type = RG_EVENT_INPUT_FOCUS;
   evt.ControlName = controlName;
}

//====================================================
// Input Unfocus
//====================================================
void RG_SetInputUnfocusEvent(RGEvent &evt,const string controlName)
{
   evt.Type = RG_EVENT_INPUT_UNFOCUS;
   evt.ControlName = controlName;
}

//====================================================
// Has Event
//====================================================
bool RG_HasEvent(const RGEvent &evt)
{
   return(evt.Type!=RG_EVENT_NONE);
}

//====================================================
// Reset Event
//====================================================
void RG_ResetEvent(RGEvent &evt)
{
   RG_ClearEvent(evt);
}

//====================================================
// Convert MT4 Chart Event -> RG Event
//====================================================
bool RG_ProcessChartEvent(
   const int id,
   const long &lparam,
   const double &dparam,
   const string &sparam,
   RGEvent &evt)
{
   RG_ClearEvent(evt);

   switch(id)
   {
      //------------------------------------------------
      // Object Click
      //------------------------------------------------
      case CHARTEVENT_OBJECT_CLICK:
      {
         evt.Type        = RG_EVENT_BUTTON_CLICK;
         evt.ControlName = sparam;
         return(true);
      }

      //------------------------------------------------
      // Object Edit Finished
      //------------------------------------------------
      case CHARTEVENT_OBJECT_ENDEDIT:
      {
         evt.Type        = RG_EVENT_INPUT_CHANGED;
         evt.ControlName = sparam;
         return(true);
      }

      //------------------------------------------------
      // Mouse Down
      //------------------------------------------------
      case CHARTEVENT_CLICK:
      {
         evt.Type        = RG_EVENT_INPUT_UNFOCUS;
         evt.ControlName = "";
         return(true);
      }
   }

   return(false);
}

#endif