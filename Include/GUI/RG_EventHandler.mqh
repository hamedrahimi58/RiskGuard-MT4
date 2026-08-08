#ifndef __RG_EVENT_HANDLER_MQH__
#define __RG_EVENT_HANDLER_MQH__

#include <RG_Settings.mqh>
#include <RG_GUI.mqh>

#include <Trade/RG_Trade.mqh>
#include <Trade/RG_RiskFree.mqh>
#include <Trade/RG_PositionCloser.mqh>
#include <Trade/RG_ProtectionManager.mqh>


//====================================================
// Handle GUI Events
//====================================================

void RG_HandleEvent(const RGEvent &evt)
{

//====================================================
// BUTTON CLICK
//====================================================

if(evt.Type==RG_EVENT_BUTTON_CLICK)
{


//----------------------------------------------------
// BUY
//----------------------------------------------------

if(evt.ControlName==RG_PREFIX+"BUY")
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



//----------------------------------------------------
// SELL
//----------------------------------------------------

if(evt.ControlName==RG_PREFIX+"SELL")
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



//----------------------------------------------------
// RISK FREE
//----------------------------------------------------

if(evt.ControlName==RG_PREFIX+"RISKFREE")
{

Print("RiskFree Button Clicked");


RG_ProcessRiskFree();


RG_SetLabelText(
RG_PREFIX+"STATUS",
"Status : Risk Free Applied");


return;

}



//----------------------------------------------------
// BREAK EVEN
//----------------------------------------------------

if(evt.ControlName==RG_PREFIX+"BREAKEVEN")
{

Print("BreakEven Button Clicked");


RG_ProcessBreakEven();


RG_SetLabelText(
RG_PREFIX+"STATUS",
"Status : Break Even Applied");


return;

}



//----------------------------------------------------
// TRAILING
//----------------------------------------------------

if(evt.ControlName==RG_PREFIX+"TRAILING")
{

Print("Trailing Button Clicked");


RG_ProcessTrailing();


RG_SetLabelText(
RG_PREFIX+"STATUS",
"Status : Trailing Applied");


return;

}



//----------------------------------------------------
// CLOSE ALL
//----------------------------------------------------

if(evt.ControlName==RG_PREFIX+"CLOSE_ALL")
{

Print("Close All Button Clicked");


RG_CloseAllPositions();


RG_SetLabelText(
RG_PREFIX+"STATUS",
"Status : All Positions Closed");


return;

}


}



//====================================================
// INPUT CHANGED
//====================================================

if(evt.Type==RG_EVENT_INPUT_CHANGED)
{


if(evt.ControlName==RG_PREFIX+"SL")
{

Print(
"SL Changed : ",
RG_GetEditText(
RG_PREFIX+"SL"));

return;

}



if(evt.ControlName==RG_PREFIX+"TP")
{

Print(
"TP Changed : ",
RG_GetEditText(
RG_PREFIX+"TP"));

return;

}


}


}


#endif