#ifndef __RG_ACTIONBUTTONS_MQH__
#define __RG_ACTIONBUTTONS_MQH__

#include <Core/RG_Defines.mqh>
#include <GUI/RG_Button.mqh>
#include <GUI/RG_Theme.mqh>


//====================================================
// Create Action Buttons
//====================================================

bool RG_CreateActionButtons(
   int panelX,
   int panelY
)
{

// BUY
RG_CreateButton(
   RG_PREFIX+"BUY",
   "BUY",
   panelX+180,
   panelY+65,
   RG_BUTTON_WIDTH,
   RG_BUTTON_HEIGHT,
   RG_COLOR_BUY,
   clrBlack);


// SELL
RG_CreateButton(
   RG_PREFIX+"SELL",
   "SELL",
   panelX+180,
   panelY+110,
   RG_BUTTON_WIDTH,
   RG_BUTTON_HEIGHT,
   RG_COLOR_SELL,
   clrWhite);


// BREAK EVEN
RG_CreateButton(
   RG_PREFIX+"BREAKEVEN",
   "BE",
   panelX+180,
   panelY+155,
   RG_BUTTON_WIDTH,
   RG_BUTTON_HEIGHT,
   clrDeepSkyBlue,
   clrWhite);


// RISK FREE
RG_CreateButton(
   RG_PREFIX+"RISKFREE",
   "RF",
   panelX+180,
   panelY+200,
   RG_BUTTON_WIDTH,
   RG_BUTTON_HEIGHT,
   clrDodgerBlue,
   clrWhite);


// TRAILING
RG_CreateButton(
   RG_PREFIX+"TRAILING",
   "TR",
   panelX+180,
   panelY+245,
   RG_BUTTON_WIDTH,
   RG_BUTTON_HEIGHT,
   clrMediumSeaGreen,
   clrWhite);


// CLOSE ALL
RG_CreateButton(
   RG_PREFIX+"CLOSE_ALL",
   "CA",
   panelX+180,
   panelY+290,
   RG_BUTTON_WIDTH,
   RG_BUTTON_HEIGHT,
   RG_COLOR_CLOSE,
   clrBlack);



return(true);

}



//====================================================
// Delete Buttons
//====================================================

void RG_DeleteActionButtons()
{

RG_DeleteButton(
   RG_PREFIX+"BUY");


RG_DeleteButton(
   RG_PREFIX+"SELL");


RG_DeleteButton(
   RG_PREFIX+"BREAKEVEN");


RG_DeleteButton(
   RG_PREFIX+"RISKFREE");


RG_DeleteButton(
   RG_PREFIX+"TRAILING");


RG_DeleteButton(
   RG_PREFIX+"CLOSE_ALL");

}



#endif