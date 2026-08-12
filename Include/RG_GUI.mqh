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

#define RG_GUI_PANEL          RG_PREFIX+"PANEL"
#define RG_GUI_HEADER         RG_PREFIX+"HEADER"
#define RG_GUI_PANEL_TOGGLE   RG_PREFIX+"PANEL_TOGGLE"
#define RG_GUI_TITLE          RG_PREFIX+"TITLE"
#define RG_GUI_STATUS         RG_PREFIX+"STATUS"

#define RG_GUI_ENTRY_LABEL    RG_PREFIX+"ENTRY_LABEL"
#define RG_GUI_ENTRY_INPUT    RG_PREFIX+"ENTRY_INPUT"
#define RG_GUI_LOT_LABEL      RG_PREFIX+"LOT_LABEL"
#define RG_GUI_LOT_INPUT      RG_PREFIX+"LOT_INPUT"
#define RG_GUI_SL_LABEL       RG_PREFIX+"SL_LABEL"
#define RG_GUI_SL_INPUT       RG_PREFIX+"SL_INPUT"
#define RG_GUI_TP_LABEL       RG_PREFIX+"TP_LABEL"
#define RG_GUI_TP_INPUT       RG_PREFIX+"TP_INPUT"
#define RG_GUI_MODE_LABEL     RG_PREFIX+"MODE_LABEL"
#define RG_GUI_MODE           RG_PREFIX+"MODE"

#define RG_GUI_BUY            RG_PREFIX+"BUY"
#define RG_GUI_SELL           RG_PREFIX+"SELL"
#define RG_GUI_SET            RG_PREFIX+"SET"
#define RG_GUI_CANCEL         RG_PREFIX+"CANCEL"
#define RG_GUI_CLOSE          RG_PREFIX+"CLOSE_ALL"
#define RG_GUI_TRAILING       RG_PREFIX+"TRAILING"

#define RG_GUI_RISK_INFO      RG_PREFIX+"RISK_INFO"
#define RG_GUI_RISK_MINUS     RG_PREFIX+"RISK_MINUS"
#define RG_GUI_RISK_VALUE     RG_PREFIX+"RISK_VALUE"
#define RG_GUI_RISK_PLUS      RG_PREFIX+"RISK_PLUS"
#define RG_GUI_RISK_PERCENT   RG_PREFIX+"RISK_PERCENT"
#define RG_GUI_RISK_DOLLAR    RG_PREFIX+"RISK_DOLLAR"
#define RG_GUI_RISK_LOT       RG_PREFIX+"RISK_LOT"
#define RG_GUI_SECTION        RG_PREFIX+"OPEN_POSITIONS"
#define RG_GUI_SECTION_TOGGLE RG_PREFIX+"OPEN_POSITIONS_TOGGLE"
#define RG_GUI_SYMBOL         RG_PREFIX+"SYMBOL"
#define RG_GUI_SPREAD         RG_PREFIX+"SPREAD"
#define RG_GUI_PROFIT         RG_PREFIX+"PROFIT"

#define RG_GUI_FOOTER         RG_PREFIX+"FOOTER"
#define RG_GUI_FOOTER_TEXT    RG_PREFIX+"FOOTER_TEXT"
#define RG_GUI_MARKET_BG      RG_PREFIX+"MARKET_BG"
#define RG_GUI_MARKET_MAXLOT  RG_PREFIX+"MARKET_MAXLOT"
#define RG_GUI_MARKET_ACTIVE  RG_PREFIX+"MARKET_ACTIVE"
#define RG_GUI_MARKET_SERVER  RG_PREFIX+"MARKET_SERVER"

#define RG_GUI_POS_PREFIX     RG_PREFIX+"POS_"
#define RG_GUI_POS_ROW        "ROW_"
#define RG_GUI_POS_TEXT       "TEXT_"
#define RG_GUI_POS_BE         "BE_"
#define RG_GUI_POS_RF         "RF_"
#define RG_GUI_POS_THIRD      "THIRD_"
#define RG_GUI_POS_HALF       "HALF_"
#define RG_GUI_POS_CLOSE      "X_"

#define RG_GUI_BG             C'25,25,25'
#define RG_GUI_HEADER_BG      C'18,18,18'
#define RG_GUI_FOOTER_BG      C'18,18,18'
#define RG_GUI_ROW_BG         C'31,31,31'
#define RG_GUI_ROW_ALT_BG     C'36,36,36'

#define RG_GUI_BORDER         clrDimGray
#define RG_GUI_TEXT           clrWhite
#define RG_GUI_MUTED          clrSilver
#define RG_GUI_GREEN          clrLime
#define RG_GUI_RED            clrTomato
#define RG_GUI_BLUE           clrDodgerBlue
#define RG_GUI_ORANGE         clrOrange
#define RG_GUI_CYAN           clrAqua
#define RG_GUI_YELLOW         clrGold

#define RG_GUI_EDIT_BG        clrBlack
#define RG_GUI_EDIT_TEXT      clrWhite
#define RG_GUI_FONT           "Times New Roman"

#define RG_GUI_TITLE_SIZE     18
#define RG_GUI_TEXT_SIZE      13
#define RG_GUI_POSITION_TEXT_SIZE 10
#define RG_GUI_STATUS_SIZE    12
#define RG_GUI_STATUS_ROW_H    34
#define RG_GUI_BUTTON_SIZE    12

#define RG_GUI_PAD            16
#define RG_GUI_HEADER_H       56

#define RG_GUI_INPUT_W        270
#define RG_GUI_INPUT_H        42

#define RG_GUI_BUTTON_W       170
#define RG_GUI_BUTTON_H       44
#define RG_GUI_SMALL_BUTTON_W 150
#define RG_GUI_SMALL_BUTTON_H 44

// Unified layout metrics.  The panel is deliberately built from these
// measurements so controls cannot overlap when the position section
// expands or collapses.
#define RG_GUI_ROW_H              58
#define RG_GUI_SECTION_H          42
#define RG_GUI_FOOTER_H           42
#define RG_GUI_MARKET_H           124

// Risk + BUY/SELL/SET are now arranged sequentially.
// Risk remains ONE single row.
#define RG_GUI_RISK_H             52
// Unified layout metrics.
// Risk row comes first, then BUY / SELL / SET.
#define RG_GUI_ROW_H          58
#define RG_GUI_SECTION_H      42
#define RG_GUI_FOOTER_H       42
#define RG_GUI_MARKET_H       124

