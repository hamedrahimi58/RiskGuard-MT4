#ifndef __RG_GUI_MQH__
#define __RG_GUI_MQH__

#include <RG_Settings.mqh>
#include <RG_Runtime.mqh>
#include <GUI/RG_Label.mqh>
#include <GUI/RG_Edit.mqh>
#include <Trade/RG_PositionCloser.mqh>
#include <Trade/RG_RiskFree.mqh>

//====================================================
// RiskGuard MT4
// GUI / PRE-TRADE CONFIRMATION
//
// BUY / SELL = preview only
// SET        = execute selected market order
// CANCEL     = remove preview without trading
//
// Preview values are frozen in Runtime.
// Live ticks do not rewrite Entry / SL / TP.
//====================================================

#define RG_GUI_PANEL           RG_PREFIX+"PANEL"
#define RG_GUI_HEADER          RG_PREFIX+"HEADER"
#define RG_GUI_PANEL_TOGGLE    RG_PREFIX+"PANEL_TOGGLE"
#define RG_GUI_TITLE           RG_PREFIX+"TITLE"
#define RG_GUI_STATUS          RG_PREFIX+"STATUS"

#define RG_GUI_ENTRY_LABEL     RG_PREFIX+"ENTRY_LABEL"
#define RG_GUI_ENTRY_INPUT     RG_PREFIX+"ENTRY_INPUT"
#define RG_GUI_LOT_LABEL       RG_PREFIX+"LOT_LABEL"
#define RG_GUI_LOT_INPUT       RG_PREFIX+"LOT_INPUT"
#define RG_GUI_SL_LABEL        RG_PREFIX+"SL_LABEL"
#define RG_GUI_SL_INPUT        RG_PREFIX+"SL_INPUT"
#define RG_GUI_TP_LABEL        RG_PREFIX+"TP_LABEL"
#define RG_GUI_TP_INPUT        RG_PREFIX+"TP_INPUT"
#define RG_GUI_MODE_LABEL      RG_PREFIX+"MODE_LABEL"
#define RG_GUI_MODE            RG_PREFIX+"MODE"

#define RG_GUI_BUY             RG_PREFIX+"BUY"
#define RG_GUI_SELL            RG_PREFIX+"SELL"
#define RG_GUI_PENDING_BUY     RG_PREFIX+"PENDING_BUY"
#define RG_GUI_PENDING_SELL    RG_PREFIX+"PENDING_SELL"
#define RG_GUI_SET             RG_PREFIX+"SET"
#define RG_GUI_CANCEL          RG_PREFIX+"CANCEL"
#define RG_GUI_CLOSE           RG_PREFIX+"CLOSE_ALL"
#define RG_GUI_TRAILING        RG_PREFIX+"TRAILING"

#define RG_GUI_RISK_INFO       RG_PREFIX+"RISK_INFO"
#define RG_GUI_ALLOWED_LOT_BG  RG_PREFIX+"ALLOWED_LOT_BG"
#define RG_GUI_PREVIEW_LOT_BG  RG_GUI_ALLOWED_LOT_BG

#define RG_GUI_RISK_MINUS      RG_PREFIX+"RISK_MINUS"
#define RG_GUI_RISK_VALUE      RG_PREFIX+"RISK_VALUE"
#define RG_GUI_RISK_PLUS       RG_PREFIX+"RISK_PLUS"
#define RG_GUI_RISK_PERCENT    RG_PREFIX+"RISK_PERCENT"
#define RG_GUI_RISK_DOLLAR     RG_PREFIX+"RISK_DOLLAR"
#define RG_GUI_RISK_LOT        RG_PREFIX+"RISK_LOT"

#define RG_GUI_SECTION         RG_PREFIX+"OPEN_POSITIONS"
#define RG_GUI_SECTION_TOGGLE  RG_PREFIX+"OPEN_POSITIONS_TOGGLE"
#define RG_GUI_SYMBOL          RG_PREFIX+"SYMBOL"
#define RG_GUI_SPREAD          RG_PREFIX+"SPREAD"
#define RG_GUI_PROFIT          RG_PREFIX+"PROFIT"

#define RG_GUI_FOOTER          RG_PREFIX+"FOOTER"
#define RG_GUI_FOOTER_TEXT     RG_PREFIX+"FOOTER_TEXT"
#define RG_GUI_MARKET_BG       RG_PREFIX+"MARKET_BG"
#define RG_GUI_MARKET_MAXLOT   RG_PREFIX+"MARKET_MAXLOT"
#define RG_GUI_MARKET_ACTIVE   RG_PREFIX+"MARKET_ACTIVE"
#define RG_GUI_MARKET_SERVER   RG_PREFIX+"MARKET_SERVER"

#define RG_GUI_POS_PREFIX      RG_PREFIX+"POS_"
#define RG_GUI_POS_ROW         "ROW_"
#define RG_GUI_POS_TEXT        "TEXT_"
#define RG_GUI_POS_INFO        "INFO_"
#define RG_GUI_POS_LOT         "LOT_"
#define RG_GUI_POS_PL_TEXT     "PLTEXT_"
#define RG_GUI_POS_BE          "BE_"
#define RG_GUI_POS_RF          "RF_"
#define RG_GUI_POS_THIRD       "THIRD_"
#define RG_GUI_POS_HALF        "HALF_"
#define RG_GUI_POS_CLOSE       "X_"
#define RG_GUI_POS_PL          "PL_"
#define RG_GUI_POS_PL_DOLLAR   "PL_D_"
#define RG_GUI_POS_PL_PERCENT  "PL_P_"

#define RG_GUI_BG              C'25,25,25'
#define RG_GUI_HEADER_BG       C'18,18,18'
#define RG_GUI_FOOTER_BG       C'18,18,18'
#define RG_GUI_REFERENCE_PANEL_W 425
#define RG_GUI_ROW_BG          C'31,31,31'
#define RG_GUI_ROW_ALT_BG      C'36,36,36'

#define RG_GUI_BORDER          clrDimGray
#define RG_GUI_TEXT            clrWhite
#define RG_GUI_MUTED           clrSilver
#define RG_GUI_GREEN           C'70,180,80'
#define RG_GUI_RED             clrTomato
#define RG_GUI_BLUE            clrDodgerBlue
#define RG_GUI_ORANGE          clrOrange
#define RG_GUI_CYAN            clrAqua
#define RG_GUI_YELLOW          clrGold

#define RG_GUI_EDIT_BG         clrBlack
#define RG_GUI_EDIT_TEXT       clrWhite
#define RG_GUI_FONT            "Times New Roman"

//====================================================
// Responsive UI scale
// Reference chart width = 2048 px
// Reference panel width = PanelWidth (normally 640 px)
//====================================================
double g_RG_GUI_UIScale=1.0;
double g_RG_GUI_DisplayScale=1.0;

int RG_GUI_S(int base);
int RG_GUI_FS(int base);

#define RG_GUI_TITLE_SIZE      RG_GUI_FS(16)
#define RG_GUI_BALANCE_SIZE    RG_GUI_FS(15)
#define RG_GUI_MARKET_TEXT_SIZE RG_GUI_FS(12)
#define RG_GUI_TEXT_SIZE       RG_GUI_FS(11)
#define RG_GUI_POSITION_TEXT_SIZE RG_GUI_FS(10)
#define RG_GUI_STATUS_SIZE     RG_GUI_FS(11)
#define RG_GUI_STATUS_ROW_H    RG_GUI_S(34)
#define RG_GUI_BUTTON_SIZE     RG_GUI_FS(10)

#define RG_GUI_PAD             RG_GUI_S(16)
#define RG_GUI_HEADER_H        RG_GUI_S(50)

#define RG_GUI_INPUT_W         RG_GUI_S(270)
#define RG_GUI_INPUT_H         RG_GUI_S(42)

#define RG_GUI_BUTTON_W        RG_GUI_S(169)
#define RG_GUI_BUTTON_H        RG_GUI_S(39)
#define RG_GUI_SMALL_BUTTON_W  RG_GUI_S(149)
#define RG_GUI_SMALL_BUTTON_H  RG_GUI_S(40)

#define RG_GUI_ROW_H           RG_GUI_S(105)
#define RG_GUI_SECTION_H       RG_GUI_S(38)
#define RG_GUI_FOOTER_H        RG_GUI_S(46)
#define RG_GUI_MARKET_H        RG_GUI_S(110)

#define RG_GUI_RISK_H          RG_GUI_S(71)
#define RG_GUI_RISK_Y          0
#define RG_GUI_POSITION_TOP    0
#define RG_GUI_ROWS_START      0
#define RG_GUI_PRIMARY_Y       0
#define RG_GUI_FIELDS_Y        0
#define RG_GUI_FIELD_STEP      RG_GUI_S(52)
#define RG_GUI_MODE_Y          0

#define RG_GUI_Z_PANEL         50000
#define RG_GUI_Z_HEADER        50011
#define RG_GUI_Z_TEXT          50019
#define RG_GUI_Z_BUTTON        50029

int  g_RG_GUI_LastChartWidth=0;
int  g_RG_GUI_LastPositionCount=-1;
int  g_RG_GUI_LastPositionTickets[8];

//====================================================
// Runtime panel position / drag state
//====================================================
// g_RG_GUI_PanelX is the LEFT margin when PanelRightAlign=false.
// g_RG_GUI_PanelX is the RIGHT margin when PanelRightAlign=true.
// g_RG_GUI_PanelY is always the TOP margin.
int  g_RG_GUI_PanelX=0;
int  g_RG_GUI_PanelY=0;
bool g_RG_GUI_PanelPositionReady=false;

bool g_RG_GUI_PanelDragging=false;
bool g_RG_GUI_PanelDragMoved=false;
bool g_RG_GUI_PanelMouseScrollWasEnabled=true;
bool g_RG_GUI_PanelMouseScrollStateCaptured=false;
int  g_RG_GUI_PanelDragStartMouseX=0;
int  g_RG_GUI_PanelDragStartMouseY=0;
int  g_RG_GUI_PanelDragStartX=0;
int  g_RG_GUI_PanelDragStartY=0;

bool g_RG_GUI_PositionsExpanded=true;
bool g_RG_GUI_PanelExpanded=true;
bool g_RG_GUI_PositionPLPercent=false;
int  g_RG_GUI_PositionPLClickMode=0;

//====================================================
// Position object names
//====================================================

string RG_GUI_PosName(string kind,int ticket)
{
   return(RG_GUI_POS_PREFIX+kind+IntegerToString(ticket));
}

string RG_GUI_PosRow(int ticket)
{
   return(RG_GUI_PosName(RG_GUI_POS_ROW,ticket));
}

string RG_GUI_PosText(int ticket)
{
   return(RG_GUI_PosName(RG_GUI_POS_TEXT,ticket));
}

string RG_GUI_PosInfo(int ticket)
{
   return(RG_GUI_PosName(RG_GUI_POS_INFO,ticket));
}

string RG_GUI_PosLot(int ticket)
{
   return(RG_GUI_PosName(RG_GUI_POS_LOT,ticket));
}

string RG_GUI_PosPLText(int ticket)
{
   return(RG_GUI_PosName(RG_GUI_POS_PL_TEXT,ticket));
}

