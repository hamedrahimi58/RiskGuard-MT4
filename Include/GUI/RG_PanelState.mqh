#ifndef __RG_PANELSTATE_MQH__
#define __RG_PANELSTATE_MQH__

//====================================================
// RiskGuard MT4
// Panel State Persistence
//
// Saves the panel's last known position and expanded/
// collapsed state to a small text file under
// MQL4\Files\RiskGuard\. This is what lets the panel
// "remember" where you left it.
//
// IMPORTANT for moving to another computer:
// This file lives under the terminal's Data Folder and
// does NOT travel with just the .mq4/.ex4/Include files.
// If you want the panel to open in the same place on a
// new machine, copy this file too (or keep the
// "RiskGuard" subfolder under MQL4\Files in your GitHub
// repo and pull it down on the new computer).
// If the file is missing, RG_PanelState_Load() simply
// returns false and the EA falls back to the PanelX /
// PanelY inputs, so nothing breaks either way.
//====================================================

#define RG_PANEL_STATE_FILE "RiskGuard\\RG_PanelState.csv"

void RG_PanelState_Save(int x,int y,bool expanded)
{
   // Make sure the "RiskGuard" subfolder exists first. Some older
   // MT4 builds don't auto-create subfolders on FileOpen, so this
   // is done explicitly. Safe to call even if it already exists.
   FolderCreate("RiskGuard");

   int handle=FileOpen(
      RG_PANEL_STATE_FILE,
      FILE_WRITE|FILE_CSV|FILE_ANSI,
      ','
   );

   if(handle==INVALID_HANDLE)
      return;

   FileWrite(
      handle,
      x,
      y,
      expanded ? 1 : 0
   );

   FileClose(handle);
}

// Returns true and fills x/y/expanded only if a saved state
// was found and could be read. Leaves the out-parameters
// untouched otherwise, so the caller can keep its defaults.
bool RG_PanelState_Load(int &x,int &y,bool &expanded)
{
   if(!FileIsExist(RG_PANEL_STATE_FILE))
      return(false);

   int handle=FileOpen(
      RG_PANEL_STATE_FILE,
      FILE_READ|FILE_CSV|FILE_ANSI,
      ','
   );

   if(handle==INVALID_HANDLE)
      return(false);

   bool ok=false;

   if(!FileIsEnding(handle))
   {
      int savedX=(int)FileReadNumber(handle);

      if(!FileIsEnding(handle))
      {
         int savedY=(int)FileReadNumber(handle);

         if(!FileIsEnding(handle))
         {
            int savedExpanded=(int)FileReadNumber(handle);

            x=savedX;
            y=savedY;
            expanded=(savedExpanded!=0);
            ok=true;
         }
      }
   }

   FileClose(handle);

   return(ok);
}

#endif