#define RG_GUI_RISK_H         74
#define RG_GUI_RISK_Y         0
#define RG_GUI_POSITION_TOP   0
#define RG_GUI_ROWS_START     0
#define RG_GUI_PRIMARY_Y      0
#define RG_GUI_FIELDS_Y      0
#define RG_GUI_FIELD_STEP     52
#define RG_GUI_MODE_Y         0

#define RG_GUI_Z_PANEL        50000
#define RG_GUI_Z_HEADER       50010
#define RG_GUI_Z_TEXT         50020
#define RG_GUI_Z_BUTTON       50030
int g_RG_GUI_LastChartWidth=0;
bool g_RG_GUI_PositionsExpanded=true;
bool g_RG_GUI_PanelExpanded=true;

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

bool RG_GUI_IsPositionObject(string name,string kind)
{
   return(StringFind(name,RG_GUI_POS_PREFIX+kind,0)==0);
}

int RG_GUI_TicketFromPositionObject(string name,string kind)
{
   string prefix=RG_GUI_POS_PREFIX+kind;

   if(StringFind(name,prefix,0)!=0)
      return(-1);

   return((int)StringToInteger(
      StringSubstr(name,StringLen(prefix))
   ));
}

//====================================================
// Layout engine
// All Trade-panel positions are calculated from one
// sequential block model.
//====================================================
struct RGGuiLayout
{
   int statusY;
   int primaryY;
   int fieldsY;
   int fieldStep;
   int modeY;
   int riskY;
   int positionY;
   int rowsY;
   int rowsHeight;
   int marketY;
   int footerY;
   int panelH;
   int actionGap;
   int actionX;
   int actionW;
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
RGGuiLayout &L
)
{
   if(rowCount<1)
      rowCount=1;

   if(rowCount>8)
      rowCount=8;

   L.contentW=w-(2*RG_GUI_PAD);

   if(L.contentW<100)
      L.contentW=100;

   //================================================
   // Header / status
   //================================================

 L.statusY=
   y+
   RG_GUI_HEADER_H+
   3;

//====================================================
// RISK ROW
//
// Risk + - + value + % $ Lot
//====================================================

L.riskY=
   L.statusY+
   RG_GUI_STATUS_ROW_H+
   6;

//====================================================
// BUY / SELL / SET
//====================================================

L.primaryY=
   L.riskY+
   RG_GUI_RISK_H+
   8;

//====================================================
// Utility actions
//====================================================

L.fieldsY=
   L.primaryY+
   RG_GUI_BUTTON_H+
   10;

L.modeY=L.fieldsY;

L.actionGap=10;
L.actionX=x+RG_GUI_PAD;
L.actionW=
   (L.contentW-(2*L.actionGap))/3;

L.labelX=x+RG_GUI_PAD;
L.inputX=x+RG_GUI_PAD;
L.rightX=x+RG_GUI_PAD;

L.positionY=
   L.fieldsY+
   RG_GUI_BUTTON_H+
   10;

   L.rowsY=
      L.positionY+
      RG_GUI_SECTION_H+
      8;

   L.rowsHeight=
      positionsExpanded ?
      rowCount*RG_GUI_ROW_H :
      0;

   //================================================
   // Market information
   //================================================

   L.marketY=
      L.rowsY+
      L.rowsHeight+
      10;

   //================================================
   // Footer
   //================================================

   L.footerY=
      L.marketY+
      RG_GUI_MARKET_H+
      10;

   L.panelH=
      (L.footerY-y)+
      RG_GUI_FOOTER_H;
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

   ObjectSetInteger(0,name,OBJPROP_READONLY,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,60000);
}

void RG_GUI_DeletePositionObjects()
{
   for(int i=ObjectsTotal()-1;i>=0;i--)
   {
      string name=ObjectName(i);

      if(StringFind(name,RG_GUI_POS_PREFIX,0)==0)
         ObjectDelete(0,name);
   }
}

void RG_DeletePanel()
{
   RG_GUI_DeletePositionObjects();

   for(int i=ObjectsTotal()-1;i>=0;i--)
   {
      string stale=ObjectName(i);

      if(StringFind(stale,RG_PREFIX,0)==0)
         ObjectDelete(0,stale);
   }

   g_RG_GUI_LastChartWidth=0;
   ChartRedraw();
}

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
      0,name,OBJ_RECTANGLE_LABEL,0,0,0))
      return(false);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,background);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,border);
   ObjectSetInteger(0,name,OBJPROP_FILL,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,zorder);

   return(true);
}

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

   if(!ObjectCreate(0,name,OBJ_BUTTON,0,0,0))
      return(false);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,RG_GUI_FONT);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,RG_GUI_BUTTON_SIZE);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,background);
   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,RG_GUI_BORDER);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,zorder);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,"");

   return(true);
}

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

   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
      return(false);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,RG_GUI_FONT);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,zorder);

   return(true);
}

void RG_GUI_SetText(string name,string text,color textColor)
{
   if(ObjectFind(0,name)<0)
      return;

   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
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
//
// When PanelRightAlign=true the chart reserves a right
// shift area and the panel is placed inside it.
// This prevents the opaque panel from covering the latest
// candles on normal desktop chart widths.
//====================================================

int RG_GUI_GetPanelWidth()
{
   int w=PanelWidth;

   if(w<640)
      w=640;

   if(w>760)
      w=760;

   return(w);
}

int RG_GUI_GetPanelX(int width)
{
   int chartWidth=
      (int)ChartGetInteger(
         0,
         CHART_WIDTH_IN_PIXELS,
         0);

   if(PanelRightAlign)
   {
      int x=
         chartWidth-width-PanelX;

      if(x<5)
         x=5;

      return(x);
   }

   return(PanelX);
}

void RG_GUI_ReserveChartSpace(int width)
{
   if(!PanelRightAlign)
      return;

   int chartWidth=
      (int)ChartGetInteger(
         0,
         CHART_WIDTH_IN_PIXELS,
         0);

   if(chartWidth<=0)
      return;

   double percent=
      100.0*(width+PanelX+5)/
      chartWidth;

   if(percent<10.0)
      percent=10.0;

   // MT4 chart shift is capped conservatively.
   if(percent>50.0)
      percent=50.0;

   ChartSetInteger(0,CHART_SHIFT,true);
   ChartSetDouble(0,CHART_SHIFT_SIZE,percent);
}

//====================================================
// Managed/account-wide active positions
//====================================================

bool RG_GUI_IsManagedOrder()
{
   return(
      OrderSymbol()==Symbol() &&
      OrderMagicNumber()==MagicNumber &&
      (OrderType()==OP_BUY || OrderType()==OP_SELL)
   );
}

int RG_GUI_ActivePositionCount()
{
   int count=0;

   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;

      if(OrderType()!=OP_BUY &&
         OrderType()!=OP_SELL)
         continue;

      if(RG_IsRiskFreeDone(OrderTicket()))
         continue;

      count++;
   }

   return(count);
}