string RG_GUI_PosBE(int ticket)
{
   return(RG_GUI_PosName(RG_GUI_POS_BE,ticket));
}

string RG_GUI_PosRF(int ticket)
{
   return(RG_GUI_PosName(RG_GUI_POS_RF,ticket));
}

string RG_GUI_PosThird(int ticket)
{
   return(RG_GUI_PosName(RG_GUI_POS_THIRD,ticket));
}

string RG_GUI_PosHalf(int ticket)
{
   return(RG_GUI_PosName(RG_GUI_POS_HALF,ticket));
}

string RG_GUI_PosClose(int ticket)
{
   return(RG_GUI_PosName(RG_GUI_POS_CLOSE,ticket));
}

string RG_GUI_PosPL(int ticket)
{
   return(RG_GUI_PosName(RG_GUI_POS_PL,ticket));
}

string RG_GUI_PosPLDollar(int ticket)
{
   return(RG_GUI_PosName(RG_GUI_POS_PL_DOLLAR,ticket));
}

string RG_GUI_PosPLPercent(int ticket)
{
   return(RG_GUI_PosName(RG_GUI_POS_PL_PERCENT,ticket));
}

bool RG_GUI_IsPositionObject(string name,string kind)
{
   if(kind==RG_GUI_POS_PL)
   {
      if(StringFind(
         name,
         RG_GUI_POS_PREFIX+RG_GUI_POS_PL_DOLLAR,
         0)==0)
      {
         g_RG_GUI_PositionPLClickMode=1;
         return(true);
      }

      if(StringFind(
         name,
         RG_GUI_POS_PREFIX+RG_GUI_POS_PL_PERCENT,
         0)==0)
      {
         g_RG_GUI_PositionPLClickMode=2;
         return(true);
      }

      if(StringFind(
         name,
         RG_GUI_POS_PREFIX+RG_GUI_POS_PL,
         0)==0)
      {
         g_RG_GUI_PositionPLClickMode=0;
         return(true);
      }
   }

   return(
      StringFind(
         name,
         RG_GUI_POS_PREFIX+kind,
         0)==0
   );
}

int RG_GUI_TicketFromPositionObject(
   string name,
   string kind)
{
   string prefix=
      RG_GUI_POS_PREFIX+kind;

   if(kind==RG_GUI_POS_PL)
   {
      if(StringFind(
         name,
         RG_GUI_POS_PREFIX+RG_GUI_POS_PL_DOLLAR,
         0)==0)
      {
         prefix=
            RG_GUI_POS_PREFIX+RG_GUI_POS_PL_DOLLAR;
      }
      else
      if(StringFind(
         name,
         RG_GUI_POS_PREFIX+RG_GUI_POS_PL_PERCENT,
         0)==0)
      {
         prefix=
            RG_GUI_POS_PREFIX+RG_GUI_POS_PL_PERCENT;
      }
   }

   if(StringFind(name,prefix,0)!=0)
      return(-1);

   return(
      (int)StringToInteger(
         StringSubstr(
            name,
            StringLen(prefix)
         )
      )
   );
}

//====================================================
// Runtime panel position
//====================================================

void RG_GUI_InitPanelPosition()
{
   if(g_RG_GUI_PanelPositionReady)
      return;

   g_RG_GUI_PanelX=PanelX;
   g_RG_GUI_PanelY=PanelY;

   if(g_RG_GUI_PanelX<5)
      g_RG_GUI_PanelX=5;

   if(g_RG_GUI_PanelY<5)
      g_RG_GUI_PanelY=5;

   g_RG_GUI_PanelPositionReady=true;
}

int RG_GUI_GetPanelY()
{
   RG_GUI_InitPanelPosition();
   return(g_RG_GUI_PanelY);
}

//====================================================
// Layout engine
//====================================================

struct RGGuiLayout
{
   int statusY;
   int primaryY;
   int pendingY;
   int fieldsY;
   int utilityY;
   int fieldStep;
   int modeY;
   int riskY;
   int previewLotY;
   int positionY;
   int rowsY;
   int rowsHeight;
   int marketY;
   int footerY;
   int panelH;
   int actionGap;
   int actionX;
   int actionW;
   int setW;
   int labelX;
   int inputX;
   int rightX;
   int contentW;
};

void RG_GUI_CalculateLayout(
   int x,
   int y,
   int w,
   int rowCount,
   bool positionsExpanded,
   RGGuiLayout &L)
{
   if(rowCount<1)
      rowCount=1;

   if(rowCount>8)
      rowCount=8;

   L.contentW=
      w-(2*RG_GUI_PAD);

   if(L.contentW<100)
      L.contentW=100;

   L.statusY=0;

   L.riskY=
      y+RG_GUI_HEADER_H+RG_GUI_S(8);

   L.previewLotY=
      L.riskY+
      RG_GUI_RISK_H+
      RG_GUI_S(8);

   // Allowed Lot card is RG_GUI_S(54) high.  Start BUY/SELL
   // below the full card so the buttons cannot overlap it.
   L.primaryY=
      L.previewLotY+
      RG_GUI_S(54)+
      RG_GUI_S(10);

   L.pendingY=
      L.primaryY+
      RG_GUI_BUTTON_H+
      RG_GUI_S(8);

   L.utilityY=
      L.pendingY+
      RG_GUI_BUTTON_H+
      RG_GUI_S(8);

   L.fieldsY=
      L.utilityY;

   L.fieldStep=0;
   L.modeY=0;

   L.positionY=
      L.utilityY+
      RG_GUI_BUTTON_H+
      10;

   L.rowsY=
      L.positionY+
      RG_GUI_SECTION_H+
      RG_GUI_S(8);

   L.rowsHeight=
      positionsExpanded ?
      rowCount*RG_GUI_ROW_H :
      0;

   L.marketY=
      L.rowsY+
      L.rowsHeight+
      8;

   L.footerY=
      L.marketY+
      RG_GUI_MARKET_H;

   L.panelH=
      (L.footerY+
       RG_GUI_FOOTER_H+
       RG_GUI_S(8))-y;

   L.actionGap=RG_GUI_S(10);

   L.actionX=
      x+RG_GUI_PAD;

   // Two wider left columns for BUY/PENDING BUY and
   // SELL/PENDING SELL. SET keeps the right column width.
   L.setW=
      (L.contentW-
       (2*L.actionGap))/3;

   L.actionW=
      (L.contentW-
       L.setW-
       (2*L.actionGap))/2;

   L.labelX=
      x+RG_GUI_PAD;

   L.inputX=0;
   L.rightX=0;
}

//====================================================
// Object helpers
//====================================================

void RG_GUI_DeleteObject(string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);
}

//====================================================
// Enable editable preview fields
//====================================================

void RG_GUI_EnablePreviewEdit(string name)
{
   if(ObjectFind(0,name)<0)
      return;

   ObjectSetInteger(
      0,name,
      OBJPROP_READONLY,
      false
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_SELECTABLE,
      true
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_SELECTED,
      false
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_HIDDEN,
      true
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_ZORDER,
      60000
   );
}

void RG_GUI_DeletePositionObjects()
{
   for(int i=ObjectsTotal()-1;i>=0;i--)
   {
      string name=ObjectName(i);

      if(StringFind(
         name,
         RG_GUI_POS_PREFIX,
         0)==0)
      {
         ObjectDelete(0,name);
      }
   }
}

void RG_DeletePanel()
{
   RG_GUI_DeletePositionObjects();

   for(int i=ObjectsTotal()-1;i>=0;i--)
   {
      string stale=ObjectName(i);

      if(StringFind(
         stale,
         RG_PREFIX,
         0)==0)
      {
         ObjectDelete(0,stale);
      }
   }

   g_RG_GUI_LastChartWidth=0;
   g_RG_GUI_LastPositionCount=-1;
   for(int k=0;k<8;k++)
      g_RG_GUI_LastPositionTickets[k]=-1;
   g_RG_GUI_PositionPLClickMode=0;

   ChartRedraw();
}

//====================================================
// Rectangle
//====================================================

bool RG_GUI_CreateRect(
   string name,
   int x,
   int y,
   int width,
   int height,
   color background,
   color border,
   int zorder)
{
   RG_GUI_DeleteObject(name);

   if(!ObjectCreate(
      0,
      name,
      OBJ_RECTANGLE_LABEL,
      0,
      0,
      0))
   {
      return(false);
   }

   ObjectSetInteger(
      0,name,
      OBJPROP_CORNER,
      CORNER_LEFT_UPPER
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_XDISTANCE,x
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_YDISTANCE,y
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_XSIZE,width
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_YSIZE,height
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_BGCOLOR,
      background
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_BORDER_COLOR,
      border
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_FILL,
      true
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_BACK,
      false
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_SELECTABLE,
      false
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_SELECTED,
      false
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_HIDDEN,
      true
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_ZORDER,
      zorder
   );

   return(true);
}

//====================================================
// Button
//====================================================

bool RG_GUI_CreateButton(
   string name,
   string text,
   int x,
   int y,
   int width,
   int height,
   color background,
   color textColor,
   int zorder)
{
   RG_GUI_DeleteObject(name);

   if(!ObjectCreate(
      0,
      name,
      OBJ_BUTTON,
      0,
      0,
      0))
   {
      return(false);
   }

   ObjectSetInteger(
      0,name,
      OBJPROP_CORNER,
      CORNER_LEFT_UPPER
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_XDISTANCE,x
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_YDISTANCE,y
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_XSIZE,width
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_YSIZE,height
   );

   ObjectSetString(
      0,name,
      OBJPROP_TEXT,
      text
   );

   ObjectSetString(
      0,name,
      OBJPROP_FONT,
      RG_GUI_FONT
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_FONTSIZE,
      RG_GUI_BUTTON_SIZE
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_BGCOLOR,
      background
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_COLOR,
      textColor
   );

   // MT4 compatibility: explicitly apply button text color through
   // the legacy API as well, preventing terminal/theme defaults from
   // leaving OBJ_BUTTON text black on some MT4 builds.
   ObjectSetText(
      name,
      text,
      RG_GUI_BUTTON_SIZE,
      RG_GUI_FONT,
      textColor
   );

   // Re-assert the modern property after ObjectSetText().
   ObjectSetInteger(
      0,name,
      OBJPROP_COLOR,
      textColor
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_BORDER_COLOR,
      RG_GUI_BORDER
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_SELECTABLE,
      false
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_SELECTED,
      false
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_HIDDEN,
      true
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_BACK,
      false
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_ZORDER,
      zorder
   );

   ObjectSetString(
      0,name,
      OBJPROP_TOOLTIP,
      ""
   );

   return(true);
}

//====================================================
// Text
//====================================================

bool RG_GUI_CreateText(
   string name,
   string text,
   int x,
   int y,
   color textColor,
   int fontSize,
   int zorder)
{
   RG_GUI_DeleteObject(name);

   if(!ObjectCreate(
      0,
      name,
      OBJ_LABEL,
      0,
      0,
      0))
   {
      return(false);
   }

   ObjectSetInteger(
      0,name,
      OBJPROP_CORNER,
      CORNER_LEFT_UPPER
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_XDISTANCE,x
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_YDISTANCE,y
   );

   ObjectSetString(
      0,name,
      OBJPROP_TEXT,
      text
   );

   ObjectSetString(
      0,name,
      OBJPROP_FONT,
      RG_GUI_FONT
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_FONTSIZE,
      fontSize
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_COLOR,
      textColor
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_SELECTABLE,
      false
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_SELECTED,
      false
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_HIDDEN,
      true
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_BACK,
      false
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_ZORDER,
      zorder
   );

   return(true);
}

