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
   // Main Panel
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

   if(!RG_CreateHeader(
      PanelX,
      PanelY))
   {
      RG_DeletePanel();
      return(false);
   }

   //--------------------------------------------------
   // Status
   //--------------------------------------------------

   if(!RG_CreateStatusBar(
      PanelX,
      PanelY))
   {
      RG_DeletePanel();
      return(false);
   }

   //--------------------------------------------------
   // Input Area
   //--------------------------------------------------

   if(!RG_CreateInputArea(
      PanelX,
      PanelY))
   {
      RG_DeletePanel();
      return(false);
   }

   //--------------------------------------------------
   // Action Buttons
   //--------------------------------------------------

   if(!RG_CreateActionButtons(
      PanelX,
      PanelY))
   {
      RG_DeletePanel();
      return(false);
   }

   //--------------------------------------------------
   // Footer
   //--------------------------------------------------

   if(!RG_CreateFooter(
      PanelX,
      PanelY))
   {
      RG_DeletePanel();
      return(false);
   }

   //--------------------------------------------------
   // Initial Footer Update
   //--------------------------------------------------

   RG_UpdateFooter();

   //--------------------------------------------------
   // Chart refresh
   //--------------------------------------------------

   ChartRedraw();

   return(true);
}


//====================================================
// Delete Main GUI
//====================================================

void RG_DeletePanel()
{
   //--------------------------------------------------
   // Delete Footer
   //--------------------------------------------------

   RG_DeleteFooter();

   //--------------------------------------------------
   // Delete Action Buttons
   //--------------------------------------------------

   RG_DeleteActionButtons();

   //--------------------------------------------------
   // Delete Input Area
   //--------------------------------------------------

   RG_DeleteInputArea();

   //--------------------------------------------------
   // Delete Status
   //--------------------------------------------------

   RG_DeleteStatusBar();

   //--------------------------------------------------
   // Delete Header
   //--------------------------------------------------

   RG_DeleteHeader();

   //--------------------------------------------------
   // Delete Main Panel
   //--------------------------------------------------

   RG_DeletePanelObject(
      RG_PANEL_NAME);

   //--------------------------------------------------
   // Force chart redraw
   //--------------------------------------------------

   ChartRedraw();
}


//====================================================
// Refresh GUI
//====================================================

void RG_UpdatePanel()
{
   //--------------------------------------------------
   // Footer
   //--------------------------------------------------

   RG_UpdateFooter();

   //--------------------------------------------------
   // Refresh chart
   //--------------------------------------------------

   ChartRedraw();
}

#endif