//====================================================
// Position rows
//====================================================

void RG_GUI_DrawPositionRow(
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

   color rowColor=
      (rowIndex%2==0 ? RG_GUI_ROW_BG : RG_GUI_ROW_ALT_BG);

   RG_GUI_CreateRect(
      RG_GUI_PosRow(ticket),
      x,y,width,RG_GUI_ROW_H,
      rowColor,RG_GUI_BORDER,
      RG_GUI_Z_PANEL+1
   );

   string side=
      (OrderType()==OP_BUY ? "BUY" : "SELL");

   string symbol=OrderSymbol();

   double profit=
      OrderProfit()+
      OrderSwap()+
      OrderCommission();

   color pColor=
      (profit>=0 ? RG_GUI_GREEN : RG_GUI_RED);

   string state=
      (RG_IsRiskFreeDone(ticket) ? " RF" : "");

   string line1=
      symbol+
      "  "+
      side+
      "  "+
      DoubleToString(OrderLots(),2)+
      "  "+
      (profit>=0?"+$":"-$")+
      DoubleToString(MathAbs(profit),2)+
      state;

   RG_GUI_CreateText(
      RG_GUI_PosText(ticket),
      line1,
      x+7,y+5,
      pColor,RG_GUI_POSITION_TEXT_SIZE,
      RG_GUI_Z_TEXT
   );

   // Fast position actions: one click for BE / RF / 1/3 / 1/2 / X.
   int buttonW=52;
   int buttonH=32;
   int gap=5;
   int total=(buttonW*5)+(gap*4);
   int bx=x+width-total-10;
   int by=y+13;

   RG_GUI_CreateButton(
      RG_GUI_PosBE(ticket),
      "BE",
      bx,by,buttonW,buttonH,
      RG_GUI_BLUE,clrWhite,
      RG_GUI_Z_BUTTON
   );

   RG_GUI_CreateButton(
      RG_GUI_PosRF(ticket),
      "RF",
      bx+((buttonW+gap)*1),by,buttonW,buttonH,
      RG_GUI_CYAN,clrBlack,
      RG_GUI_Z_BUTTON
   );

   RG_GUI_CreateButton(
      RG_GUI_PosThird(ticket),
      "1/3",
      bx+((buttonW+gap)*2),by,buttonW,buttonH,
      RG_GUI_YELLOW,clrBlack,
      RG_GUI_Z_BUTTON
   );

   RG_GUI_CreateButton(
      RG_GUI_PosHalf(ticket),
      "1/2",
      bx+((buttonW+gap)*3),by,buttonW,buttonH,
      RG_GUI_ORANGE,clrBlack,
      RG_GUI_Z_BUTTON
   );

   RG_GUI_CreateButton(
      RG_GUI_PosClose(ticket),
      "X",
      bx+((buttonW+gap)*4),by,buttonW,buttonH,
      RG_GUI_RED,clrWhite,
      RG_GUI_Z_BUTTON
   );
}