void RG_GUI_SetText(
   string name,
   string text,
   color textColor)
{
   if(ObjectFind(0,name)<0)
      return;

   ObjectSetString(
      0,name,
      OBJPROP_TEXT,
      text
   );

   ObjectSetInteger(
      0,name,
      OBJPROP_COLOR,
      textColor
   );
}

void RG_StatusReady()
{
   RG_GUI_SetText(
      RG_GUI_STATUS,
      "Status : BUY/SELL = Preview | SET = Send",
      RG_GUI_YELLOW
   );
}

//====================================================
// Chart / panel layout
//====================================================

int RG_GUI_GetPanelWidth()
{
   int chartWidth=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);

   if(chartWidth<=0)
      chartWidth=2048;

   long dpi=(long)TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   if(dpi<=0)
      dpi=96;

   g_RG_GUI_DisplayScale=((double)dpi)/96.0;

   // Reference geometry: 2048px chart -> 370px panel.
   // The panel follows the chart proportion instead of being fixed to 640px.
   double scale=((double)chartWidth)/2048.0;

   if(scale<0.75)
      scale=0.75;

   if(scale>1.75)
      scale=1.75;

   g_RG_GUI_UIScale=scale;

   int w=(int)MathRound(((double)RG_GUI_REFERENCE_PANEL_W)*scale);

   // Keep a functional minimum width for the fixed Trade-tab controls.
   // The panel remains proportional on normal/larger charts, but the
   // minimum prevents the Risk row from overflowing its own panel.
   if(w<360)
      w=360;

   return(w);
}

int RG_GUI_S(int base)
{
   double scale=g_RG_GUI_UIScale;
   if(scale<=0.0)
      scale=1.0;

   int v=(int)MathRound(((double)base)*scale);
   if(v<1)
      v=1;

   return(v);
}

int RG_GUI_FS(int base)
{
   double uiScale=g_RG_GUI_UIScale;
   if(uiScale<=0.0)
      uiScale=1.0;

   double dpiScale=g_RG_GUI_DisplayScale;
   if(dpiScale<=0.0)
      dpiScale=1.0;

   // Geometry follows chart width. Font size is additionally normalized
   // against Windows/terminal DPI so the visual size remains consistent
   // across 100%, 125% and 150% display scaling.
   int v=(int)MathRound(((double)base)*uiScale/dpiScale);
   if(v<8)
      v=8;
   return(v);
}

int RG_GUI_GetPanelX(int width)
{
   RG_GUI_InitPanelPosition();

   int chartWidth=
      (int)ChartGetInteger(
         0,
         CHART_WIDTH_IN_PIXELS,
         0
      );

   if(PanelRightAlign)
   {
      int x=
         chartWidth-
         width-
         g_RG_GUI_PanelX;

      if(x<5)
         x=5;

      return(x);
   }

   return(g_RG_GUI_PanelX);
}

void RG_GUI_ReserveChartSpace(int width)
{
   RG_GUI_InitPanelPosition();

   if(!PanelRightAlign)
      return;

   int chartWidth=
      (int)ChartGetInteger(
         0,
         CHART_WIDTH_IN_PIXELS,
         0
      );

   if(chartWidth<=0)
      return;

   double percent=
      100.0*
      (width+PanelX+5)/
      chartWidth;

   if(percent<10.0)
      percent=10.0;

   if(percent>50.0)
      percent=50.0;

   ChartSetInteger(
      0,
      CHART_SHIFT,
      true
   );

   ChartSetDouble(
      0,
      CHART_SHIFT_SIZE,
      percent
   );
}

//====================================================
// Managed/account-wide active positions
//====================================================

bool RG_GUI_IsManagedOrder()
{
   return(
      OrderMagicNumber()==MagicNumber &&
      (
         OrderType()==OP_BUY ||
         OrderType()==OP_SELL
      )
   );
}

int RG_GUI_ActivePositionCount()
{
   int count=0;

   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(
         i,
         SELECT_BY_POS,
         MODE_TRADES))
      {
         continue;
      }

      if(OrderType()!=OP_BUY &&
         OrderType()!=OP_SELL)
      {
         continue;
      }

      if(RG_IsRiskFreeDone(OrderTicket()))
         continue;

      count++;
   }

   return(count);
}

//====================================================
// Position row
//
// IMPORTANT:
// Lot / P&L information is now separated into dedicated
// labels. The P/L $/% buttons have their own area and
// cannot overlap the information text.
//====================================================

