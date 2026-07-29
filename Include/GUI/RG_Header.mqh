#ifndef __RG_HEADER_MQH__
#define __RG_HEADER_MQH__

#include <GUI/RG_Theme.mqh>
#include <GUI/RG_Label.mqh>

//====================================================
// Create Header
//====================================================
bool RG_CreateHeader(
   int panelX,
   int panelY)
{
   //--------------------------------------------------
   // Title
   //--------------------------------------------------
   return RG_CreateLabel(
      RG_PREFIX+"TITLE",
      RG_NAME+" v"+RG_VERSION,
      panelX + RG_PADDING,
      panelY + 8,
      RG_COLOR_TITLE,
      RG_FONT_TITLE_SIZE);
}

//====================================================
// Delete Header
//====================================================
void RG_DeleteHeader()
{
   RG_DeleteLabel(RG_PREFIX+"TITLE");
}

#endif