void RG_GUI_UpdatePositionRows(
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

//====================================================
// Price / Pip helpers
//====================================================

double RG_GUI_PipSize()
{
   double point=
      MarketInfo(Symbol(),MODE_POINT);

   int digits=
      (int)MarketInfo(Symbol(),MODE_DIGITS);

   if(point<=0)
      return(0);

   if(digits==3 || digits==5)
      return(point*10.0);

   return(point);
}

double RG_GUI_PointsToPips(int points)
{
   double pip=RG_GUI_PipSize();
   double point=MarketInfo(Symbol(),MODE_POINT);

   if(pip<=0 || point<=0)
      return(0);

   return(points*point/pip);
}

double RG_GUI_PipsToPrice(double pips)
{
   double pip=RG_GUI_PipSize();

   if(pip<=0)
      return(0);

   return(pips*pip);
}

//====================================================
// Preview field display
//
// PRICE mode:
// Entry = price
// SL / TP = absolute prices
//
// PIPS mode:
// Entry = price
// SL / TP = distances in pips
//====================================================

void RG_GUI_SetPreviewPriceFields(int direction)
{
   if(direction!=OP_BUY && direction!=OP_SELL)
      return;

   RefreshRates();

   int digits=
      (int)MarketInfo(Symbol(),MODE_DIGITS);

   double entry=
      (direction==OP_BUY ? Ask : Bid);

   int slPts=RG_RuntimeStopLoss();
   int tpPts=RG_RuntimeTakeProfit();

   double sl=0.0;
   double tp=0.0;

   if(slPts>0)
   {
      sl=
         (direction==OP_BUY ?
          entry-slPts*Point :
          entry+slPts*Point);
   }

   if(tpPts>0)
   {
      tp=
         (direction==OP_BUY ?
          entry+tpPts*Point :
          entry-tpPts*Point);
   }

   entry=NormalizeDouble(entry,digits);
   sl=NormalizeDouble(sl,digits);
   tp=NormalizeDouble(tp,digits);

   RG_RuntimeSetPreviewPrices(entry,sl,tp);

   RG_SetEditText(
      RG_GUI_ENTRY_INPUT,
      DoubleToString(entry,digits)
   );

   if(RG_RuntimePreviewUsePips())
   {
      RG_SetEditText(
         RG_GUI_SL_INPUT,
         slPts>0 ?
         DoubleToString(RG_GUI_PointsToPips(slPts),2) :
         ""
      );

      RG_SetEditText(
         RG_GUI_TP_INPUT,
         tpPts>0 ?
         DoubleToString(RG_GUI_PointsToPips(tpPts),2) :
         ""
      );
   }
   else
   {
      RG_SetEditText(
         RG_GUI_SL_INPUT,
         sl>0 ?
         DoubleToString(sl,digits) :
         ""
      );

      RG_SetEditText(
         RG_GUI_TP_INPUT,
         tp>0 ?
         DoubleToString(tp,digits) :
         ""
      );
   }

   if(ObjectFind(0,RG_GUI_MODE)>=0)
   {
      ObjectSetString(
         0,
         RG_GUI_MODE,
         OBJPROP_TEXT,
         RG_RuntimePreviewUsePips() ?
         "PIPS" : "PRICE"
      );
   }
}

//====================================================
// Parse current preview fields into actual prices
//====================================================

bool RG_GUI_ParsePreviewFields(
   int direction,
   double &lot,
   double &entry,
   double &sl,
   double &tp)
{
   lot=
      StrToDouble(
         RG_GetEditText(RG_GUI_LOT_INPUT)
      );

   entry=
      StrToDouble(
         RG_GetEditText(RG_GUI_ENTRY_INPUT)
      );

   sl=0.0;
   tp=0.0;

   if(lot<=0)
      return(false);

   if(entry<=0)
      return(false);

   if(direction!=OP_BUY &&
      direction!=OP_SELL)
      return(false);

   if(RG_RuntimePreviewUsePips())
   {
      double slPips=
         StrToDouble(
            RG_GetEditText(RG_GUI_SL_INPUT)
         );

      double tpPips=
         StrToDouble(
            RG_GetEditText(RG_GUI_TP_INPUT)
         );

      if(UseStopLoss)
      {
         if(slPips<=0)
            return(false);

         double slDistance=
            RG_GUI_PipsToPrice(slPips);

         if(slDistance<=0)
            return(false);

         sl=
            (direction==OP_BUY ?
             entry-slDistance :
             entry+slDistance);
      }

      if(UseTakeProfit)
      {
         if(tpPips<=0)
            return(false);

         double tpDistance=
            RG_GUI_PipsToPrice(tpPips);

         if(tpDistance<=0)
            return(false);

         tp=
            (direction==OP_BUY ?
             entry+tpDistance :
             entry-tpDistance);
      }
   }
   else
   {
      if(UseStopLoss)
      {
         sl=
            StrToDouble(
               RG_GetEditText(RG_GUI_SL_INPUT)
            );

         if(sl<=0)
            return(false);
      }

      if(UseTakeProfit)
      {
         tp=
            StrToDouble(
               RG_GetEditText(RG_GUI_TP_INPUT)
            );

         if(tp<=0)
            return(false);
      }
   }

   int digits=
      (int)MarketInfo(Symbol(),MODE_DIGITS);

   entry=NormalizeDouble(entry,digits);

   if(sl>0)
      sl=NormalizeDouble(sl,digits);

   if(tp>0)
      tp=NormalizeDouble(tp,digits);

   if(UseStopLoss)
   {
      if(direction==OP_BUY && sl>=entry)
         return(false);

      if(direction==OP_SELL && sl<=entry)
         return(false);
   }

   if(UseTakeProfit)
   {
      if(direction==OP_BUY && tp<=entry)
         return(false);

      if(direction==OP_SELL && tp>=entry)
         return(false);
   }

   return(true);
}

//====================================================
// Sync runtime preview from GUI
//====================================================

bool RG_GUI_SyncPreviewFromFields()
{
   int direction=
      RG_RuntimePreviewDirection();

   if(!RG_RuntimePreviewActive())
      return(false);

   double lot,entry,sl,tp;

   if(!RG_GUI_ParsePreviewFields(
      direction,lot,entry,sl,tp))
      return(false);

   if(MaxLot>0 && lot>MaxLot)
      return(false);

   RG_RuntimeSetPreviewPrices(entry,sl,tp);

   return(true);
}

//====================================================
// Toggle PRICE / PIPS mode
//====================================================

void RG_GUI_ToggleProtectionMode()
{
   bool usePips=
      !RG_RuntimePreviewUsePips();

   RG_RuntimeSetPreviewUsePips(usePips);

   if(RG_RuntimePreviewActive())
   {
      int direction=
         RG_RuntimePreviewDirection();

      double entry=
         RG_RuntimePreviewEntry();

      double sl=
         RG_RuntimePreviewSL();

      double tp=
         RG_RuntimePreviewTP();

      int digits=
         (int)MarketInfo(Symbol(),MODE_DIGITS);

      RG_SetEditText(
         RG_GUI_ENTRY_INPUT,
         entry>0 ?
         DoubleToString(entry,digits) :
         ""
      );

      if(usePips)
      {
         double pip=RG_GUI_PipSize();

         double slPips=
            (pip>0 && sl>0) ?
            MathAbs(entry-sl)/pip : 0;

         double tpPips=
            (pip>0 && tp>0) ?
            MathAbs(tp-entry)/pip : 0;

         RG_SetEditText(
            RG_GUI_SL_INPUT,
            slPips>0 ?
            DoubleToString(slPips,2) : ""
         );

         RG_SetEditText(
            RG_GUI_TP_INPUT,
            tpPips>0 ?
            DoubleToString(tpPips,2) : ""
         );
      }
      else
      {
         RG_SetEditText(
            RG_GUI_SL_INPUT,
            sl>0 ?
            DoubleToString(sl,digits) : ""
         );

         RG_SetEditText(
            RG_GUI_TP_INPUT,
            tp>0 ?
            DoubleToString(tp,digits) : ""
         );
      }
   }

   if(ObjectFind(0,RG_GUI_MODE)>=0)
   {
      ObjectSetString(
         0,
         RG_GUI_MODE,
         OBJPROP_TEXT,
         usePips ? "PIPS" : "PRICE"
      );
   }

   RG_GUI_UpdateRiskInfo();
   ChartRedraw();
}

//====================================================
// Calculate Preview Lot from Risk mode
//
// %   = Account Balance * Risk %
// $   = Fixed Dollar Risk
// Lot = Configured Fixed Lot
//
// IMPORTANT:
// This function NEVER changes Fixed Lot.
//====================================================

double RG_GUI_CalculateRiskLot(
   int direction,
   double entry,
   double sl
)
{
   if(direction!=OP_BUY &&
      direction!=OP_SELL)
      return(0);

   if(entry<=0 ||
      sl<=0)
      return(0);

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

      // Runtime risk value mirrors the configured Fixed Lot when
      // LOT mode is selected. Use it if the runtime fixed-lot
      // cache has not been initialized yet.
      if(fixedLot<=0)
         fixedLot=RG_RuntimeRiskValue();

      if(fixedLot<=0)
         fixedLot=
            MarketInfo(
               Symbol(),
               MODE_MINLOT
            );

      double lotStep=
         MarketInfo(
            Symbol(),
            MODE_LOTSTEP
         );

      if(lotStep<=0)
         lotStep=0.01;

      fixedLot=
         MathFloor(
            fixedLot/lotStep
         )*lotStep;

      return(
         NormalizeDouble(
            fixedLot,
            2
         )
      );
   }

   //================================================
   // Calculate allowed money risk
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
   // Broker tick economics
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
      return(0);

   // Loss for 1 lot at selected SL
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
      brokerMaxLot=MaxLot;

   if(lot>brokerMaxLot)
      lot=brokerMaxLot;

   // Round DOWN so risk does not exceed selected risk
   lot=
      MathFloor(
         lot/lotStep
      )*lotStep;

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
      MarketInfo(Symbol(),MODE_POINT);

   double tickSize=
      MarketInfo(Symbol(),MODE_TICKSIZE);

   double tickValue=
      MarketInfo(Symbol(),MODE_TICKVALUE);

   if(point<=0 ||
      tickSize<=0 ||
      tickValue<=0 ||
      lot<=0)
      return(0);

   return(
      lot*
      tickValue*
      (point/tickSize)
   );
}

