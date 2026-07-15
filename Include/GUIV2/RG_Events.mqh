#ifndef __RG_EVENTS_V2_MQH__
#define __RG_EVENTS_V2_MQH__

//====================================================
// Event Types
//====================================================
enum ENUM_RG_EVENT
{
   RG_EVENT_NONE = 0,
   RG_EVENT_BUTTON_CLICK,
   RG_EVENT_INPUT_CHANGED
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
void RG_SetButtonClickEvent(
   RGEvent &evt,
   const string controlName)
{
   evt.Type = RG_EVENT_BUTTON_CLICK;
   evt.ControlName = controlName;
}

//====================================================
// Input Changed
//====================================================
void RG_SetInputChangedEvent(
   RGEvent &evt,
   const string controlName)
{
   evt.Type = RG_EVENT_INPUT_CHANGED;
   evt.ControlName = controlName;
}

//====================================================
// Has Event
//====================================================
bool RG_HasEvent(const RGEvent &evt)
{
   return(evt.Type != RG_EVENT_NONE);
}

#endif