void RG_GUI_DrawPositionRow(
   int ticket,
   int rowIndex,
   int x,
   int y,
   int width)
{
   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
   {
      return;
   }

   if(!RG_GUI_IsManagedOrder())
      return;

   color rowColor=
      (
         rowIndex%2==0 ?
         RG_GUI_ROW_BG :
         RG_GUI_ROW_ALT_BG
      );

   RG_GUI_CreateRect(
      RG_GUI_PosRow(ticket),
      x,
      y,
      width,
      RG_GUI_ROW_H,
      rowColor,
      RG_GUI_BORDER,
      RG_GUI_Z_PANEL+1
   );

   string side=
      (
         OrderType()==OP_BUY ?
         "BUY" :
         "SELL"
      );

   string symbol=
      OrderSymbol();

   double profit=
      OrderProfit()+
      OrderSwap()+
      OrderCommission();

   color pColor=
      (
         profit>=0 ?
         RG_GUI_GREEN :
         RG_GUI_RED
      );

   string state=
      (
         RG_IsRiskFreeDone(ticket) ?
         "  RF" :
         ""
      );

   //=================================================
   // Position title
   //=================================================

   string title=
      symbol+
      "  |  "+
      side;

   RG_GUI_CreateText(
      RG_GUI_PosText(ticket),
      title,
      x+(width/2),
      y+8,
      RG_GUI_TEXT,
      RG_GUI_POSITION_TEXT_SIZE,
      RG_GUI_Z_TEXT
   );

   ObjectSetInteger(
      0,
      RG_GUI_PosText(ticket),
      OBJPROP_XDISTANCE,
      x+(width/2)-RG_GUI_S(70)
   );

   //=================================================
   // Information row
   //
   // OLD:
   // One long text + $/% buttons on top of it.
   //
   // NEW:
   // Lot and P/L are separate labels.
   //=================================================

   double balance=
      AccountBalance();

   double pct=
      (
         balance>0.0 ?
         (profit/balance)*100.0 :
         0.0
      );

   string plText="";

   if(g_RG_GUI_PositionPLPercent)
   {
      plText=
         "P/L : "+
         (
            pct>=0.0 ?
            "+" :
            ""
         )+
         DoubleToString(pct,2)+
         "%"+
         state;
   }
   else
   {
      plText=
         "P/L : "+
         (
            profit>=0.0 ?
            "+$" :
            "-$"
         )+
         DoubleToString(
            MathAbs(profit),
            2
         )+
         state;
   }

   // Dedicated Lot label.
   RG_GUI_CreateText(
      RG_GUI_PosLot(ticket),
      "Lot : "+
      DoubleToString(
         OrderLots(),
         2
      ),
      x+RG_GUI_S(12),
      y+RG_GUI_S(40),
      RG_GUI_TEXT,
      RG_GUI_POSITION_TEXT_SIZE,
      RG_GUI_Z_TEXT
   );

   // Dedicated P/L label.
   // It is positioned before the $/% selector area.
   RG_GUI_CreateText(
      RG_GUI_PosPLText(ticket),
      plText,
      x+RG_GUI_S(150),
      y+RG_GUI_S(40),
      pColor,
      RG_GUI_POSITION_TEXT_SIZE,
      RG_GUI_Z_TEXT
   );

   //=================================================
   // P/L display selector
   //=================================================

   int plButtonW=RG_GUI_S(34);
   int plGap=RG_GUI_S(4);

   int plX=
      x+
      width-
      (
         (plButtonW*2)+
         plGap+
         12
      );

   RG_GUI_CreateButton(
      RG_GUI_PosPLDollar(ticket),
      "$",
      plX,
      y+RG_GUI_S(32),
      plButtonW,
      28,
      (
         g_RG_GUI_PositionPLPercent ?
         RG_GUI_HEADER_BG :
         RG_GUI_BLUE
      ),
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   RG_GUI_CreateButton(
      RG_GUI_PosPLPercent(ticket),
      "%",
      plX+
      plButtonW+
      plGap,
      y+RG_GUI_S(32),
      plButtonW,
      28,
      (
         g_RG_GUI_PositionPLPercent ?
         RG_GUI_BLUE :
         RG_GUI_HEADER_BG
      ),
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   //=================================================
   // Position management controls
   //=================================================

   int buttonW=RG_GUI_S(52);
   int buttonH=RG_GUI_S(32);
   int gap=RG_GUI_S(5);

   int total=
      (buttonW*5)+
      (gap*4);

   int bx=
      x+
      (width-total)/2;

   int by=
      y+RG_GUI_S(70);

   RG_GUI_CreateButton(
      RG_GUI_PosBE(ticket),
      "BE",
      bx,
      by,
      buttonW,
      buttonH,
      RG_GUI_BLUE,
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   RG_GUI_CreateButton(
      RG_GUI_PosRF(ticket),
      "RF",
      bx+
      ((buttonW+gap)*1),
      by,
      buttonW,
      buttonH,
      RG_GUI_CYAN,
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   RG_GUI_CreateButton(
      RG_GUI_PosThird(ticket),
      "1/3",
      bx+
      ((buttonW+gap)*2),
      by,
      buttonW,
      buttonH,
      RG_GUI_YELLOW,
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   RG_GUI_CreateButton(
      RG_GUI_PosHalf(ticket),
      "1/2",
      bx+
      ((buttonW+gap)*3),
      by,
      buttonW,
      buttonH,
      RG_GUI_ORANGE,
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   RG_GUI_CreateButton(
      RG_GUI_PosClose(ticket),
      "X",
      bx+
      ((buttonW+gap)*4),
      by,
      buttonW,
      buttonH,
      RG_GUI_RED,
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );
}

void RG_GUI_RebuildPositionRows(
   int x,
   int y,
   int width,
   int maxRows)
{
   RG_GUI_DeletePositionObjects();

   int row=0;

   for(int i=OrdersTotal()-1;
       i>=0 && row<maxRows;
       i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;

      if(!RG_GUI_IsManagedOrder())
         continue;

      RG_GUI_DrawPositionRow(
         OrderTicket(),
         row,
         x,
         y+(row*RG_GUI_ROW_H),
         width
      );

      row++;
   }
}

bool RG_GUI_PositionStructureChanged(int maxRows)
{
   int tickets[8];
   int count=0;

   ArrayInitialize(tickets,-1);

   for(int i=OrdersTotal()-1;
       i>=0 && count<maxRows;
       i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;

      if(!RG_GUI_IsManagedOrder())
         continue;

      tickets[count]=OrderTicket();
      count++;
   }

   if(count!=g_RG_GUI_LastPositionCount)
      return(true);

   for(int j=0;j<count;j++)
   {
      if(tickets[j]!=g_RG_GUI_LastPositionTickets[j])
         return(true);
   }

   return(false);
}

void RG_GUI_CachePositionStructure(int maxRows)
{
   g_RG_GUI_LastPositionCount=0;
   for(int k=0;k<8;k++)
      g_RG_GUI_LastPositionTickets[k]=-1;

   for(int i=OrdersTotal()-1;
       i>=0 && g_RG_GUI_LastPositionCount<maxRows;
       i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;

      if(!RG_GUI_IsManagedOrder())
         continue;

      g_RG_GUI_LastPositionTickets[g_RG_GUI_LastPositionCount]=OrderTicket();
      g_RG_GUI_LastPositionCount++;
   }
}

void RG_GUI_UpdatePositionRowValues(
   int ticket,
   int rowIndex,
   int x,
   int y,
   int width)
{
   if(!OrderSelect(ticket,SELECT_BY_TICKET))
      return;

   if(!RG_GUI_IsManagedOrder())
      return;

   double profit=OrderProfit()+OrderSwap()+OrderCommission();
   double balance=AccountBalance();
   double pct=(balance>0.0 ? (profit/balance)*100.0 : 0.0);
   string state=(RG_IsRiskFreeDone(ticket) ? "  RF" : "");

   string plText;
   if(g_RG_GUI_PositionPLPercent)
      plText="P/L : "+(pct>=0.0?"+":"")+DoubleToString(pct,2)+"%"+state;
   else
      plText="P/L : "+(profit>=0.0?"+$":"-$")+DoubleToString(MathAbs(profit),2)+state;

   if(ObjectFind(0,RG_GUI_PosLot(ticket))>=0)
      ObjectSetString(0,RG_GUI_PosLot(ticket),OBJPROP_TEXT,"Lot : "+DoubleToString(OrderLots(),2));

   if(ObjectFind(0,RG_GUI_PosPLText(ticket))>=0)
   {
      ObjectSetString(0,RG_GUI_PosPLText(ticket),OBJPROP_TEXT,plText);
      ObjectSetInteger(0,RG_GUI_PosPLText(ticket),OBJPROP_COLOR,(profit>=0.0?RG_GUI_GREEN:RG_GUI_RED));
   }

   if(ObjectFind(0,RG_GUI_PosPLDollar(ticket))>=0)
      ObjectSetInteger(0,RG_GUI_PosPLDollar(ticket),OBJPROP_BGCOLOR,(g_RG_GUI_PositionPLPercent?RG_GUI_HEADER_BG:RG_GUI_BLUE));

   if(ObjectFind(0,RG_GUI_PosPLPercent(ticket))>=0)
      ObjectSetInteger(0,RG_GUI_PosPLPercent(ticket),OBJPROP_BGCOLOR,(g_RG_GUI_PositionPLPercent?RG_GUI_BLUE:RG_GUI_HEADER_BG));

   if(ObjectFind(0,RG_GUI_PosRF(ticket))>=0)
   {
      ObjectSetInteger(0,RG_GUI_PosRF(ticket),OBJPROP_BGCOLOR,RG_GUI_CYAN);
      ObjectSetString(0,RG_GUI_PosRF(ticket),OBJPROP_TEXT,"RF");
   }
}

void RG_GUI_UpdatePositionRows(
   int x,
   int y,
   int width,
   int maxRows)
{
   if(maxRows<1)
      maxRows=1;
   if(maxRows>8)
      maxRows=8;

   if(RG_GUI_PositionStructureChanged(maxRows))
   {
      RG_GUI_RebuildPositionRows(x,y,width,maxRows);
      RG_GUI_CachePositionStructure(maxRows);
      ChartRedraw();
      return;
   }

   for(int row=0;row<g_RG_GUI_LastPositionCount && row<maxRows;row++)
   {
      int ticket=g_RG_GUI_LastPositionTickets[row];
      if(ticket>0)
         RG_GUI_UpdatePositionRowValues(
            ticket,row,x,y+(row*RG_GUI_ROW_H),width
         );
   }
}

//====================================================
// Price / Pip helpers
//====================================================

double RG_GUI_PipSize()
{
   double point=
      MarketInfo(
         Symbol(),
         MODE_POINT
      );

   int digits=
      (int)MarketInfo(
         Symbol(),
         MODE_DIGITS
      );

   if(point<=0)
      return(0);

   if(digits==3 || digits==5)
      return(point*10.0);

   return(point);
}

double RG_GUI_PointsToPips(int points)
{
   double pip=
      RG_GUI_PipSize();

   double point=
      MarketInfo(
         Symbol(),
         MODE_POINT
      );

   if(pip<=0 || point<=0)
      return(0);

   return(
      points*
      point/
      pip
   );
}

double RG_GUI_PipsToPrice(double pips)
{
   double pip=
      RG_GUI_PipSize();

   if(pip<=0)
      return(0);

   return(
      pips*pip
   );
}

//====================================================
// Preview field display
//====================================================

void RG_GUI_SetPreviewPriceFields(int direction)
{
   if(direction!=OP_BUY &&
      direction!=OP_SELL)
   {
      return;
   }

   if(!RG_RuntimePreviewActive() ||
      RG_RuntimePreviewDirection()!=direction)
   {
      RG_GUI_CreateRiskPreview(direction);
   }
   else
   {
      RG_GUI_UpdateRiskInfo();
   }
}

//====================================================
// Parse preview
//====================================================

bool RG_GUI_ParsePreviewFields(
   int direction,
   double &lot,
   double &entry,
   double &sl,
   double &tp)
{
   if(!RG_RuntimePreviewActive())
      return(false);

   if(direction!=OP_BUY &&
      direction!=OP_SELL)
   {
      return(false);
   }

   if(RG_RuntimePreviewDirection()!=direction)
      return(false);

   entry=
      RG_RuntimePreviewEntry();

   sl=
      RG_RuntimePreviewSL();

   tp=
      RG_RuntimePreviewTP();

   lot=
      RG_GUI_CalculateRiskLot(
         direction,
         entry,
         sl
      );

   if(entry<=0 || lot<=0)
      return(false);

   if(UseStopLoss)
   {
      if(sl<=0)
         return(false);

      if(direction==OP_BUY &&
         sl>=entry)
      {
         return(false);
      }

      if(direction==OP_SELL &&
         sl<=entry)
      {
         return(false);
      }
   }

   if(UseTakeProfit)
   {
      if(tp<=0)
         return(false);

      if(direction==OP_BUY &&
         tp<=entry)
      {
         return(false);
      }

      if(direction==OP_SELL &&
         tp>=entry)
      {
         return(false);
      }
   }

   if(MaxLot>0 &&
      lot>MaxLot)
   {
      lot=MaxLot;
   }

   return(true);
}

//====================================================
// Sync runtime preview
//====================================================

bool RG_GUI_SyncPreviewFromFields()
{
   if(!RG_RuntimePreviewActive())
      return(false);

   double lot,entry,sl,tp;

   return(
      RG_GUI_ParsePreviewFields(
         RG_RuntimePreviewDirection(),
         lot,
         entry,
         sl,
         tp
      )
   );
}

//====================================================
// Toggle PRICE / PIPS mode
//====================================================

void RG_GUI_ToggleProtectionMode()
{
   bool usePips=
      !RG_RuntimePreviewUsePips();

   RG_RuntimeSetPreviewUsePips(
      usePips
   );

   RG_GUI_UpdateRiskInfo();
   ChartRedraw();
}

//====================================================
// Calculate Risk Lot
//====================================================

double RG_GUI_CalculateRiskLot(
   int direction,
   double entry,
   double sl)
{
   if(direction!=OP_BUY &&
      direction!=OP_SELL)
   {
      return(0);
   }

   if(entry<=0 ||
      sl<=0)
   {
      return(0);
   }

   double stopDistance=
      MathAbs(entry-sl);

   if(stopDistance<=0)
      return(0);

   ENUM_RG_RISK_MODE mode=
      RG_RuntimeRiskMode();

   //================================================
   // FIXED LOT
   //================================================

   if(mode==RG_RISK_LOT)
   {
      double fixedLot=
         RG_RuntimeFixedLot();

      if(fixedLot<=0)
      {
         fixedLot=
            RG_RuntimeRiskValue();
      }

      if(fixedLot<=0)
      {
         fixedLot=
            MarketInfo(
               Symbol(),
               MODE_MINLOT
            );
      }

      double lotStep=
         MarketInfo(
            Symbol(),
            MODE_LOTSTEP
         );

      if(lotStep<=0)
         lotStep=0.01;

      fixedLot=
         MathFloor(
            fixedLot/
            lotStep
         )*
         lotStep;

      return(
         NormalizeDouble(
            fixedLot,
            2
         )
      );
   }

   //================================================
   // Allowed money risk
   //================================================

   double riskValue=
      RG_RuntimeRiskValue();

   if(riskValue<=0)
      return(0);

   double riskMoney=0.0;

   if(mode==RG_RISK_PERCENT)
   {
      riskMoney=
         AccountBalance()*
         riskValue/
         100.0;
   }
   else
   if(mode==RG_RISK_DOLLAR)
   {
      riskMoney=
         riskValue;
   }

   if(riskMoney<=0)
      return(0);

   //================================================
   // Broker economics
   //================================================

   double tickSize=
      MarketInfo(
         Symbol(),
         MODE_TICKSIZE
      );

   double tickValue=
      MarketInfo(
         Symbol(),
         MODE_TICKVALUE
      );

   if(tickSize<=0 ||
      tickValue<=0)
   {
      return(0);
   }

   double lossPerLot=
      (stopDistance/tickSize)*
      tickValue;

   if(lossPerLot<=0)
      return(0);

   double lot=
      riskMoney/
      lossPerLot;

   //================================================
   // Broker limits
   //================================================

   double minLot=
      MarketInfo(
         Symbol(),
         MODE_MINLOT
      );

   double brokerMaxLot=
      MarketInfo(
         Symbol(),
         MODE_MAXLOT
      );

   double lotStep=
      MarketInfo(
         Symbol(),
         MODE_LOTSTEP
      );

   if(minLot<=0)
      minLot=0.01;

   if(brokerMaxLot<=0)
      brokerMaxLot=100.0;

   if(lotStep<=0)
      lotStep=0.01;

   if(MaxLot>0 &&
      brokerMaxLot>MaxLot)
   {
      brokerMaxLot=MaxLot;
   }

   if(lot>brokerMaxLot)
      lot=brokerMaxLot;

   lot=
      MathFloor(
         lot/lotStep
      )*
      lotStep;

   if(lot<minLot)
      lot=minLot;

   if(lot>brokerMaxLot)
      lot=brokerMaxLot;

   return(
      NormalizeDouble(
         lot,
         2
      )
   );
}

//====================================================
// Dollar Risk / Reward
//====================================================

double RG_GUI_DollarPerPoint(double lot)
{
   double point=
      MarketInfo(
         Symbol(),
         MODE_POINT
      );

   double tickSize=
      MarketInfo(
         Symbol(),
         MODE_TICKSIZE
      );

   double tickValue=
      MarketInfo(
         Symbol(),
         MODE_TICKVALUE
      );

   if(point<=0 ||
      tickSize<=0 ||
      tickValue<=0 ||
      lot<=0)
   {
      return(0);
   }

   return(
      lot*
      tickValue*
      (point/tickSize)
   );
}

//====================================================
// ALLOWED LOT
//====================================================

void RG_GUI_UpdateRiskInfo()
{
   if(ObjectFind(
      0,
      RG_GUI_RISK_INFO)<0)
   {
      return;
   }

   string text=
      "ALLOWED LOT : --";

   if(RG_RuntimePreviewActive())
   {
      double lot=
         RG_GUI_CalculateRiskLot(
            RG_RuntimePreviewDirection(),
            RG_RuntimePreviewEntry(),
            RG_RuntimePreviewSL()
         );

      if(lot>0)
      {
         text=
            "ALLOWED LOT : "+
            DoubleToString(
               lot,
               2
            );
      }
   }

   RG_GUI_SetText(
      RG_GUI_RISK_INFO,
      text,
      RG_GUI_YELLOW
   );

   int panelW=
      RG_GUI_GetPanelWidth();

   int panelX=
      RG_GUI_GetPanelX(panelW);

   ObjectSetInteger(
      0,
      RG_GUI_RISK_INFO,
      OBJPROP_XDISTANCE,
      panelX+
      (panelW/2)
   );

   ObjectSetInteger(
      0,
      RG_GUI_RISK_INFO,
      OBJPROP_YDISTANCE,
      RG_GUI_GetPanelY()+
      RG_GUI_HEADER_H+
      8+
      RG_GUI_RISK_H+
      RG_GUI_S(8)+
      27
   );

   ObjectSetInteger(
      0,
      RG_GUI_RISK_INFO,
      OBJPROP_ANCHOR,
      ANCHOR_CENTER
   );
}

//====================================================
// SET validation / apply
//====================================================

bool RG_GUI_ApplySettings()
{
   if(!RG_RuntimePreviewActive())
      return(false);

   int direction=
      RG_RuntimePreviewDirection();

   double entry=
      RG_RuntimePreviewEntry();

   double sl=
      RG_RuntimePreviewSL();

   double tp=
      RG_RuntimePreviewTP();

   if(direction!=OP_BUY &&
      direction!=OP_SELL)
   {
      return(false);
   }

   if(entry<=0)
      return(false);

   if(UseStopLoss)
   {
      if(sl<=0)
         return(false);

      if(direction==OP_BUY &&
         sl>=entry)
      {
         return(false);
      }

      if(direction==OP_SELL &&
         sl<=entry)
      {
         return(false);
      }
   }

   if(UseTakeProfit)
   {
      if(tp<=0)
         return(false);

      if(direction==OP_BUY &&
         tp<=entry)
      {
         return(false);
      }

      if(direction==OP_SELL &&
         tp>=entry)
      {
         return(false);
      }
   }

   double lot=
      RG_GUI_CalculateRiskLot(
         direction,
         entry,
         sl
      );

   if(lot<=0)
      return(false);

   if(MaxLot>0 &&
      lot>MaxLot)
   {
      lot=MaxLot;
   }

   return(
      RG_RuntimeApplyPreview(
         lot,
         entry,
         sl,
         tp
      )
   );
}

//====================================================
// Risk controls
//====================================================

void RG_GUI_UpdateRiskControls()
{
   if(ObjectFind(
      0,
      RG_GUI_RISK_VALUE)<0)
   {
      return;
   }

   ENUM_RG_RISK_MODE mode=
      RG_RuntimeRiskMode();

   double value=
      RG_RuntimeRiskValue();

   int digits=2;

   if(mode==RG_RISK_PERCENT)
      digits=1;

   if(mode==RG_RISK_DOLLAR)
      digits=2;

   if(mode==RG_RISK_LOT)
      digits=2;

   RG_GUI_SetText(
      RG_GUI_RISK_VALUE,
      DoubleToString(
         value,
         digits
      ),
      RG_GUI_TEXT
   );

   if(ObjectFind(
      0,
      RG_GUI_RISK_PERCENT)>=0)
   {
      ObjectSetInteger(
         0,
         RG_GUI_RISK_PERCENT,
         OBJPROP_BGCOLOR,
         mode==RG_RISK_PERCENT ?
         RG_GUI_BLUE :
         RG_GUI_HEADER_BG
      );
   }

   if(ObjectFind(
      0,
      RG_GUI_RISK_DOLLAR)>=0)
   {
      ObjectSetInteger(
         0,
         RG_GUI_RISK_DOLLAR,
         OBJPROP_BGCOLOR,
         mode==RG_RISK_DOLLAR ?
         RG_GUI_BLUE :
         RG_GUI_HEADER_BG
      );
   }

   if(ObjectFind(
      0,
      RG_GUI_RISK_LOT)>=0)
   {
      ObjectSetInteger(
         0,
         RG_GUI_RISK_LOT,
         OBJPROP_BGCOLOR,
         mode==RG_RISK_LOT ?
         RG_GUI_BLUE :
         RG_GUI_HEADER_BG
      );
   }
}

//====================================================
// Adjust Risk
//====================================================

void RG_GUI_AdjustRisk(int direction)
{
   ENUM_RG_RISK_MODE mode=
      RG_RuntimeRiskMode();

   if(mode==RG_RISK_LOT)
   {
      RG_GUI_UpdateRiskControls();
      return;
   }

   double value=
      RG_RuntimeRiskValue();

   double step=0.1;
   double minimum=0.1;

   if(mode==RG_RISK_DOLLAR)
   {
      step=1.0;
      minimum=1.0;
   }

   value+=
      direction*
      step;

   if(value<minimum)
      value=minimum;

   int digits=
      (
         mode==RG_RISK_PERCENT ?
         1 :
         2
      );

   value=
      NormalizeDouble(
         value,
         digits
      );

   if(mode==RG_RISK_PERCENT)
   {
      if(value>100.0)
         value=100.0;
   }

   RG_RuntimeSetRiskValue(
      value
   );

   RG_GUI_UpdateRiskControls();
}

//====================================================
// Set Risk Mode
//====================================================

void RG_GUI_SetRiskMode(
   ENUM_RG_RISK_MODE mode)
{
   RG_RuntimeSetRiskMode(mode);

   double value=
      RG_RuntimeRiskValue();

   if(mode==RG_RISK_PERCENT)
   {
      if(value<=0 ||
         value>100)
      {
         value=1.0;
      }
   }
   else
   if(mode==RG_RISK_DOLLAR)
   {
      if(value<=0)
         value=1.0;
   }
   else
   {
      value=
         RG_RuntimeFixedLot();

      if(value<=0)
      {
         value=
            MarketInfo(
               Symbol(),
               MODE_MINLOT
            );
      }
   }

   RG_RuntimeSetRiskValue(
      value
   );

   RG_GUI_UpdateRiskControls();
}

//====================================================
// Create initial Preview
//====================================================

bool RG_GUI_CreateRiskPreview(int direction)
{
   if(direction!=OP_BUY &&
      direction!=OP_SELL)
   {
      return(false);
   }

   RefreshRates();

   double entry=
      (
         direction==OP_BUY ?
         Ask :
         Bid
      );

   if(entry<=0)
      return(false);

   double atr=
      iATR(
         Symbol(),
         Period(),
         ATRPeriod,
         0
      );

   if(atr<=0)
      return(false);

   double distance=
      atr*
      ATRMultiplier;

   if(distance<=0)
      return(false);

   int digits=
      (int)MarketInfo(
         Symbol(),
         MODE_DIGITS
      );

   entry=
      NormalizeDouble(
         entry,
         digits
      );

   double sl=
      (
         direction==OP_BUY ?
         entry-distance :
         entry+distance
      );

   double tp=
      (
         direction==OP_BUY ?
         entry+
         distance*
         InitialRR :
         entry-
         distance*
         InitialRR
      );

   sl=
      NormalizeDouble(
         sl,
         digits
      );

   tp=
      NormalizeDouble(
         tp,
         digits
      );

   RG_RuntimeSetPreviewDirection(
      direction
   );

   RG_RuntimeSetPreviewUsePips(
      false
   );

   RG_RuntimeSetPreviewPrices(
      entry,
      sl,
      tp
   );

   double lot=
      RG_GUI_CalculateRiskLot(
         direction,
         entry,
         sl
      );

   if(lot<=0)
      return(false);

   if(MaxLot>0 &&
      lot>MaxLot)
   {
      lot=MaxLot;
   }

   // Calculated Allowed Lot is display/trade-preview data only.
   // Configured Fixed Lot is never overwritten.

   RG_GUI_UpdateRiskInfo();

   return(true);
}

//====================================================
// Position section
//====================================================

int RG_GUI_GetPositionCount()
{
   int count=0;

   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(
         i,
         SELECT_BY_POS,
         MODE_TRADES))
      {
         continue;
      }

      if(!RG_GUI_IsManagedOrder())
         continue;

      count++;
   }

   return(count);
}

void RG_GUI_SetPanelHeight(int height)
{
   if(ObjectFind(
      0,
      RG_GUI_PANEL)>=0)
   {
      ObjectSetInteger(
         0,
         RG_GUI_PANEL,
         OBJPROP_YSIZE,
         height
      );
   }
}

void RG_GUI_UpdatePositionSectionLayout()
{
   if(!g_RG_GUI_PanelExpanded)
      return;

   int w=
      RG_GUI_GetPanelWidth();

   int x=
      RG_GUI_GetPanelX(w);

   int y=RG_GUI_GetPanelY();

   if(y<5)
      y=5;

   // Layout is based on ACTUAL open managed positions.
   // MaxOpenPositions is a trading limit, not a UI row reservation.
   int count=
      RG_GUI_GetPositionCount();

   int rows=count;

   if(rows<1)
      rows=1;

   if(rows>8)
      rows=8;

   RGGuiLayout L;

   RG_GUI_CalculateLayout(
      x,
      y,
      w,
      rows,
      g_RG_GUI_PositionsExpanded,
      L
   );

   RG_GUI_SetPanelHeight(
      L.panelH
   );

   if(ObjectFind(
      0,
      RG_GUI_MARKET_BG)>=0)
   {
      ObjectSetInteger(
         0,
         RG_GUI_MARKET_BG,
         OBJPROP_YDISTANCE,
         L.marketY
      );

      ObjectSetInteger(
         0,
         RG_GUI_MARKET_BG,
         OBJPROP_XDISTANCE,
         x+RG_GUI_PAD
      );

      ObjectSetInteger(
         0,
         RG_GUI_MARKET_BG,
         OBJPROP_XSIZE,
         w-(2*RG_GUI_PAD)
      );

      ObjectSetInteger(
         0,
         RG_GUI_MARKET_BG,
         OBJPROP_YSIZE,
         RG_GUI_MARKET_H
      );
   }

   if(ObjectFind(
      0,
      RG_GUI_SYMBOL)>=0)
   {
      ObjectSetInteger(
         0,
         RG_GUI_SYMBOL,
         OBJPROP_YDISTANCE,
         L.marketY+RG_GUI_S(8)
      );

      ObjectSetInteger(
         0,
         RG_GUI_SYMBOL,
         OBJPROP_XDISTANCE,
         x+RG_GUI_PAD+RG_GUI_S(14)
      );
   }

   if(ObjectFind(
      0,
      RG_GUI_SPREAD)>=0)
   {
      ObjectSetInteger(
         0,
         RG_GUI_SPREAD,
         OBJPROP_YDISTANCE,
         L.marketY+RG_GUI_S(8)
      );

      ObjectSetInteger(
         0,
         RG_GUI_SPREAD,
         OBJPROP_XDISTANCE,
         x+RG_GUI_PAD+((w-(2*RG_GUI_PAD))/2)
      );
   }

   if(ObjectFind(
      0,
      RG_GUI_PROFIT)>=0)
   {
      ObjectSetInteger(
         0,
         RG_GUI_PROFIT,
         OBJPROP_YDISTANCE,
         L.marketY+RG_GUI_S(82)
      );

      ObjectSetInteger(
         0,
         RG_GUI_PROFIT,
         OBJPROP_XDISTANCE,
         x+RG_GUI_PAD+RG_GUI_S(14)
      );
   }

   if(ObjectFind(
      0,
      RG_GUI_MARKET_MAXLOT)>=0)
   {
      ObjectSetInteger(
         0,
         RG_GUI_MARKET_MAXLOT,
         OBJPROP_YDISTANCE,
         L.marketY+RG_GUI_S(48)
      );

      ObjectSetInteger(
         0,
         RG_GUI_MARKET_MAXLOT,
         OBJPROP_XDISTANCE,
         x+RG_GUI_PAD+((w-(2*RG_GUI_PAD))/2)
      );
   }

   if(ObjectFind(
      0,
      RG_GUI_MARKET_ACTIVE)>=0)
   {
      ObjectSetInteger(
         0,
         RG_GUI_MARKET_ACTIVE,
         OBJPROP_YDISTANCE,
         L.marketY+RG_GUI_S(48)
      );

      ObjectSetInteger(
         0,
         RG_GUI_MARKET_ACTIVE,
         OBJPROP_XDISTANCE,
         x+RG_GUI_PAD+RG_GUI_S(14)
      );
   }

   if(ObjectFind(
      0,
      RG_GUI_MARKET_SERVER)>=0)
   {
      ObjectSetInteger(
         0,
         RG_GUI_MARKET_SERVER,
         OBJPROP_YDISTANCE,
         L.marketY+RG_GUI_S(82)
      );

      ObjectSetInteger(
         0,
         RG_GUI_MARKET_SERVER,
         OBJPROP_XDISTANCE,
         x+RG_GUI_PAD+((w-(2*RG_GUI_PAD))/2)
      );
   }

   if(ObjectFind(
      0,
      RG_GUI_FOOTER)>=0)
   {
      ObjectSetInteger(
         0,
         RG_GUI_FOOTER,
         OBJPROP_YDISTANCE,
         L.footerY
      );
   }

   if(ObjectFind(
      0,
      RG_GUI_FOOTER_TEXT)>=0)
   {
      ObjectSetInteger(
         0,
         RG_GUI_FOOTER_TEXT,
         OBJPROP_XDISTANCE,
         x+(w/2)
      );

      ObjectSetInteger(
         0,
         RG_GUI_FOOTER_TEXT,
         OBJPROP_YDISTANCE,
         L.footerY+RG_GUI_S(27)
      );

      ObjectSetInteger(
         0,
         RG_GUI_FOOTER_TEXT,
         OBJPROP_ANCHOR,
         ANCHOR_CENTER
      );
   }

   if(ObjectFind(
      0,
      RG_GUI_SECTION_TOGGLE)>=0)
   {
      string caption=
         "OPEN POSITIONS ("+
         IntegerToString(count)+
         ")  "+
         (
            g_RG_GUI_PositionsExpanded ?
            "[ - ]" :
            "[ + ]"
         );

      ObjectSetString(
         0,
         RG_GUI_SECTION_TOGGLE,
         OBJPROP_TEXT,
         caption
      );

      ObjectSetInteger(
         0,
         RG_GUI_SECTION_TOGGLE,
         OBJPROP_XDISTANCE,
         x+RG_GUI_PAD
      );

      ObjectSetInteger(
         0,
         RG_GUI_SECTION_TOGGLE,
         OBJPROP_YDISTANCE,
         L.positionY
      );

      ObjectSetInteger(
         0,
         RG_GUI_SECTION_TOGGLE,
         OBJPROP_XSIZE,
         w-(2*RG_GUI_PAD)
      );

      ObjectSetInteger(
         0,
         RG_GUI_SECTION_TOGGLE,
         OBJPROP_YSIZE,
         RG_GUI_SECTION_H
      );
   }

   if(g_RG_GUI_PositionsExpanded)
   {
      RG_GUI_UpdatePositionRows(
         x+RG_GUI_PAD,
         L.rowsY,
         w-(2*RG_GUI_PAD),
         rows
      );
   }
   else if(g_RG_GUI_LastPositionCount!=-1)
   {
      RG_GUI_DeletePositionObjects();
      g_RG_GUI_LastPositionCount=0;
   }
}

void RG_GUI_TogglePositionPL()
{
   if(g_RG_GUI_PositionPLClickMode==1)
   {
      g_RG_GUI_PositionPLPercent=false;
   }
   else
   if(g_RG_GUI_PositionPLClickMode==2)
   {
      g_RG_GUI_PositionPLPercent=true;
   }
   else
   {
      g_RG_GUI_PositionPLPercent=
         !g_RG_GUI_PositionPLPercent;
   }

   g_RG_GUI_PositionPLClickMode=0;

   RG_GUI_UpdatePositionSectionLayout();
   RG_UpdateFooter();
}

void RG_GUI_TogglePanel()
{
   g_RG_GUI_PanelExpanded=
      !g_RG_GUI_PanelExpanded;

   RG_CreatePanel();
}

void RG_GUI_TogglePositions()
{
   g_RG_GUI_PositionsExpanded=
      !g_RG_GUI_PositionsExpanded;

   RG_GUI_UpdatePositionSectionLayout();
   RG_UpdateFooter();
}

//====================================================
// Create Panel
//====================================================

bool RG_CreatePanel()
{
   RG_DeletePanel();

   int w=
      RG_GUI_GetPanelWidth();

   int x=
      RG_GUI_GetPanelX(w);

   int y=RG_GUI_GetPanelY();

   if(y<5)
      y=5;

   RG_GUI_ReserveChartSpace(0);

   //=================================================
   // Collapsed
   //=================================================

   if(!g_RG_GUI_PanelExpanded)
   {
      if(!RG_GUI_CreateRect(
         RG_GUI_PANEL,
         x,
         y,
         w,
         RG_GUI_HEADER_H,
         RG_GUI_BG,
         RG_GUI_BORDER,
         RG_GUI_Z_PANEL))
      {
         return(false);
      }

      RG_GUI_CreateRect(
         RG_GUI_HEADER,
         x,
         y,
         w,
         RG_GUI_HEADER_H,
         RG_GUI_HEADER_BG,
         RG_GUI_BORDER,
         RG_GUI_Z_HEADER
      );

      RG_GUI_CreateButton(
         RG_GUI_PANEL_TOGGLE,
         "RiskGuard MT4   [ + ]",
         x+2,
         y+RG_GUI_S(2),
         w-4,
         RG_GUI_HEADER_H-RG_GUI_S(4),
         RG_GUI_HEADER_BG,
         RG_GUI_TEXT,
         RG_GUI_Z_BUTTON
      );

      ObjectSetInteger(0,RG_GUI_PANEL_TOGGLE,OBJPROP_FONTSIZE,RG_GUI_TITLE_SIZE);
      ObjectSetText(RG_GUI_PANEL_TOGGLE,"RiskGuard MT4   [ + ]",RG_GUI_TITLE_SIZE,RG_GUI_FONT,RG_GUI_TEXT);

      g_RG_GUI_LastChartWidth=
         (int)ChartGetInteger(
            0,
            CHART_WIDTH_IN_PIXELS,
            0
         );

      ChartRedraw();

      return(true);
   }

   // Layout is based on ACTUAL open managed positions.
   // MaxOpenPositions is a trading limit, not a UI row reservation.
   int count=
      RG_GUI_GetPositionCount();

   int rows=count;

   if(rows<1)
      rows=1;

   if(rows>8)
      rows=8;

   RGGuiLayout L;

   RG_GUI_CalculateLayout(
      x,
      y,
      w,
      rows,
      g_RG_GUI_PositionsExpanded,
      L
   );

   if(!RG_GUI_CreateRect(
      RG_GUI_PANEL,
      x,
      y,
      w,
      L.panelH,
      RG_GUI_BG,
      RG_GUI_BORDER,
      RG_GUI_Z_PANEL))
   {
      return(false);
   }

   RG_GUI_CreateRect(
      RG_GUI_HEADER,
      x,
      y,
      w,
      RG_GUI_HEADER_H,
      RG_GUI_HEADER_BG,
      RG_GUI_BORDER,
      RG_GUI_Z_HEADER
   );

   RG_GUI_CreateButton(
      RG_GUI_PANEL_TOGGLE,
      "RiskGuard MT4   [ - ]",
      x+2,
      y+RG_GUI_S(2),
      w-4,
      RG_GUI_HEADER_H-RG_GUI_S(4),
      RG_GUI_HEADER_BG,
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   ObjectSetInteger(0,RG_GUI_PANEL_TOGGLE,OBJPROP_FONTSIZE,RG_GUI_TITLE_SIZE);
   ObjectSetText(RG_GUI_PANEL_TOGGLE,"RiskGuard MT4   [ - ]",RG_GUI_TITLE_SIZE,RG_GUI_FONT,RG_GUI_TEXT);

   //=================================================
   // RISK ROW
   //=================================================

   int riskY=L.riskY;
   int riskX=x+RG_GUI_PAD;

   // The Risk row must always fit INSIDE the panel.  Its six controls
   // previously used independently scaled fixed widths, which could
   // exceed the available content width on smaller charts.
   int riskAvail=w-(2*RG_GUI_PAD);
   if(riskAvail<220)
      riskAvail=220;

   int riskGap=RG_GUI_S(7);
   int riskLabelW=RG_GUI_S(60);
   int riskMinusW=RG_GUI_S(46);
   int riskValueW=RG_GUI_S(64);
   int riskPlusW=RG_GUI_S(46);
   int riskModeW=RG_GUI_S(56);

   int riskBase=
      riskLabelW+
      riskValueW+
      riskMinusW+
      riskPlusW+
      (riskModeW*3)+
      (riskGap*6);

   if(riskBase>riskAvail)
   {
      double f=((double)riskAvail)/((double)riskBase);
      if(f<0.65)
         f=0.65;

      riskLabelW=(int)MathRound(riskLabelW*f);
      riskMinusW=(int)MathRound(riskMinusW*f);
      riskValueW=(int)MathRound(riskValueW*f);
      riskPlusW=(int)MathRound(riskPlusW*f);
      riskModeW=(int)MathRound(riskModeW*f);
      riskGap=(int)MathRound(riskGap*f);
   }

   int riskRowH=RG_GUI_RISK_H;

   RG_GUI_CreateText(
      RG_PREFIX+"RISK_LABEL",
      "Risk",
      riskX,
      riskY+(riskRowH/2),
      RG_GUI_TEXT,
      RG_GUI_TEXT_SIZE,
      RG_GUI_Z_TEXT
   );

   ObjectSetInteger(
      0,
      RG_PREFIX+"RISK_LABEL",
      OBJPROP_ANCHOR,
      ANCHOR_LEFT
   );

   int rx=
      riskX+
      riskLabelW+
      riskGap;

   RG_GUI_CreateButton(
      RG_GUI_RISK_MINUS,
      "-",
      rx,
      riskY,
      riskMinusW,
      riskRowH,
      RG_GUI_HEADER_BG,
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   rx+=
      riskMinusW+
      riskGap;

   RG_GUI_CreateText(
      RG_GUI_RISK_VALUE,
      "",
      rx+(riskValueW/2),
      riskY+(riskRowH/2),
      RG_GUI_TEXT,
      RG_GUI_TEXT_SIZE,
      RG_GUI_Z_TEXT
   );

   ObjectSetInteger(
      0,
      RG_GUI_RISK_VALUE,
      OBJPROP_ANCHOR,
      ANCHOR_CENTER
   );

   rx+=
      riskValueW+
      riskGap;

   RG_GUI_CreateButton(
      RG_GUI_RISK_PLUS,
      "+",
      rx,
      riskY,
      riskPlusW,
      riskRowH,
      RG_GUI_HEADER_BG,
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   rx+=
      riskPlusW+
      riskGap;

   RG_GUI_CreateButton(
      RG_GUI_RISK_PERCENT,
      "%",
      rx,
      riskY,
      riskModeW,
      riskRowH,
      RG_GUI_HEADER_BG,
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   rx+=
      riskModeW+
      riskGap;

   RG_GUI_CreateButton(
      RG_GUI_RISK_DOLLAR,
      "$",
      rx,
      riskY,
      riskModeW,
      riskRowH,
      RG_GUI_HEADER_BG,
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   rx+=
      riskModeW+
      riskGap;

   RG_GUI_CreateButton(
      RG_GUI_RISK_LOT,
      "Lot",
      rx,
      riskY,
      riskModeW,
      riskRowH,
      RG_GUI_HEADER_BG,
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   //=================================================
   // ALLOWED LOT CARD
   //=================================================

   RG_GUI_CreateRect(
      RG_GUI_ALLOWED_LOT_BG,
      x+RG_GUI_PAD,
      L.previewLotY,
      w-(2*RG_GUI_PAD),
      54,
      RG_GUI_HEADER_BG,
      RG_GUI_BORDER,
      RG_GUI_Z_PANEL+1
   );

   RG_GUI_CreateText(
      RG_GUI_RISK_INFO,
      "ALLOWED LOT : --",
      x+(w/2),
      L.previewLotY+RG_GUI_S(27),
      RG_GUI_YELLOW,
      RG_GUI_TEXT_SIZE,
      RG_GUI_Z_TEXT
   );

   ObjectSetInteger(
      0,
      RG_GUI_RISK_INFO,
      OBJPROP_ANCHOR,
      ANCHOR_CENTER
   );

   //=================================================
   // PRIMARY ACTIONS
   //=================================================

   RG_GUI_CreateButton(
      RG_GUI_BUY,
      "BUY",
      L.actionX,
      L.primaryY,
      L.actionW,
      RG_GUI_BUTTON_H,
      RG_GUI_GREEN,
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   RG_GUI_CreateButton(
      RG_GUI_SELL,
      "SELL",
      L.actionX+
      L.actionW+
      L.actionGap,
      L.primaryY,
      L.actionW,
      RG_GUI_BUTTON_H,
      RG_GUI_RED,
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   RG_GUI_CreateButton(
      RG_GUI_SET,
      "SET",
      L.actionX+
      (L.actionW+
       L.actionGap)*2,
      L.primaryY,
      L.setW,
      (RG_GUI_BUTTON_H*2)+8,
      RG_GUI_BLUE,
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   //=================================================
   // PENDING ACTIONS
   // Direction only. EA detects STOP vs LIMIT from Entry.
   //=================================================

   RG_GUI_CreateButton(
      RG_GUI_PENDING_BUY,
      "PENDING BUY",
      L.actionX,
      L.pendingY,
      L.actionW,
      RG_GUI_BUTTON_H,
      RG_GUI_GREEN,
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   ObjectSetInteger(0,RG_GUI_PENDING_BUY,OBJPROP_FONTSIZE,RG_GUI_BUTTON_SIZE);

   RG_GUI_CreateButton(
      RG_GUI_PENDING_SELL,
      "PENDING SELL",
      L.actionX+
      L.actionW+
      L.actionGap,
      L.pendingY,
      L.actionW,
      RG_GUI_BUTTON_H,
      RG_GUI_RED,
      RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   ObjectSetInteger(0,RG_GUI_PENDING_SELL,OBJPROP_FONTSIZE,RG_GUI_BUTTON_SIZE);

   //=================================================
   // UTILITY ACTIONS
   //=================================================

   RG_GUI_CreateButton(
      RG_GUI_CLOSE,
      "CLOSE ALL",
      L.actionX,
      L.utilityY,
      L.actionW,
      RG_GUI_BUTTON_H,
      RG_GUI_ORANGE,
      clrBlack,
      RG_GUI_Z_BUTTON
   );

   RG_GUI_CreateButton(
      RG_GUI_TRAILING,
      "TRAILING",
      L.actionX+
      L.actionW+
      L.actionGap,
      L.utilityY,
      L.actionW,
      RG_GUI_BUTTON_H,
      RG_GUI_YELLOW,
      clrBlack,
      RG_GUI_Z_BUTTON
   );

   RG_GUI_CreateButton(
      RG_GUI_CANCEL,
      "CANCEL",
      L.actionX+
      (L.actionW+
       L.actionGap)*2,
      L.utilityY,
      L.setW,
      RG_GUI_BUTTON_H,
      RG_GUI_RED,
      clrBlack,
      RG_GUI_Z_BUTTON
   );

   //=================================================
   // OPEN POSITIONS
   //=================================================

   RG_GUI_CreateButton(
      RG_GUI_SECTION_TOGGLE,
      "OPEN POSITIONS ("+
      IntegerToString(count)+
      ")  "+
      (
         g_RG_GUI_PositionsExpanded ?
         "[ - ]" :
         "[ + ]"
      ),
      x+RG_GUI_PAD,
      L.positionY,
      w-(2*RG_GUI_PAD),
      RG_GUI_SECTION_H,
      RG_GUI_HEADER_BG,
      RG_GUI_YELLOW,
      RG_GUI_Z_BUTTON
   );

   //=================================================
   // MARKET / ACCOUNT INFORMATION
   //=================================================

   RG_GUI_CreateRect(
      RG_GUI_MARKET_BG,
      x+RG_GUI_PAD,
      L.marketY,
      w-(2*RG_GUI_PAD),
      RG_GUI_MARKET_H,
      RG_GUI_HEADER_BG,
      RG_GUI_BORDER,
      RG_GUI_Z_PANEL+1
   );

   RG_GUI_CreateText(
      RG_GUI_SYMBOL,
      "",
      x+RG_GUI_PAD+RG_GUI_S(14),
      L.marketY+RG_GUI_S(8),
      RG_GUI_MUTED,
      RG_GUI_MARKET_TEXT_SIZE,
      RG_GUI_Z_TEXT
   );

   RG_GUI_CreateText(
      RG_GUI_SPREAD,
      "",
      x+RG_GUI_PAD+((w-(2*RG_GUI_PAD))/2),
      L.marketY+RG_GUI_S(8),
      RG_GUI_MUTED,
      RG_GUI_MARKET_TEXT_SIZE,
      RG_GUI_Z_TEXT
   );

   RG_GUI_CreateText(
      RG_GUI_MARKET_ACTIVE,
      "",
      x+RG_GUI_PAD+RG_GUI_S(14),
      L.marketY+RG_GUI_S(48),
      RG_GUI_MUTED,
      RG_GUI_MARKET_TEXT_SIZE,
      RG_GUI_Z_TEXT
   );

   RG_GUI_CreateText(
      RG_GUI_MARKET_MAXLOT,
      "",
      x+RG_GUI_PAD+((w-(2*RG_GUI_PAD))/2),
      L.marketY+RG_GUI_S(48),
      RG_GUI_MUTED,
      RG_GUI_MARKET_TEXT_SIZE,
      RG_GUI_Z_TEXT
   );

   RG_GUI_CreateText(
      RG_GUI_PROFIT,
      "",
      x+RG_GUI_PAD+RG_GUI_S(14),
      L.marketY+RG_GUI_S(82),
      RG_GUI_GREEN,
      RG_GUI_MARKET_TEXT_SIZE,
      RG_GUI_Z_TEXT
   );

   RG_GUI_CreateText(
      RG_GUI_MARKET_SERVER,
      "",
      x+RG_GUI_PAD+((w-(2*RG_GUI_PAD))/2),
      L.marketY+RG_GUI_S(82),
      RG_GUI_YELLOW,
      RG_GUI_MARKET_TEXT_SIZE,
      RG_GUI_Z_TEXT
   );

   //=================================================
   // FOOTER
   //=================================================

   RG_GUI_CreateRect(
      RG_GUI_FOOTER,
      x,
      L.footerY,
      w,
      RG_GUI_FOOTER_H,
      RG_GUI_FOOTER_BG,
      RG_GUI_BORDER,
      RG_GUI_Z_PANEL+1
   );

   RG_GUI_CreateText(
      RG_GUI_FOOTER_TEXT,
      "",
      x+(w/2),
      L.footerY+RG_GUI_S(27),
      RG_GUI_MUTED,
      RG_GUI_BALANCE_SIZE,
      RG_GUI_Z_TEXT
   );

   ObjectSetInteger(
      0,
      RG_GUI_FOOTER_TEXT,
      OBJPROP_ANCHOR,
      ANCHOR_CENTER
   );

   g_RG_GUI_LastChartWidth=
      (int)ChartGetInteger(
         0,
         CHART_WIDTH_IN_PIXELS,
         0
      );

   RG_GUI_UpdateRiskControls();
   RG_GUI_UpdatePositionSectionLayout();
   RG_GUI_UpdateRiskInfo();
   RG_UpdateGUI();
   RG_UpdateFooter();

   ChartRedraw();

   return(true);
}

//====================================================
// Footer
//====================================================

void RG_UpdateFooter()
{
   int active=
      RG_GUI_ActivePositionCount();

   if(ObjectFind(
      0,
      RG_GUI_MARKET_MAXLOT)>=0)
   {
      RG_GUI_SetText(
         RG_GUI_MARKET_MAXLOT,
         "Max Lot : "+
         DoubleToString(
            MaxLot,
            2
         ),
         RG_GUI_MUTED
      );
   }

   if(ObjectFind(
      0,
      RG_GUI_MARKET_ACTIVE)>=0)
   {
      RG_GUI_SetText(
         RG_GUI_MARKET_ACTIVE,
         "Active : "+
         IntegerToString(active)+
         "/"+
         IntegerToString(MaxOpenPositions),
         RG_GUI_MUTED
      );
   }

   if(ObjectFind(
      0,
      RG_GUI_MARKET_SERVER)>=0)
   {
      RG_GUI_SetText(
         RG_GUI_MARKET_SERVER,
         "Server : "+
         TimeToString(
            TimeCurrent(),
            TIME_SECONDS
         ),
         RG_GUI_YELLOW
      );
   }

   if(ObjectFind(
      0,
      RG_GUI_FOOTER_TEXT)>=0)
   {
      RG_GUI_SetText(
         RG_GUI_FOOTER_TEXT,
         "Balance : "+
         DoubleToString(
            AccountBalance(),
            2
         ),
         RG_GUI_MUTED
      );
   }

   if(!g_RG_GUI_PanelExpanded &&
      ObjectFind(
         0,
         RG_GUI_PANEL_TOGGLE)>=0)
   {
      ObjectSetString(
         0,
         RG_GUI_PANEL_TOGGLE,
         OBJPROP_TEXT,
         "RiskGuard MT4   | Server: "+
         TimeToString(
            TimeCurrent(),
            TIME_SECONDS
         )+
         "   [ + ]"
      );
   }
}

//====================================================
// GUI Update
//====================================================

void RG_UpdateGUI()
{
   RefreshRates();

   int chartWidth=
      (int)ChartGetInteger(
         0,
         CHART_WIDTH_IN_PIXELS,
         0
      );

   if(g_RG_GUI_LastChartWidth>0 &&
      chartWidth>0 &&
      chartWidth!=g_RG_GUI_LastChartWidth)
   {
      RG_CreatePanel();
      return;
   }

   if(!g_RG_GUI_PanelExpanded)
      return;

   if(ObjectFind(
      0,
      RG_GUI_SYMBOL)>=0)
   {
      RG_GUI_SetText(
         RG_GUI_SYMBOL,
         "Symbol : "+
         Symbol(),
         RG_GUI_MUTED
      );
   }

   if(ObjectFind(
      0,
      RG_GUI_SPREAD)>=0)
   {
      double spread=
         (
            Point>0 ?
            (Ask-Bid)/Point :
            0
         );

      RG_GUI_SetText(
         RG_GUI_SPREAD,
         "Spread : "+
         DoubleToString(
            spread,
            1
         ),
         RG_GUI_MUTED
      );
   }

   double profit=0;

   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(
         i,
         SELECT_BY_POS,
         MODE_TRADES))
      {
         continue;
      }

      if(!RG_GUI_IsManagedOrder())
         continue;

      profit+=
         OrderProfit()+
         OrderSwap()+
         OrderCommission();
   }

   RG_GUI_SetText(
      RG_GUI_PROFIT,
      "Profit : "+
      (
         profit>=0 ?
         "+$" :
         "-$"
      )+
      DoubleToString(
         MathAbs(profit),
         2
      ),
      profit>=0 ?
      RG_GUI_GREEN :
      RG_GUI_RED
   );

   RG_GUI_UpdatePositionSectionLayout();
   RG_GUI_UpdateRiskInfo();
   RG_UpdateFooter();
}

void RG_RefreshGUI()
{
   RG_UpdateGUI();
   ChartRedraw();
}

//====================================================
// Panel Drag
//====================================================

bool RG_GUI_PointInsidePanelHeader(int px,int py)
{
   int w=RG_GUI_GetPanelWidth();
   int x=RG_GUI_GetPanelX(w);
   int y=RG_GUI_GetPanelY();

   return(
      px>=x &&
      px<=x+w &&
      py>=y &&
      py<=y+RG_GUI_HEADER_H
   );
}

void RG_GUI_MovePanelObjects(int dx,int dy)
{
   for(int i=ObjectsTotal()-1;i>=0;i--)
   {
      string name=ObjectName(i);

      // GUI objects use RG_ prefix.
      // Trade visualization uses RGTV_ and is intentionally excluded.
      if(StringFind(name,RG_PREFIX,0)!=0)
         continue;

      if(ObjectFind(0,name)<0)
         continue;

      int ox=(int)ObjectGetInteger(0,name,OBJPROP_XDISTANCE);
      int oy=(int)ObjectGetInteger(0,name,OBJPROP_YDISTANCE);

      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,ox+dx);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,oy+dy);
   }
}

void RG_GUI_SetPanelRuntimePosition(int newX,int newY)
{
   RG_GUI_InitPanelPosition();

   int w=RG_GUI_GetPanelWidth();
   int chartWidth=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);

   if(chartWidth>0)
   {
      if(PanelRightAlign)
      {
         int maxRight=chartWidth-w-5;
         if(maxRight<5)
            maxRight=5;

         if(newX<5)
            newX=5;

         if(newX>maxRight)
            newX=maxRight;
      }
      else
      {
         int maxLeft=chartWidth-w-5;
         if(maxLeft<5)
            maxLeft=5;

         if(newX<5)
            newX=5;

         if(newX>maxLeft)
            newX=maxLeft;
      }
   }
   else
   {
      if(newX<5)
         newX=5;
   }

   if(newY<5)
      newY=5;

   int chartHeight=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   if(chartHeight>0 && ObjectFind(0,RG_GUI_PANEL)>=0)
   {
      int panelHeight=(int)ObjectGetInteger(0,RG_GUI_PANEL,OBJPROP_YSIZE);
      int maxY=chartHeight-panelHeight-5;

      if(maxY<5)
         maxY=5;

      if(newY>maxY)
         newY=maxY;
   }

   g_RG_GUI_PanelX=newX;
   g_RG_GUI_PanelY=newY;
}

void RG_GUI_EndPanelDrag()
{
   if(g_RG_GUI_PanelMouseScrollStateCaptured)
   {
      ChartSetInteger(
         0,
         CHART_MOUSE_SCROLL,
         g_RG_GUI_PanelMouseScrollWasEnabled
      );

      g_RG_GUI_PanelMouseScrollStateCaptured=false;
   }

   g_RG_GUI_PanelDragging=false;
}

// Returns true when the current mouse event was consumed by panel drag.
bool RG_GUI_HandlePanelMouseMove(int x,int y,string flags)
{
   bool leftDown=(StringFind(flags,"1",0)>=0);

   if(!leftDown)
   {
      RG_GUI_EndPanelDrag();
      return(false);
   }

   if(!g_RG_GUI_PanelDragging)
   {
      if(!RG_GUI_PointInsidePanelHeader(x,y))
         return(false);

      g_RG_GUI_PanelDragging=true;
      g_RG_GUI_PanelDragMoved=false;

      // While dragging the RiskGuard panel, prevent MT4 from interpreting
      // the same left-mouse drag as a chart scroll/pan operation.
      // The previous chart setting is restored when the drag ends.
      g_RG_GUI_PanelMouseScrollWasEnabled=
         (bool)ChartGetInteger(
            0,
            CHART_MOUSE_SCROLL,
            0
         );

      g_RG_GUI_PanelMouseScrollStateCaptured=true;

      ChartSetInteger(
         0,
         CHART_MOUSE_SCROLL,
         false
      );

      g_RG_GUI_PanelDragStartMouseX=x;
      g_RG_GUI_PanelDragStartMouseY=y;
      g_RG_GUI_PanelDragStartX=g_RG_GUI_PanelX;
      g_RG_GUI_PanelDragStartY=g_RG_GUI_PanelY;
      return(true);
   }

   int dx=x-g_RG_GUI_PanelDragStartMouseX;
   int dy=y-g_RG_GUI_PanelDragStartMouseY;

   if(MathAbs(dx)<2 && MathAbs(dy)<2)
      return(true);

   int newX=g_RG_GUI_PanelDragStartX;
   int newY=g_RG_GUI_PanelDragStartY+dy;

   // In right-aligned mode PanelX is a right margin, so screen-right
   // movement means a smaller right margin.
   if(PanelRightAlign)
      newX=g_RG_GUI_PanelDragStartX-dx;
   else
      newX=g_RG_GUI_PanelDragStartX+dx;

   int oldPanelX=g_RG_GUI_PanelX;
   int oldPanelY=g_RG_GUI_PanelY;

   RG_GUI_SetPanelRuntimePosition(newX,newY);

   int actualDX=0;
   int actualDY=
      g_RG_GUI_PanelY-oldPanelY;

   if(PanelRightAlign)
      actualDX=oldPanelX-g_RG_GUI_PanelX;
   else
      actualDX=g_RG_GUI_PanelX-oldPanelX;

   if(actualDX!=0 || actualDY!=0)
   {
      // Move by the delta from the PREVIOUS mouse event, not from the
      // original drag point. This prevents cumulative over-movement.
      RG_GUI_MovePanelObjects(actualDX,actualDY);
      g_RG_GUI_PanelDragMoved=true;
      ChartRedraw();
   }

   return(true);
}

// A drag begins on the header, but the header is also the collapse button.
// If the user actually moved the panel, consume the following click so the
// panel does not collapse accidentally when the mouse is released.
bool RG_GUI_ConsumePanelToggleClick()
{
   if(!g_RG_GUI_PanelDragMoved)
      return(false);

   g_RG_GUI_PanelDragMoved=false;
   return(true);
}

//====================================================
// Risk button hold / acceleration support
//====================================================

bool RG_GUI_PointInsideObject(
   string name,
   int px,
   int py)
{
   if(ObjectFind(0,name)<0)
      return(false);

   int ox=
      (int)ObjectGetInteger(
         0,
         name,
         OBJPROP_XDISTANCE
      );

   int oy=
      (int)ObjectGetInteger(
         0,
         name,
         OBJPROP_YDISTANCE
      );

   int ow=
      (int)ObjectGetInteger(
         0,
         name,
         OBJPROP_XSIZE
      );

   int oh=
      (int)ObjectGetInteger(
         0,
         name,
         OBJPROP_YSIZE
      );

   return(
      px>=ox &&
      px<=ox+ow &&
      py>=oy &&
      py<=oy+oh
   );
}

void RG_GUI_HandleRiskMouseHold(
   int x,
   int y,
   string flags)
{
   static uint holdStart=0;
   static uint lastRepeat=0;
   static int  lastDirection=0;

   if(StringFind(
      flags,
      "1",
      0)<0)
   {
      holdStart=0;
      lastRepeat=0;
      lastDirection=0;
      return;
   }

   int direction=0;

   if(RG_GUI_PointInsideObject(
      RG_GUI_RISK_PLUS,
      x,
      y))
   {
      direction=1;
   }
   else
   if(RG_GUI_PointInsideObject(
      RG_GUI_RISK_MINUS,
      x,
      y))
   {
      direction=-1;
   }
   else
   {
      holdStart=0;
      lastRepeat=0;
      lastDirection=0;
      return;
   }

   uint now=
      GetTickCount();

   if(lastDirection!=direction ||
      holdStart==0)
   {
      holdStart=now;
      lastRepeat=now;
      lastDirection=direction;
      return;
   }

   uint held=
      now-holdStart;

   uint interval=260;

   if(held>3000)
      interval=70;
   else
   if(held>1800)
      interval=100;
   else
   if(held>900)
      interval=150;

   if(now-lastRepeat>=interval)
   {
      RG_GUI_AdjustRisk(direction);

      if(RG_RuntimePreviewActive())
         RG_GUI_UpdateRiskInfo();

      lastRepeat=now;
   }
}

void RG_GUI_ResetRiskMouseHold()
{
   // Internal state resets automatically
   // when the next mouse move has no left button.
}

#endif