void RG_GUI_UpdateRiskInfo()
{
   if(ObjectFind(0,RG_GUI_RISK_INFO)<0)
      return;

   if(!RG_RuntimePreviewActive())
   {
      RG_GUI_SetText(
         RG_GUI_RISK_INFO,
         "",
         RG_GUI_TEXT
      );
      return;
   }
   
double lot=
   RG_GUI_CalculateRiskLot(
      RG_RuntimePreviewDirection(),
      RG_RuntimePreviewEntry(),
      RG_RuntimePreviewSL()
   );

if(lot>0)
{
   RG_SetEditText(
      RG_GUI_LOT_INPUT,
      DoubleToString(lot,2)
   );
}

double entry=
   RG_RuntimePreviewEntry();

double sl=
   RG_RuntimePreviewSL();

double tp=
   RG_RuntimePreviewTP();

   if(lot<=0 || entry<=0)
   {
      RG_GUI_SetText(
         RG_GUI_RISK_INFO,
         "",
         RG_GUI_TEXT
      );
      return;
   }

   double dpp=
      RG_GUI_DollarPerPoint(lot);

   if(dpp<=0)
   {
      RG_GUI_SetText(
         RG_GUI_RISK_INFO,
         "Lot "+DoubleToString(lot,2)+"   Risk $ 0.00   Reward $ 0.00   R:R —",
         RG_GUI_YELLOW
      );
      return;
   }

   double risk=0.0;
   double reward=0.0;

   if(UseStopLoss && sl>0)
      risk=
         MathAbs(entry-sl)/Point*dpp;

   if(UseTakeProfit && tp>0)
      reward=
         MathAbs(tp-entry)/Point*dpp;

   string rrText="—";
   if(risk>0 && reward>0)
   {
      double rr=reward/risk;
      rrText="1:"+DoubleToString(rr,2);
   }

   string text=
      "Lot "+DoubleToString(lot,2)+
      "   Risk $ "+DoubleToString(risk,2)+
      "   Reward $ "+DoubleToString(reward,2)+
      "   R:R "+rrText;

   RG_GUI_SetText(
      RG_GUI_RISK_INFO,
      text,
      RG_GUI_YELLOW
   );
}

//====================================================
// Calculate Preview Lot from selected Risk mode
//
// PERCENT = AccountBalance * Risk%
// DOLLAR  = fixed dollar risk
// LOT     = configured Fixed Lot
//
// IMPORTANT:
// This function NEVER changes Fixed Lot.
//====================================================


//====================================================
// SET validation / apply
//====================================================

