#ifndef __RG_GUI_MQH__
#define __RG_GUI_MQH__

#include <RG_Settings.mqh>
#include <Core/RG_Defines.mqh>

#include <GUI/RG_Panel.mqh>
#include <GUI/RG_Label.mqh>
#include <GUI/RG_Button.mqh>
#include <GUI/RG_Edit.mqh>
#include <GUI/RG_Header.mqh>
#include <GUI/RG_StatusBar.mqh>
#include <GUI/RG_InputArea.mqh>
#include <GUI/RG_ActionButtons.mqh>
#include <GUI/RG_Footer.mqh>

//====================================================
// Create Main GUI
//====================================================

bool RG_CreatePanel()
{

   //--------------------------------------------------
   // Panel
   //--------------------------------------------------
   if(!RG_CreatePanelObject(
      RG_PANEL_NAME,
      PanelX,
      PanelY,
      PanelWidth,
      PanelHeight,
      clrBlack))
   {
      return(false);
   }



   //--------------------------------------------------
// Header
//--------------------------------------------------
RG_CreateHeader(
   PanelX,
   PanelY);

//--------------------------------------------------
// Status
//--------------------------------------------------
RG_CreateStatusBar(
   PanelX,
   PanelY);

RG_CreateInputArea(
   PanelX,
   PanelY);

RG_CreateActionButtons(
   PanelX,
   PanelY);

RG_CreateFooter(
   PanelX,
   PanelY);


   return(true);
}



//====================================================
// Delete GUI
//====================================================

void RG_DeletePanel()
{
   

   RG_DeleteFooter();

   RG_DeleteActionButtons();

   RG_DeleteInputArea();

   RG_DeleteStatusBar();

   RG_DeleteHeader();

   RG_DeletePanelObject(RG_PANEL_NAME);

   RG_DeleteStatusBar();

   RG_DeleteHeader();

   RG_DeletePanelObject(RG_PANEL_NAME);

}


#endif