bool RG_GUI_ApplySettings()
{
   if(!RG_RuntimePreviewActive())
      return(false);

   int direction=RG_RuntimePreviewDirection();
   double entry=RG_RuntimePreviewEntry();
   double sl=RG_RuntimePreviewSL();
   double tp=RG_RuntimePreviewTP();

   if(direction!=OP_BUY && direction!=OP_SELL) return(false);
   if(entry<=0) return(false);

   if(UseStopLoss)
   {
      if(sl<=0) return(false);
      if(direction==OP_BUY && sl>=entry) return(false);
      if(direction==OP_SELL && sl<=entry) return(false);
   }

   if(UseTakeProfit)
   {
      if(tp<=0) return(false);
      if(direction==OP_BUY && tp<=entry) return(false);
      if(direction==OP_SELL && tp>=entry) return(false);
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
   lot=MaxLot;

// IMPORTANT:
// Do NOT overwrite configured Fixed Lot.
// The calculated lot is only the volume
// used for this trade.
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
   if(ObjectFind(0,RG_GUI_RISK_VALUE)<0)
      return;

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

   // IMPORTANT:
   // Do NOT display %, $ or Lot after the number.
   // The mode buttons already show the unit.
   RG_GUI_SetText(
      RG_GUI_RISK_VALUE,
      DoubleToString(value,digits),
      RG_GUI_TEXT
   );

   if(ObjectFind(0,RG_GUI_RISK_PERCENT)>=0)
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

   if(ObjectFind(0,RG_GUI_RISK_DOLLAR)>=0)
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

   if(ObjectFind(0,RG_GUI_RISK_LOT)>=0)
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
//
// IMPORTANT:
// Fixed Lot is NOT editable from the Risk panel.
// % and $ can be changed with +/-.
//====================================================

void RG_GUI_AdjustRisk(int direction)
{
   ENUM_RG_RISK_MODE mode=
      RG_RuntimeRiskMode();

   // Fixed Lot is deliberately NOT editable
   // through the Risk panel.
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

   value += direction*step;

   if(value<minimum)
      value=minimum;

   int digits=
      (mode==RG_RISK_PERCENT ? 1 : 2);

   value=
      NormalizeDouble(value,digits);

   // Safety limit for percentage risk.
   if(mode==RG_RISK_PERCENT)
   {
      if(value>100.0)
         value=100.0;
   }

   RG_RuntimeSetRiskValue(value);

   RG_GUI_UpdateRiskControls();
}

//====================================================
// Set Risk Mode
//====================================================

void RG_GUI_SetRiskMode(
   ENUM_RG_RISK_MODE mode
)
{
   RG_RuntimeSetRiskMode(mode);

   double value=
      RG_RuntimeRiskValue();

   if(mode==RG_RISK_PERCENT)
   {
      if(value<=0 || value>100)
         value=1.0;
   }
   else
   if(mode==RG_RISK_DOLLAR)
   {
      if(value<=0)
         value=1.0;
   }
   else
   {
      // FIXED LOT:
      // read the existing fixed lot.
      // Do NOT change it from the panel.
      value=
         RG_RuntimeFixedLot();

      if(value<=0)
         value=
            MarketInfo(
               Symbol(),
               MODE_MINLOT
            );
   }

   RG_RuntimeSetRiskValue(value);

   // IMPORTANT:
   // Do NOT call RG_RuntimeSetFixedLot() here.
   // Fixed Lot remains controlled by the input/settings.
   RG_GUI_UpdateRiskControls();
}
//====================================================
// Create initial Preview from current market + ATR
//====================================================

bool RG_GUI_CreateRiskPreview(int direction)
{
   if(direction!=OP_BUY && direction!=OP_SELL) return(false);

   RefreshRates();
   double entry=(direction==OP_BUY ? Ask : Bid);
   if(entry<=0) return(false);

   double atr=iATR(Symbol(),Period(),ATRPeriod,0);
   if(atr<=0) return(false);

   double distance=atr*ATRMultiplier;
   if(distance<=0) return(false);

   int digits=(int)MarketInfo(Symbol(),MODE_DIGITS);
   entry=NormalizeDouble(entry,digits);

   double sl=(direction==OP_BUY ? entry-distance : entry+distance);
   double tp=(direction==OP_BUY ? entry+distance*InitialRR : entry-distance*InitialRR);

   sl=NormalizeDouble(sl,digits);
   tp=NormalizeDouble(tp,digits);

   RG_RuntimeSetPreviewDirection(direction);
   RG_RuntimeSetPreviewUsePips(false);
   RG_RuntimeSetPreviewPrices(entry,sl,tp);

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
   lot=MaxLot;

//================================================
// IMPORTANT:
//
// Preview lot is DISPLAYED in the Lot field.
//
// We DO NOT call:
// RG_RuntimeSetFixedLot(lot)
//
// because that would overwrite the configured
// Fixed Lot value from Inputs.
//================================================

RG_SetEditText(
   RG_GUI_LOT_INPUT,
   DoubleToString(lot,2)
);

RG_GUI_UpdateRiskControls();
RG_GUI_UpdateRiskInfo();

return(true);
}

//====================================================
// Position section layout / collapse
//====================================================

int RG_GUI_GetPositionCount()
{
   int count=0;

   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;

      if(!RG_GUI_IsManagedOrder())
         continue;

      count++;
   }

   return(count);
}

void RG_GUI_SetPanelHeight(int height)
{
   if(ObjectFind(0,RG_GUI_PANEL)>=0)
      ObjectSetInteger(0,RG_GUI_PANEL,OBJPROP_YSIZE,height);
}

void RG_GUI_UpdatePositionSectionLayout()
{
   if(!g_RG_GUI_PanelExpanded)
      return;

   int w=RG_GUI_GetPanelWidth();
   int x=RG_GUI_GetPanelX(w);
   int y=PanelY;
   if(y<5) y=5;

   int rows=MaxOpenPositions;
   if(rows<1) rows=1;
   if(rows>8) rows=8;

   int count=RG_GUI_GetPositionCount();

   RGGuiLayout L;
   RG_GUI_CalculateLayout(
      x,y,w,rows,
      g_RG_GUI_PositionsExpanded,
      L
   );

   int sectionY=L.positionY;
   int rowsY=L.rowsY;
   int marketY=L.marketY;
   int footerY=L.footerY;
   int panelH=L.panelH;

   RG_GUI_SetPanelHeight(panelH);

   if(ObjectFind(0,RG_GUI_SECTION_TOGGLE)>=0)
   {
      string caption=
         "OPEN POSITIONS ("+IntegerToString(count)+")  "+
         (g_RG_GUI_PositionsExpanded ? "[ - ]" : "[ + ]");

      ObjectSetString(0,RG_GUI_SECTION_TOGGLE,OBJPROP_TEXT,caption);
      ObjectSetInteger(0,RG_GUI_SECTION_TOGGLE,OBJPROP_XDISTANCE,x+RG_GUI_PAD);
      ObjectSetInteger(0,RG_GUI_SECTION_TOGGLE,OBJPROP_YDISTANCE,sectionY);
      ObjectSetInteger(0,RG_GUI_SECTION_TOGGLE,OBJPROP_XSIZE,w-(2*RG_GUI_PAD));
      ObjectSetInteger(0,RG_GUI_SECTION_TOGGLE,OBJPROP_YSIZE,RG_GUI_SECTION_H);
   }

   RG_GUI_DeletePositionObjects();

   if(g_RG_GUI_PositionsExpanded)
   {
      RG_GUI_UpdatePositionRows(
         x+RG_GUI_PAD,
         rowsY,
         w-(2*RG_GUI_PAD),
         rows
      );
   }

   if(ObjectFind(0,RG_GUI_SYMBOL)>=0)
      ObjectSetInteger(0,RG_GUI_SYMBOL,OBJPROP_YDISTANCE,marketY+16);
   if(ObjectFind(0,RG_GUI_SPREAD)>=0)
      ObjectSetInteger(0,RG_GUI_SPREAD,OBJPROP_YDISTANCE,marketY+52);
   if(ObjectFind(0,RG_GUI_PROFIT)>=0)
      ObjectSetInteger(0,RG_GUI_PROFIT,OBJPROP_YDISTANCE,marketY+88);

   if(ObjectFind(0,RG_GUI_MARKET_MAXLOT)>=0)
      ObjectSetInteger(0,RG_GUI_MARKET_MAXLOT,OBJPROP_YDISTANCE,marketY+16);

   if(ObjectFind(0,RG_GUI_MARKET_ACTIVE)>=0)
      ObjectSetInteger(0,RG_GUI_MARKET_ACTIVE,OBJPROP_YDISTANCE,marketY+52);

   if(ObjectFind(0,RG_GUI_MARKET_SERVER)>=0)
      ObjectSetInteger(0,RG_GUI_MARKET_SERVER,OBJPROP_YDISTANCE,marketY+88);

   if(ObjectFind(0,RG_GUI_MARKET_BG)>=0)
   {
      ObjectSetInteger(0,RG_GUI_MARKET_BG,OBJPROP_XDISTANCE,x+RG_GUI_PAD);
      ObjectSetInteger(0,RG_GUI_MARKET_BG,OBJPROP_YDISTANCE,marketY);
      ObjectSetInteger(0,RG_GUI_MARKET_BG,OBJPROP_XSIZE,w-(2*RG_GUI_PAD));
      ObjectSetInteger(0,RG_GUI_MARKET_BG,OBJPROP_YSIZE,RG_GUI_MARKET_H);
   }

   if(ObjectFind(0,RG_GUI_FOOTER)>=0)
      ObjectSetInteger(0,RG_GUI_FOOTER,OBJPROP_YDISTANCE,footerY);
   if(ObjectFind(0,RG_GUI_FOOTER_TEXT)>=0)
      ObjectSetInteger(0,RG_GUI_FOOTER_TEXT,OBJPROP_YDISTANCE,footerY+9);

   ChartRedraw();
}

void RG_GUI_TogglePanel()
{
   g_RG_GUI_PanelExpanded=!g_RG_GUI_PanelExpanded;
   RG_CreatePanel();
}

void RG_GUI_TogglePositions()
{
   g_RG_GUI_PositionsExpanded=!g_RG_GUI_PositionsExpanded;
   RG_GUI_UpdatePositionSectionLayout();
   RG_UpdateFooter();
}

//====================================================
// Create Panel
//====================================================

bool RG_CreatePanel()
{
   RG_DeletePanel();

   int w=RG_GUI_GetPanelWidth();
   int x=RG_GUI_GetPanelX(w);
   int y=PanelY;
   if(y<5) y=5;

   // The panel is intentionally left-aligned. No chart-shift reservation
   // is used in the current visual architecture.
   RG_GUI_ReserveChartSpace(0);

   // Collapsed state: show only the title bar. The title bar itself is
   // clickable and restores the complete Trade panel.
   if(!g_RG_GUI_PanelExpanded)
   {
      if(!RG_GUI_CreateRect(
         RG_GUI_PANEL,x,y,w,RG_GUI_HEADER_H,
         RG_GUI_BG,RG_GUI_BORDER,
         RG_GUI_Z_PANEL))
         return(false);

      RG_GUI_CreateRect(
         RG_GUI_HEADER,x,y,w,RG_GUI_HEADER_H,
         RG_GUI_HEADER_BG,RG_GUI_BORDER,
         RG_GUI_Z_HEADER
      );

      RG_GUI_CreateButton(
         RG_GUI_PANEL_TOGGLE,
         "RiskGuard MT4   | Server: "+TimeToString(TimeCurrent(),TIME_SECONDS)+"   [ + ]",
         x+2,y+2,w-4,RG_GUI_HEADER_H-4,
         RG_GUI_HEADER_BG,RG_GUI_TEXT,
         RG_GUI_Z_BUTTON
      );

      g_RG_GUI_LastChartWidth=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
      ChartRedraw();
      return(true);
   }

   int rows=MaxOpenPositions;
   if(rows<1) rows=1;
   if(rows>8) rows=8;

   int count=RG_GUI_GetPositionCount();

   RGGuiLayout L;
   RG_GUI_CalculateLayout(
      x,y,w,rows,
      g_RG_GUI_PositionsExpanded,
      L
   );

   int sectionY=L.positionY;
   int rowsY=L.rowsY;
   int marketY=L.marketY;
   int footerY=L.footerY;
   int h=L.panelH;

   if(!RG_GUI_CreateRect(
      RG_GUI_PANEL,x,y,w,h,
      RG_GUI_BG,RG_GUI_BORDER,
      RG_GUI_Z_PANEL))
      return(false);

   RG_GUI_CreateRect(
      RG_GUI_HEADER,x,y,w,RG_GUI_HEADER_H,
      RG_GUI_HEADER_BG,RG_GUI_BORDER,
      RG_GUI_Z_HEADER
   );

   RG_GUI_CreateButton(
      RG_GUI_PANEL_TOGGLE,
      "RiskGuard MT4   [ - ]",
      x+2,y+2,w-4,RG_GUI_HEADER_H-4,
      RG_GUI_HEADER_BG,RG_GUI_TEXT,
      RG_GUI_Z_BUTTON
   );

   // Status is deliberately below the title bar so it can never overlap it.
   RG_GUI_CreateText(
      RG_GUI_STATUS,
      "Status : BUY/SELL = Preview | SET = Send",
      x+RG_GUI_PAD,L.statusY,
      RG_GUI_YELLOW,RG_GUI_STATUS_SIZE,
      RG_GUI_Z_TEXT
   );
//====================================================
// RISK ROW
//
// IMPORTANT:
// Risk text is kept visible.
// Everything is intentionally placed on ONE line.
//
// Layout:
//
// Risk   [ - ] [ value ] [ + ] [ % ] [ $ ] [ Lot ]
//
// Fixed Lot philosophy:
// When LOT mode is selected, the displayed lot value
// comes from Fixed Lot settings and +/- are disabled.
//====================================================

int riskY=L.riskY;
int riskX=x+RG_GUI_PAD;

int riskGap=12;

// Dedicated space for the Risk label so it can never touch the - button.
int riskLabelW=76;
int riskMinusW=46;
int riskValueW=68;
int riskPlusW=46;
int riskModeW=56;

int riskRowH=RG_GUI_RISK_H;

//--------------------------------------------
// Risk label
//--------------------------------------------

RG_GUI_CreateText(
   RG_PREFIX+"RISK_LABEL",
   "Risk",
   riskX,
   riskY+13,
   RG_GUI_TEXT,
   RG_GUI_TEXT_SIZE,
   RG_GUI_Z_TEXT
);

//--------------------------------------------
// Minus
//--------------------------------------------

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

//--------------------------------------------
// Numeric value
//--------------------------------------------

rx+=
   riskMinusW+
   riskGap;

RG_GUI_CreateText(
   RG_GUI_RISK_VALUE,
   "",
   rx,
   riskY+13,
   RG_GUI_TEXT,
   RG_GUI_TEXT_SIZE,
   RG_GUI_Z_TEXT
);

//--------------------------------------------
// Plus
//--------------------------------------------

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

//--------------------------------------------
// Percent
//--------------------------------------------

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

//--------------------------------------------
// Dollar
//--------------------------------------------

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

//--------------------------------------------
// Lot
//--------------------------------------------

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

// Preview risk/reward information is displayed directly
// under the Risk controls and above BUY / SELL / SET.
RG_GUI_CreateText(
   RG_GUI_RISK_INFO,
   "Risk $ 0.00    Reward $ 0.00    R:R  —",
   riskX,
   riskY+47,
   RG_GUI_YELLOW,
   RG_GUI_STATUS_SIZE,
   RG_GUI_Z_TEXT
);

//====================================================
// BUY / SELL / SET
//
// Now BELOW the Risk row.
//====================================================

RG_GUI_CreateButton(
   RG_GUI_BUY,
   "BUY",
   L.actionX,
   L.primaryY,
   L.actionW,
   RG_GUI_BUTTON_H,
   RG_GUI_GREEN,
   clrBlack,
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
   clrWhite,
   RG_GUI_Z_BUTTON
);

RG_GUI_CreateButton(
   RG_GUI_SET,
   "SET",
   L.actionX+
   (L.actionW+
   L.actionGap)*2,
   L.primaryY,
   L.actionW,
   RG_GUI_BUTTON_H,
   RG_GUI_BLUE,
   clrWhite,
   RG_GUI_Z_BUTTON
);

RG_GUI_UpdateRiskControls();

   // Utility actions.
   RG_GUI_CreateButton(
      RG_GUI_CLOSE,"CLOSE ALL",
      L.actionX,L.fieldsY,L.actionW,RG_GUI_BUTTON_H,
      RG_GUI_ORANGE,clrBlack,RG_GUI_Z_BUTTON
   );
   RG_GUI_CreateButton(
      RG_GUI_TRAILING,"TRAILING",
      L.actionX+L.actionW+L.actionGap,L.fieldsY,L.actionW,RG_GUI_BUTTON_H,
      RG_GUI_YELLOW,clrBlack,RG_GUI_Z_BUTTON
   );
   RG_GUI_CreateButton(
      RG_GUI_CANCEL,"CANCEL",
      L.actionX+(L.actionW+L.actionGap)*2,L.fieldsY,L.actionW,RG_GUI_BUTTON_H,
      RG_GUI_RED,clrWhite,RG_GUI_Z_BUTTON
   );

   RG_GUI_UpdateRiskControls();

   // Collapsible position header.
   RG_GUI_CreateButton(
      RG_GUI_SECTION_TOGGLE,
      "OPEN POSITIONS ("+IntegerToString(count)+")  "+(g_RG_GUI_PositionsExpanded?"[ - ]":"[ + ]"),
      x+RG_GUI_PAD,sectionY,
      w-(2*RG_GUI_PAD),RG_GUI_SECTION_H,
      RG_GUI_HEADER_BG,RG_GUI_YELLOW,RG_GUI_Z_BUTTON
   );

   // Market information card.
   RG_GUI_CreateRect(
      RG_GUI_MARKET_BG,
      x+RG_GUI_PAD,marketY,
      w-(2*RG_GUI_PAD),RG_GUI_MARKET_H,
      RG_GUI_HEADER_BG,RG_GUI_BORDER,RG_GUI_Z_PANEL+1
   );

   int mid=x+(w/2);
   RG_GUI_CreateText(RG_GUI_SYMBOL,"Symbol : "+Symbol(),x+RG_GUI_PAD+18,marketY+16,RG_GUI_MUTED,RG_GUI_TEXT_SIZE,RG_GUI_Z_TEXT);
   RG_GUI_CreateText(RG_GUI_SPREAD,"Spread : 0",x+RG_GUI_PAD+18,marketY+52,RG_GUI_MUTED,RG_GUI_TEXT_SIZE,RG_GUI_Z_TEXT);
   RG_GUI_CreateText(RG_GUI_PROFIT,"Profit : $0.00",x+RG_GUI_PAD+18,marketY+88,RG_GUI_GREEN,RG_GUI_TEXT_SIZE,RG_GUI_Z_TEXT);

   RG_GUI_CreateText(RG_GUI_MARKET_MAXLOT,"Max Lot : 0.00",mid,marketY+16,RG_GUI_MUTED,RG_GUI_TEXT_SIZE,RG_GUI_Z_TEXT);
   RG_GUI_CreateText(RG_GUI_MARKET_ACTIVE,"Active : 0/0",mid,marketY+52,RG_GUI_MUTED,RG_GUI_TEXT_SIZE,RG_GUI_Z_TEXT);
   RG_GUI_CreateText(RG_GUI_MARKET_SERVER,"Server : 00:00:00",mid,marketY+88,RG_GUI_YELLOW,RG_GUI_TEXT_SIZE,RG_GUI_Z_TEXT);

   RG_GUI_CreateRect(
      RG_GUI_FOOTER,x,footerY,w,RG_GUI_FOOTER_H,
      RG_GUI_FOOTER_BG,RG_GUI_BORDER,RG_GUI_Z_PANEL+2
   );
   RG_GUI_CreateText(
      RG_GUI_FOOTER_TEXT,"",x+RG_GUI_PAD,footerY+9,
      RG_GUI_MUTED,RG_GUI_TEXT_SIZE,RG_GUI_Z_TEXT
   );

   g_RG_GUI_LastChartWidth=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);

   RG_StatusReady();
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
   int active=RG_GUI_ActivePositionCount();

   if(ObjectFind(0,RG_GUI_MARKET_MAXLOT)>=0)
      RG_GUI_SetText(
         RG_GUI_MARKET_MAXLOT,
         "Max Lot : "+DoubleToString(MaxLot,2),
         RG_GUI_MUTED
      );

   if(ObjectFind(0,RG_GUI_MARKET_ACTIVE)>=0)
      RG_GUI_SetText(
         RG_GUI_MARKET_ACTIVE,
         "Active : "+IntegerToString(active)+"/"+IntegerToString(MaxOpenPositions),
         RG_GUI_MUTED
      );

   if(ObjectFind(0,RG_GUI_MARKET_SERVER)>=0)
      RG_GUI_SetText(
         RG_GUI_MARKET_SERVER,
         "Server : "+TimeToString(TimeCurrent(),TIME_SECONDS),
         RG_GUI_YELLOW
      );

   if(ObjectFind(0,RG_GUI_FOOTER_TEXT)>=0)
      RG_GUI_SetText(
         RG_GUI_FOOTER_TEXT,
         "RiskGuard MT4  |  Trade",
         RG_GUI_MUTED
      );

   // Keep server time visible while the whole panel is collapsed.
   if(!g_RG_GUI_PanelExpanded &&
      ObjectFind(0,RG_GUI_PANEL_TOGGLE)>=0)
   {
      ObjectSetString(
         0,
         RG_GUI_PANEL_TOGGLE,
         OBJPROP_TEXT,
         "RiskGuard MT4   | Server: "+
         TimeToString(TimeCurrent(),TIME_SECONDS)+
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

   if(ObjectFind(0,RG_GUI_SYMBOL)>=0)
   {
      RG_GUI_SetText(
         RG_GUI_SYMBOL,
         "Symbol : "+Symbol(),
         RG_GUI_MUTED
      );
   }

   if(ObjectFind(0,RG_GUI_SPREAD)>=0)
   {
      double spread=
         (Point>0 ? (Ask-Bid)/Point : 0);

      RG_GUI_SetText(
         RG_GUI_SPREAD,
         "Spread : "+DoubleToString(spread,1),
         RG_GUI_MUTED
      );
   }

   double profit=0;

   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(
         i,SELECT_BY_POS,MODE_TRADES))
         continue;

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
      (profit>=0?"+$":"-$")+
      DoubleToString(MathAbs(profit),2),
      profit>=0?RG_GUI_GREEN:RG_GUI_RED
   );

   RG_GUI_UpdatePositionSectionLayout();
   RG_GUI_UpdateRiskInfo();
   RG_UpdateFooter();

   ChartRedraw();
}

void RG_RefreshGUI()
{
   RG_UpdateGUI();
   ChartRedraw();
}

#endif
