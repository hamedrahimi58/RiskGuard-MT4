#property strict

//====================================================
// RiskGuard MT4
// Main Expert Advisor
// Stage 3: Multi-Symbol Positions
// News: Today Only / Server Time
//
// PRE-TRADE FLOW
//
// 1) EA starts with NO synthetic preview.
// 2) BUY / SELL creates one frozen preview.
// 3) Entry / SL / TP can be edited before SET.
// 4) SET sends the selected market order.
// 5) Preview is deleted after successful SET.
// 6) CANCEL removes preview without trading.
// 7) Native MT4 Entry / SL / TP remain the live controls.
//====================================================

#include <RG_Settings.mqh>
#include <RG_Runtime.mqh>

#include <Trade/RG_Broker.mqh>
#include <Trade/RG_PositionSizer.mqh>
#include <Trade/RG_PositionManager.mqh>
#include <Trade/RG_PositionCloser.mqh>
#include <Trade/RG_Trade.mqh>

#include <Trade/RG_RiskFree.mqh>
#include <Trade/RG_Trailing.mqh>
#include <Trade/RG_TakeProfit.mqh>

#include <RG_Journal.mqh>
#include <RG_GUI.mqh>
#include <RG_License.mqh>
#include <GUI/RG_TrailingSetup.mqh>
#include <GUI/RG_TradeVisualization.mqh>

//====================================================
// Chart state owned by the EA while it is attached
//====================================================

bool   g_RG_OriginalChartShift=false;
double g_RG_OriginalShiftSize=0.0;
bool   g_RG_ChartStateCaptured=false;

//====================================================
// Stage 4A pending UI state
//====================================================

bool g_RG_PendingPreview=false;

string RG_MainPreviewGVPrefix()
{
   return("RiskGuard.MainPreview."+IntegerToString((int)ChartID())+"."+Symbol()+".");
}

void RG_SaveMainPreviewState()
{
   if(!RG_RuntimePreviewActive())
      return;

   string p=RG_MainPreviewGVPrefix();
   GlobalVariableSet(p+"pending",g_RG_PendingPreview?1.0:0.0);
   GlobalVariableSet(p+"bid",RG_TV_PendingBidSnapshot());
   GlobalVariableSet(p+"ask",RG_TV_PendingAskSnapshot());
}

void RG_RestoreMainPreviewState()
{
   string p=RG_MainPreviewGVPrefix();
   if(!GlobalVariableCheck(p+"pending"))
      return;

   g_RG_PendingPreview=(GlobalVariableGet(p+"pending")>0.5);

   if(GlobalVariableCheck(p+"bid") && GlobalVariableCheck(p+"ask"))
      RG_TV_SetPendingMarketSnapshot(GlobalVariableGet(p+"bid"),GlobalVariableGet(p+"ask"));

   RG_TV_SetPendingPreview(g_RG_PendingPreview);
}

void RG_ClearMainPreviewState()
{
   string p=RG_MainPreviewGVPrefix();
   GlobalVariableDel(p+"pending");
   GlobalVariableDel(p+"bid");
   GlobalVariableDel(p+"ask");
}
int  g_RG_PendingDirection=-1;

//====================================================
// STAGE 4A - PENDING ORDER ENGINE
//
// This layer is intentionally independent from GUI/Preview.
// Pending order identity is determined by order type + symbol.
// All broker constraints are read from the target symbol.
// Stage 4A does NOT alter the existing market-order flow.
//====================================================

bool RG_PendingTypeValid(int pendingType)
{
   return(
      pendingType==OP_BUYSTOP  ||
      pendingType==OP_BUYLIMIT ||
      pendingType==OP_SELLSTOP ||
      pendingType==OP_SELLLIMIT
   );
}

// Validate the requested pending entry against the target symbol.
bool RG_ValidatePendingEntry(
   string symbol,
   int pendingType,
   double entryPrice)
{
   if(symbol=="")
      return(false);

   if(!RG_PendingTypeValid(pendingType))
      return(false);

   double bid=MarketInfo(symbol,MODE_BID);
   double ask=MarketInfo(symbol,MODE_ASK);

   int digits=(int)MarketInfo(symbol,MODE_DIGITS);
   double point=MarketInfo(symbol,MODE_POINT);

   int stopLevelPoints=(int)MarketInfo(symbol,MODE_STOPLEVEL);
   int freezeLevelPoints=(int)MarketInfo(symbol,MODE_FREEZELEVEL);

   if(bid<=0.0 || ask<=0.0 || point<=0.0)
      return(false);

   entryPrice=NormalizeDouble(entryPrice,digits);

   double minimumDistance=
      MathMax(stopLevelPoints,freezeLevelPoints)*
      point;

   if(pendingType==OP_BUYSTOP)
   {
      if(entryPrice<=ask)
         return(false);

      if((entryPrice-ask)<minimumDistance)
         return(false);
   }

   if(pendingType==OP_BUYLIMIT)
   {
      if(entryPrice>=ask)
         return(false);

      if((ask-entryPrice)<minimumDistance)
         return(false);
   }

   if(pendingType==OP_SELLSTOP)
   {
      if(entryPrice>=bid)
         return(false);

      if((bid-entryPrice)<minimumDistance)
         return(false);
   }

   if(pendingType==OP_SELLLIMIT)
   {
      if(entryPrice<=bid)
         return(false);

      if((entryPrice-bid)<minimumDistance)
         return(false);
   }

   return(true);
}

// Validate SL/TP against the pending entry and target symbol.
// Zero means "not set".
bool RG_ValidatePendingStops(
   string symbol,
   int pendingType,
   double entryPrice,
   double sl,
   double tp)
{
   if(symbol=="")
      return(false);

   if(!RG_PendingTypeValid(pendingType))
      return(false);

   int digits=(int)MarketInfo(symbol,MODE_DIGITS);
   double point=MarketInfo(symbol,MODE_POINT);

   if(point<=0.0)
      return(false);

   entryPrice=NormalizeDouble(entryPrice,digits);
   sl=NormalizeDouble(sl,digits);
   tp=NormalizeDouble(tp,digits);

   bool isBuy=
      (pendingType==OP_BUYSTOP ||
       pendingType==OP_BUYLIMIT);

   if(isBuy)
   {
      if(sl>0.0 && sl>=entryPrice)
         return(false);

      if(tp>0.0 && tp<=entryPrice)
         return(false);
   }
   else
   {
      if(sl>0.0 && sl<=entryPrice)
         return(false);

      if(tp>0.0 && tp>=entryPrice)
         return(false);
   }

   return(true);
}

// Validate the complete Stage 4A pending request.
bool RG_ValidatePendingRequest(
   string symbol,
   int pendingType,
   double lots,
   double entryPrice,
   double sl,
   double tp)
{
   if(!RG_PendingTypeValid(pendingType))
      return(false);

   if(symbol=="")
      return(false);

   if(lots<=0.0)
      return(false);

   double minLot=
      MarketInfo(symbol,MODE_MINLOT);

   double maxLot=
      MarketInfo(symbol,MODE_MAXLOT);

   double lotStep=
      MarketInfo(symbol,MODE_LOTSTEP);

   if(minLot<=0.0 ||
      maxLot<=0.0 ||
      lotStep<=0.0)
      return(false);

   if(lots<minLot-0.00000001 ||
      lots>maxLot+0.00000001)
      return(false);

   double lotUnits=
      lots/lotStep;

   if(MathAbs(lotUnits-MathRound(lotUnits))>0.000001)
      return(false);

   if(!RG_ValidatePendingEntry(
      symbol,
      pendingType,
      entryPrice))
      return(false);

   if(!RG_ValidatePendingStops(
      symbol,
      pendingType,
      entryPrice,
      sl,
      tp))
      return(false);

   return(true);
}

// Stage 4A native pending sender.
// GUI/Preview/Risk calculations will call this in later sub-stages.
int RG_SendPendingOrder(
   string symbol,
   int pendingType,
   double lots,
   double entryPrice,
   double sl,
   double tp,
   string comment)
{
   if(!RG_ValidatePendingRequest(
      symbol,
      pendingType,
      lots,
      entryPrice,
      sl,
      tp))
   {
      Print(
         "RiskGuard Pending validation failed. Symbol=",
         symbol,
         " Type=",
         pendingType
      );

      return(-1);
   }

   int digits=(int)MarketInfo(symbol,MODE_DIGITS);

   double price=
      NormalizeDouble(entryPrice,digits);

   double stopLoss=
      (sl>0.0 ?
       NormalizeDouble(sl,digits) :
       0.0);

   double takeProfit=
      (tp>0.0 ?
       NormalizeDouble(tp,digits) :
       0.0);

   ResetLastError();

   int ticket=OrderSend(
      symbol,
      pendingType,
      lots,
      price,
      0,
      stopLoss,
      takeProfit,
      comment,
      MagicNumber,
      0,
      clrNONE
   );

   if(ticket<0)
   {
      int error=GetLastError();

      Print(
         "RiskGuard Pending OrderSend failed. ",
         "Symbol=",symbol,
         " Type=",pendingType,
         " Lots=",DoubleToString(lots,2),
         " Entry=",DoubleToString(price,digits),
         " SL=",DoubleToString(stopLoss,digits),
         " TP=",DoubleToString(takeProfit,digits),
         " Error=",error
      );

      return(-1);
   }

   Print(
      "RiskGuard Pending order opened. ",
      "Ticket=",ticket,
      " Symbol=",symbol,
      " Type=",pendingType
   );

   return(ticket);
}

//====================================================
// Stage 4A Pending UI helpers
//====================================================

void RG_ClearPendingMode()
{
   g_RG_PendingPreview=false;
   g_RG_PendingDirection=-1;
}

int RG_DetectPendingType(int direction,double entry)
{
   if(direction!=OP_BUY && direction!=OP_SELL)
      return(-1);

   double bid=MarketInfo(Symbol(),MODE_BID);
   double ask=MarketInfo(Symbol(),MODE_ASK);

   if(bid<=0.0 || ask<=0.0 || entry<=0.0)
      return(-1);

   if(direction==OP_BUY)
   {
      if(entry>ask) return(OP_BUYSTOP);
      if(entry<ask) return(OP_BUYLIMIT);
   }
   else
   {
      if(entry<bid) return(OP_SELLSTOP);
      if(entry>bid) return(OP_SELLLIMIT);
   }

   return(-1);
}

string RG_PendingTypeName(int pendingType)
{
   if(pendingType==OP_BUYSTOP) return("BUY STOP");
   if(pendingType==OP_BUYLIMIT) return("BUY LIMIT");
   if(pendingType==OP_SELLSTOP) return("SELL STOP");
   if(pendingType==OP_SELLLIMIT) return("SELL LIMIT");
   return("PENDING");
}

bool RG_CreatePendingPreview(int direction)
{
   if(direction!=OP_BUY && direction!=OP_SELL)
      return(false);

   // Capture the tradable market price ONCE when the button is pressed.
   // After this point ticks must not reposition the preview.
   RG_TV_CapturePendingMarketSnapshot();

   if(!RG_GUI_CreateRiskPreview(direction))
      return(false);

   g_RG_PendingPreview=true;
   g_RG_PendingDirection=direction;

   RG_TV_ShowPreview(direction);
   RG_GUI_UpdateRiskInfo();

   return(true);
}

//====================================================
// Status
//====================================================

void RG_PanelStatus(string text)
{
   RG_GUI_SetText(
      RG_GUI_STATUS,
      "●  "+text,
      RG_GUI_TEXT
   );
}

void RG_MainStatus(string text)
{
   RG_PanelStatus(text);
}

//====================================================
// Manual Break Even
//====================================================

bool RG_PanelBreakEvenTicket(int ticket)
{
   if(ticket<=0)
      return(false);

   if(!OrderSelect(ticket,SELECT_BY_TICKET))
      return(false);

   // Stage 3: positions are NOT restricted to the chart symbol.
   // Ticket is the identity; OrderSymbol() supplies the position symbol.
   int orderType=OrderType();

   if(orderType!=OP_BUY &&
      orderType!=OP_SELL)
      return(false);

   string orderSymbol=OrderSymbol();

   double orderBid=
      MarketInfo(orderSymbol,MODE_BID);

   double orderAsk=
      MarketInfo(orderSymbol,MODE_ASK);

   int orderDigits=
      (int)MarketInfo(orderSymbol,MODE_DIGITS);

   double orderPoint=
      MarketInfo(orderSymbol,MODE_POINT);

   double stopLevel=
      MarketInfo(orderSymbol,MODE_STOPLEVEL)*
      orderPoint;

   if(orderBid<=0.0 || orderAsk<=0.0)
      return(false);

   double openPrice=
      NormalizeDouble(
         OrderOpenPrice(),
         orderDigits
      );

   double newSL=openPrice;

   if(orderType==OP_BUY)
   {
      if(newSL>=orderBid-stopLevel)
         return(false);

      if(OrderStopLoss()>0 &&
         OrderStopLoss()>=newSL)
         return(true);
   }
   else
   {
      if(newSL<=orderAsk+stopLevel)
         return(false);

      if(OrderStopLoss()>0 &&
         OrderStopLoss()<=newSL)
         return(true);
   }

   ResetLastError();

   if(!OrderModify(
      ticket,
      OrderOpenPrice(),
      newSL,
      OrderTakeProfit(),
      0,
      clrNONE))
   {
      Print(
         "RiskGuard BE failed. Ticket=",
         ticket,
         " Error=",
         GetLastError()
      );

      return(false);
   }

   return(true);
}

//====================================================
// Manual RiskFree
//
// RF is deliberately different from BE. The dedicated RF engine
// requires live price room beyond Entry equal to current Spread +
// Commission before it will place an RF stop.
//====================================================
bool RG_PanelRiskFreeTicket(int ticket)
{
   return(RG_ApplyManualRiskFree(ticket));
}

//====================================================
// STAGE 3 - MULTI-SYMBOL POSITIONS
//
// Position identity is the MT4 ticket.
// OrderSymbol() is used for all position-specific market data.
// The chart symbol must never restrict management of another
// open position belonging to this EA/MagicNumber.
//====================================================

//====================================================
// Native MT4 levels
//====================================================

void RG_EnableNativeTradeLevels()
{
   ChartSetInteger(
      0,
      CHART_SHOW_TRADE_LEVELS,
      true
   );
}

void RG_CaptureChartState()
{
   if(g_RG_ChartStateCaptured)
      return;

   g_RG_OriginalChartShift=
      (bool)ChartGetInteger(
         0,
         CHART_SHIFT,
         0
      );

   g_RG_OriginalShiftSize=
      ChartGetDouble(
         0,
         CHART_SHIFT_SIZE,
         0
      );

   g_RG_ChartStateCaptured=true;
}

void RG_RestoreChartState()
{
   if(!g_RG_ChartStateCaptured)
      return;

   ChartSetInteger(
      0,
      CHART_SHIFT,
      g_RG_OriginalChartShift
   );

   ChartSetDouble(
      0,
      CHART_SHIFT_SIZE,
      g_RG_OriginalShiftSize
   );

   ChartRedraw();

   g_RG_ChartStateCaptured=false;
}

//====================================================
// INIT
//====================================================

int OnInit()
{
   RG_CaptureChartState();

   // Force a fresh read of current EA Inputs on every MT4 reinitialization.
   RG_RuntimeResetForInputs();
   RG_RuntimeInit();

   // Auto Risk Free is panel-controlled. Preserve the user's ON/OFF choice
   // across chart/EA reinitialization; default to OFF only on first use.
   string rgAutoRFKey="RG_AUTO_RF_STATE_"+IntegerToString(AccountNumber())+"_"+IntegerToString((int)ChartID());
   if(GlobalVariableCheck(rgAutoRFKey))
      RG_SetAutoRiskFreeEnabled(GlobalVariableGet(rgAutoRFKey)>0.5);
   else
      RG_SetAutoRiskFreeEnabled(false);
   RG_RuntimeClearPreview();
   RG_TrailingSetupClose();
   RG_TV_DeleteTradeVisualization();

   // Restore a frozen Preview after a timeframe/chart reinitialization.
   // The snapshot contains the exact Entry/SL/TP values from before the change.
   bool rgPreviewRestored=RG_RuntimeRestorePreviewSnapshot();
   RG_RestoreMainPreviewState();

   if(rgPreviewRestored)
   {
      // Pending state is restored by the persistence block below if present.
      // The visualization itself is redrawn after the panel is initialized.
   }

   // MT4 owns real Entry / SL / TP visualization.
   RG_EnableNativeTradeLevels();

   // Native MT4 trade levels remain enabled.
   // Closed-trade history markers are not controlled through
   // an MQL4 ChartSetInteger property.

   RG_SpecialTimesInit();
   RG_GUI_LoadToolsPreferences();
   RG_JournalInit();

   // Clear chart objects left by an older News/Session EA instance before
   // rebuilding the current panel and timeline visualization.
   RG_NewsDeleteObjects();
   RG_GUI_DeleteSessionObjects();

   EventSetTimer(1);
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
   ChartSetInteger(0,CHART_EVENT_MOUSE_WHEEL,true);

   if(!RG_CreatePanel())
   {
      EventKillTimer();
      RG_RestoreChartState();
      return(INIT_FAILED);
   }

   RG_StatusReady();

   // Simple private-license guard. The panel remains visible when locked,
   // but all trading and position-management operations are disabled.
   if(!RG_LicenseIsValid())
   {
      RG_RuntimeClearPreview();
      RG_RuntimeClearPreviewSnapshot();
      RG_ClearMainPreviewState();
      RG_TrailingSetupClose();
   RG_TV_DeleteTradeVisualization();
   }

   RG_ProcessPositionManager();
   RG_UpdateGUI();
   RG_UpdateFooter();
   RG_LicenseApplyStatus();

   if(rgPreviewRestored && RG_LicenseIsValid())
      RG_ProcessTradeVisualization();

   ChartRedraw();

   return(INIT_SUCCEEDED);
}

//====================================================
// DEINIT
//====================================================

void OnDeinit(const int reason)
{
   // Timeframe/symbol chart changes reinitialize the EA. Preserve the
   // frozen Preview only for that lifecycle event.
   if(reason==REASON_CHARTCHANGE && RG_RuntimePreviewActive())
   {
      RG_RuntimeSavePreviewSnapshot();
      RG_SaveMainPreviewState();
   }
   else if(reason!=REASON_CHARTCHANGE)
   {
      RG_RuntimeClearPreviewSnapshot();
      RG_ClearMainPreviewState();
   }

   EventKillTimer();
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,false);
   ChartSetInteger(0,CHART_EVENT_MOUSE_WHEEL,false);

   RG_TrailingSetupClose();
   RG_TV_DeleteTradeVisualization();
   RG_SpecialTimesDelete();

   // News and Sessions are chart objects, so remove them explicitly on EA
   // deinitialization. They will be recreated cleanly after reinitialization.
   RG_NewsDeleteObjects();
   RG_GUI_DeleteSessionObjects();

   RG_DeletePanel();

   RG_RestoreChartState();
}

//====================================================
// TIMER
//====================================================

void OnTimer()
{
   RG_SpecialTimesUpdate();

   if(!RG_LicenseIsValid())
   {
      RG_UpdateGUI();
      RG_UpdateFooter();
      RG_LicenseApplyStatus();
      return;
   }

   // If MT4's native Delete/Backspace handling removes Journal objects,
   // recover the active editor on the next timer without changing the
   // underlying keyboard behavior. This is only a resilience layer.
   if(g_RG_GUI_JournalEditType>=0 && ObjectFind(0,RG_GUI_JV_NAMEEDIT)<0)
      RG_GUI_CreateJournalRenameDialog();

   RG_RuntimeSyncInputDefaults();
   RG_NewsEngineUpdate();
   RG_GUI_UpdateSessionVisualization();
   RG_JournalUpdate();
   RG_ProcessPositionManager();

   RG_UpdateGUI();
   RG_UpdateFooter();
   RG_LicenseApplyStatus();

   // Only the selected frozen preview is drawn.
   RG_ProcessTradeVisualization();
}

//====================================================
// TICK
//====================================================

void OnTick()
{
   RefreshRates();
   RG_SpecialTimesUpdate();

   if(!RG_LicenseIsValid())
   {
      RG_UpdateGUI();
      RG_UpdateFooter();
      RG_LicenseApplyStatus();
      return;
   }

   RG_RuntimeSyncInputDefaults();
   RG_GUI_UpdateSessionVisualization();
   RG_JournalUpdate();
   RG_ProcessPositionManager();

   // Manual RF is controlled by the position-row RF button.
   // Automatic RF is controlled by the panel AUTO RF toggle.
   RG_ProcessRiskFree();

   // Trailing is controlled independently per position by its TR button.
   RG_ProcessTrailing();

   RG_UpdateGUI();
   RG_UpdateFooter();
   RG_LicenseApplyStatus();

   // Preview values are not recalculated from Ask/Bid.
   RG_ProcessTradeVisualization();
}

void RG_SaveSpecialTimeFromGUI(int i)
{
   string tn=RG_GUI_ST_TimeName(i);
   string ln=RG_GUI_ST_LabelName(i);
   if(ObjectFind(0,tn)<0 || ObjectFind(0,ln)<0) return;
   string tm=ObjectGetString(0,tn,OBJPROP_TEXT);
   string lb=ObjectGetString(0,ln,OBJPROP_TEXT);
   RG_SpecialTimesSetEvent(i,RG_SpecialTimesGetEnabled(i),tm,lb,RG_SpecialTimesGetColor(i));
}

//====================================================
// CHART EVENT
//====================================================

//====================================================
// J-03 EXCEL EXPORT - shared UI action
//====================================================
bool RG_DoJournalExcelExport()
{
   if(ObjectFind(0,RG_GUI_JV_REPORT_SUM)>=0)
      ObjectSetString(0,RG_GUI_JV_REPORT_SUM,OBJPROP_TEXT,"EXPORTING...");
   ChartRedraw();

   string fs=g_RG_GUI_JournalReportFrom;
   string ts=g_RG_GUI_JournalReportTo;
   if(ObjectFind(0,RG_GUI_JV_REPORT_FROM)>=0)
   {
      string v=ObjectGetString(0,RG_GUI_JV_REPORT_FROM,OBJPROP_TEXT);
      if(StringLen(v)>0) fs=v;
   }
   if(ObjectFind(0,RG_GUI_JV_REPORT_TO)>=0)
   {
      string v=ObjectGetString(0,RG_GUI_JV_REPORT_TO,OBJPROP_TEXT);
      if(StringLen(v)>0) ts=v;
   }

   datetime fd=StrToTime(fs);
   datetime td=StrToTime(ts);
   if(fd<=0 || td<=0 || td<fd)
   {
      if(ObjectFind(0,RG_GUI_JV_REPORT_SUM)>=0)
         ObjectSetString(0,RG_GUI_JV_REPORT_SUM,OBJPROP_TEXT,"Invalid date range. Use YYYY.MM.DD");
      ChartRedraw();
      return(false);
   }

   g_RG_GUI_JournalReportFrom=fs;
   g_RG_GUI_JournalReportTo=ts;
   string outFile="";
   bool exported=RG_JournalExportRaw(fd,td,outFile);
   if(ObjectFind(0,RG_GUI_JV_REPORT_SUM)>=0)
   {
      if(exported)
         ObjectSetString(0,RG_GUI_JV_REPORT_SUM,OBJPROP_TEXT,"Excel Journal exported: "+outFile);
      else
         ObjectSetString(0,RG_GUI_JV_REPORT_SUM,OBJPROP_TEXT,"Export failed. MT4 error: "+IntegerToString(g_RG_JournalLastExportError));
   }
   ChartRedraw();
   return(exported);
}

bool RG_JournalReportDateFieldHit(int mx,int my,int &field)
{
   field=0;
   if(!g_RG_GUI_JournalReportOpen) return(false);

   int cw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   int ch=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   int w=RG_GUI_S(560), h=RG_GUI_S(270);
   if(w>cw-RG_GUI_S(20)) w=cw-RG_GUI_S(20);
   if(h>ch-RG_GUI_S(20)) h=ch-RG_GUI_S(20);
   int x=(cw-w)/2, y=(ch-h)/2;

   int fx=x+RG_GUI_S(12), fy=y+RG_GUI_S(52);
   int tx=x+RG_GUI_S(250), ty=y+RG_GUI_S(52);
   int fw=RG_GUI_S(210), fh=RG_GUI_S(24);

   if(mx>=fx && mx<=fx+fw && my>=fy && my<=fy+fh)
   {
      field=1;
      return(true);
   }
   if(mx>=tx && mx<=tx+fw && my>=ty && my<=ty+fh)
   {
      field=2;
      return(true);
   }
   return(false);
}

void RG_JournalReportFocusField(int field)
{
   if(field<1 || field>2) return;
   g_RG_GUI_JournalReportEditField=field;
   g_RG_GUI_JournalReportEditFocused=true;

   // The report date is entered as a complete YYYY.MM.DD value.
   // Clearing here makes the first typed digit deterministic and avoids
   // fighting the native OBJ_EDIT selection state.
   if(field==1)
   {
      g_RG_GUI_JournalReportFrom="";
      if(ObjectFind(0,RG_GUI_JV_REPORT_FROM)>=0)
      {
         ObjectSetInteger(0,RG_GUI_JV_REPORT_FROM,OBJPROP_READONLY,false);
         ObjectSetInteger(0,RG_GUI_JV_REPORT_FROM,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,RG_GUI_JV_REPORT_FROM,OBJPROP_SELECTED,true);
         ObjectSetString(0,RG_GUI_JV_REPORT_FROM,OBJPROP_TEXT,"");
         ObjectSetInteger(0,RG_GUI_JV_REPORT_FROM,OBJPROP_ZORDER,65000);
      }
   }
   else
   {
      g_RG_GUI_JournalReportTo="";
      if(ObjectFind(0,RG_GUI_JV_REPORT_TO)>=0)
      {
         ObjectSetInteger(0,RG_GUI_JV_REPORT_TO,OBJPROP_READONLY,false);
         ObjectSetInteger(0,RG_GUI_JV_REPORT_TO,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,RG_GUI_JV_REPORT_TO,OBJPROP_SELECTED,true);
         ObjectSetString(0,RG_GUI_JV_REPORT_TO,OBJPROP_TEXT,"");
         ObjectSetInteger(0,RG_GUI_JV_REPORT_TO,OBJPROP_ZORDER,65000);
      }
   }
   ChartSetInteger(0,CHART_KEYBOARD_CONTROL,true);
   ChartRedraw();
}

bool RG_JournalReportExportHit(int mx,int my)
{
   if(!g_RG_GUI_JournalReportOpen) return(false);
   int cw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   int ch=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   int w=RG_GUI_S(560), h=RG_GUI_S(270);
   if(w>cw-RG_GUI_S(20)) w=cw-RG_GUI_S(20);
   if(h>ch-RG_GUI_S(20)) h=ch-RG_GUI_S(20);
   int x=(cw-w)/2, y=(ch-h)/2;
   int bx=x+RG_GUI_S(188), by=y+RG_GUI_S(86);
   int bw=RG_GUI_S(118), bh=RG_GUI_S(24);
   return(mx>=bx && mx<=bx+bw && my>=by && my<=by+bh);
}

void OnChartEvent(
   const int id,
   const long &lparam,
   const double &dparam,
   const string &sparam)
{
   // Locked builds keep the panel visible but ignore all chart controls.
   if(!RG_LicenseIsValid())
   {
      RG_LicenseApplyStatus();
      return;
   }

   //=================================================
   // ACCOUNT-WIDE JOURNAL SETTINGS SYNC
   //=================================================
   if(id==CHARTEVENT_CUSTOM+RG_JOURNAL_SYNC_EVENT_ID)
   {
      // Never interrupt an active Pattern/Trigger/Condition editor.
      // The next timer cycle will reload the shared settings after the
      // editor is closed.
      if(g_RG_GUI_JournalEditType>=0)
      {
         g_RG_JournalPendingSync=true;
         return;
      }

      RG_JournalHandleSettingsSync();
      RG_CreatePanel();
      ChartRedraw();
      return;
   }

   //=================================================
   // HELD RISK +/- BUTTON
   //=================================================
   if(id==CHARTEVENT_MOUSE_MOVE)
   {
      int mouseX=(int)lparam;
      int mouseY=(int)dparam;

      // Panel drag is handled first. It only activates from the header.
      // RG_GUI temporarily disables CHART_MOUSE_SCROLL during an active drag,
      // then restores the chart's previous scroll state on mouse release.
      // Risk +/- hold continues to work everywhere else.
      bool panelDragHandled=
         RG_GUI_HandlePanelMouseMove(
            mouseX,
            mouseY,
            sparam
         );

      RG_GUI_HandleRiskMouseHold(
         mouseX,
         mouseY,
         sparam
      );

      if(panelDragHandled)
         return;

      return;
   }

   //=================================================
   // JOURNAL TRADE DESCRIPTION KEYBOARD INPUT
   //=================================================
   if(id==CHARTEVENT_KEYDOWN && g_RG_GUI_JournalDescriptionOpen)
   {
      int k=(int)lparam;
      if(k==13)
      {
         RG_JournalSetDescription(g_RG_GUI_JournalDescriptionTicket,g_RG_GUI_JournalDescriptionBuffer);
         RG_GUI_DeleteJournalDescriptionPanel();
         RG_CreatePanel();
         RG_UpdateGUI();
         ChartRedraw();
         return;
      }
      if(k==27)
      {
         RG_GUI_DeleteJournalDescriptionPanel();
         RG_CreatePanel();
         RG_UpdateGUI();
         ChartRedraw();
         return;
      }
      if(k==8)
      {
         int n=StringLen(g_RG_GUI_JournalDescriptionBuffer);
         if(n>0) g_RG_GUI_JournalDescriptionBuffer=StringSubstr(g_RG_GUI_JournalDescriptionBuffer,0,n-1);
         if(ObjectFind(0,RG_GUI_JV_DESC_EDIT)>=0) ObjectSetString(0,RG_GUI_JV_DESC_EDIT,OBJPROP_TEXT,g_RG_GUI_JournalDescriptionBuffer);
         return;
      }
      if(k==46)
      {
         g_RG_GUI_JournalDescriptionBuffer="";
         if(ObjectFind(0,RG_GUI_JV_DESC_EDIT)>=0) ObjectSetString(0,RG_GUI_JV_DESC_EDIT,OBJPROP_TEXT,"");
         return;
      }
      string ch=RG_GUI_JournalKeyChar(k);
      if(ch!="" && StringLen(g_RG_GUI_JournalDescriptionBuffer)<240)
      {
         g_RG_GUI_JournalDescriptionBuffer+=ch;
         if(ObjectFind(0,RG_GUI_JV_DESC_EDIT)>=0) ObjectSetString(0,RG_GUI_JV_DESC_EDIT,OBJPROP_TEXT,g_RG_GUI_JournalDescriptionBuffer);
      }
      return;
   }

   //=================================================
   // JOURNAL RENAME DIALOG KEYBOARD INPUT
   //=================================================
   if(id==CHARTEVENT_KEYDOWN)
   {
      if(RG_GUI_HandleJournalReportKeyDown(lparam)) return;
      if(RG_GUI_HandleJournalKeyDown(lparam,sparam))
      {
         if(lparam==13 && g_RG_GUI_JournalEditType>=0)
         {
            // Reuse the normal OK path below by committing directly here.
            string kn=RG_JournalClean(ObjectGetString(0,RG_GUI_JV_NAMEEDIT,OBJPROP_TEXT));
            if(kn!="")
            {
               if(g_RG_GUI_JournalEditIndex<0)
               {
                  if(g_RG_GUI_JournalEditType==0) RG_JournalAddCondition(kn);
                  else if(g_RG_GUI_JournalEditType==1) RG_JournalAddPattern(kn);
                  else if(g_RG_GUI_JournalEditType==2) RG_JournalAddTrigger(kn);
               }
               else
               {
                  if(g_RG_GUI_JournalEditType==0) RG_JournalRenameItem(g_RG_JournalConditions,g_RG_JournalConditionCount,g_RG_GUI_JournalEditIndex,kn);
                  else if(g_RG_GUI_JournalEditType==1) RG_JournalRenameItem(g_RG_JournalPatterns,g_RG_JournalPatternCount,g_RG_GUI_JournalEditIndex,kn);
                  else if(g_RG_GUI_JournalEditType==2) RG_JournalRenameItem(g_RG_JournalTriggers,g_RG_JournalTriggerCount,g_RG_GUI_JournalEditIndex,kn);
               }
            }
            RG_GUI_JournalRestoreChartObjects();
            ObjectDelete(0,RG_GUI_JV_CFG); ObjectDelete(0,RG_GUI_JV_CFG+"_T"); ObjectDelete(0,RG_GUI_JV_NAMEEDIT); ObjectDelete(0,RG_GUI_JV_OK); ObjectDelete(0,RG_GUI_JV_CANCEL); ObjectDelete(0,RG_GUI_JV_CLEAR);
            g_RG_GUI_JournalEditIndex=-1; g_RG_GUI_JournalEditType=-1; g_RG_GUI_JournalEditFocused=false;
            if(RG_JournalHasPendingSync())
            {
               RG_JournalHandleSettingsSync();
               RG_JournalClearPendingSync();
            }
            RG_CreatePanel();
            ChartRedraw();
         }
         return;
      }
   }

   //=================================================
   // OPEN POSITIONS SCROLLBAR
   //=================================================
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam==RG_GUI_POS_SCROLL_TRACK)
      {
         RG_GUI_HandlePositionScrollbarClick((int)dparam);
         return;
      }
   }

   if(id==CHARTEVENT_OBJECT_DRAG)
   {
      if(RG_GUI_HandlePositionScrollbarDrag(sparam))
         return;
   }

   //=================================================
   // PREVIEW LINE DRAG
   //=================================================
   // Entry / SL / TP preview lines are native MT4 chart
   // objects. Their final dragged price is delivered here.
   // Commit it to Runtime, then rebuild the preview and risk UI.
   if(id==CHARTEVENT_OBJECT_DRAG)
   {
      if(RG_TV_HandlePreviewDrag(sparam))
      {
         if(RG_RuntimePreviewActive())
         {
            RG_GUI_UpdateRiskInfo();
            RG_MainStatus(
               "Preview updated - drag Entry / SL / TP then SET"
            );
         }

         if(RG_JournalPreviewIsOpen())
         {
            RG_GUI_RefreshJournalPreviewState();
         }
         RG_UpdateGUI();
         RG_UpdateFooter();
         ChartRedraw();
         return;
      }
   }

   //=================================================
   // J-02 JOURNAL SETTINGS EDITS
   //=================================================
   if(id==CHARTEVENT_OBJECT_ENDEDIT)
   {
      for(int jsi=0;jsi<100;jsi++)
      {
         if(sparam==RG_GUI_JV_SCond(jsi) && jsi<g_RG_JournalConditionCount)
         { RG_JournalRenameItem(g_RG_JournalConditions,g_RG_JournalConditionCount,jsi,ObjectGetString(0,sparam,OBJPROP_TEXT)); return; }
         if(sparam==RG_GUI_JV_SPat(jsi) && jsi<g_RG_JournalPatternCount)
         { RG_JournalRenameItem(g_RG_JournalPatterns,g_RG_JournalPatternCount,jsi,ObjectGetString(0,sparam,OBJPROP_TEXT)); return; }
         if(sparam==RG_GUI_JV_STrg(jsi) && jsi<g_RG_JournalTriggerCount)
         { RG_JournalRenameItem(g_RG_JournalTriggers,g_RG_JournalTriggerCount,jsi,ObjectGetString(0,sparam,OBJPROP_TEXT)); return; }
      }
   }

   //=================================================
   // Special Times are saved by the custom KEYDOWN editor.
   //=================================================

   //=================================================
   // STANDARD MT4 OBJ_EDIT FINISH
   //=================================================
   if(id==CHARTEVENT_OBJECT_ENDEDIT)
   {
      int idx=-1;
      bool isTime=RG_ST_IsTimeObject(sparam,idx);
      bool isLabel=RG_ST_IsLabelObject(sparam,idx);
      if((isTime || isLabel) && idx>=0 && idx<10)
      {
         string tn=RG_GUI_ST_TimeName(idx);
         string ln=RG_GUI_ST_LabelName(idx);
         string tm=ObjectGetString(0,tn,OBJPROP_TEXT);
         string lb=ObjectGetString(0,ln,OBJPROP_TEXT);

         if(isTime)
         {
            int mins=-1;
            if(RG_ST_ParseTime(tm,mins))
               RG_SpecialTimesSetEvent(idx,RG_SpecialTimesGetEnabled(idx),tm,lb,RG_SpecialTimesGetColor(idx));
            else
               ObjectSetString(0,tn,OBJPROP_TEXT,RG_SpecialTimesGetTime(idx));
         }
         else
         {
            if(StringLen(lb)==0) lb="SPECIAL "+IntegerToString(idx+1);
            RG_SpecialTimesSetEvent(idx,RG_SpecialTimesGetEnabled(idx),tm,lb,RG_SpecialTimesGetColor(idx));
            ObjectSetString(0,ln,OBJPROP_TEXT,lb);
         }

         ObjectSetInteger(0,sparam,OBJPROP_SELECTED,false);
         RG_GUI_UpdateToolsPanel();
         RG_SpecialTimesUpdate();
         ChartRedraw();
         return;
      }
   }

   //=================================================
   // J-03.1 JOURNAL REPORTING
   //=================================================
   if(id==CHARTEVENT_OBJECT_ENDEDIT)
   {
      if(sparam==RG_GUI_JV_REPORT_FROM)
      {
         g_RG_GUI_JournalReportFrom=ObjectGetString(0,sparam,OBJPROP_TEXT);
         return;
      }
      if(sparam==RG_GUI_JV_REPORT_TO)
      {
         g_RG_GUI_JournalReportTo=ObjectGetString(0,sparam,OBJPROP_TEXT);
         return;
      }
   }

   //=================================================
   // CLICK
   //=================================================

   // Some MT4 builds deliver the click on an OBJ_BUTTON as a chart click
   // when the overlay contains native OBJ_EDIT controls.  Keep a coordinate
   // fallback so EXPORT EXCEL cannot become a dead button.
   if(id==CHARTEVENT_CLICK && g_RG_GUI_JournalReportOpen)
   {
      int reportField=0;
      if(RG_JournalReportDateFieldHit((int)lparam,(int)dparam,reportField))
      {
         RG_JournalReportFocusField(reportField);
         return;
      }

      if(RG_JournalReportExportHit((int)lparam,(int)dparam))
      {
         RG_DoJournalExcelExport();
         return;
      }
   }

   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam==RG_GUI_JV_DESC_EDIT)
      {
         ObjectSetInteger(0,sparam,OBJPROP_READONLY,false);
         ObjectSetInteger(0,sparam,OBJPROP_ZORDER,50000);
         ObjectSetInteger(0,sparam,OBJPROP_SELECTED,false);
         g_RG_GUI_JournalDescriptionBuffer=ObjectGetString(0,sparam,OBJPROP_TEXT);
         ChartRedraw();
         return;
      }

      // Journal report date fields use the native MT4 OBJ_EDIT editor.
      // Keep the object selectable/selected so MT4 itself receives keyboard
      // input. The previous version disabled SELECTABLE on click, which
      // prevented normal editing.
      if(sparam==RG_GUI_JV_REPORT_FROM || sparam==RG_GUI_JV_REPORT_TO)
      {
         RG_JournalReportFocusField(sparam==RG_GUI_JV_REPORT_FROM ? 1 : 2);
         return;
      }
      if(sparam==RG_GUI_JV_REPORT && !g_RG_GUI_JournalReportOpen)
      {
         // Open the report as an overlay on the existing Journal tab.
         // Do NOT rebuild the whole panel here: RG_CreatePanel() deletes the
         // object that generated this click and can delay the report until
         // the next chart/tab event.
         g_RG_GUI_JournalSettingsOpen=false;
         g_RG_GUI_JournalReportOpen=true;
         g_RG_GUI_JournalReportFrom=TimeToString(TimeCurrent()-30*86400,TIME_DATE);
         g_RG_GUI_JournalReportTo=TimeToString(TimeCurrent(),TIME_DATE);
         g_RG_GUI_JournalReportEditField=0;
         g_RG_GUI_JournalReportEditFocused=false;
         ChartSetInteger(0,CHART_KEYBOARD_CONTROL,true);
         RG_GUI_CreateJournalReportPanel();
         ChartRedraw();
         return;
      }
      if(sparam==RG_GUI_JV_REPORT_CLOSE)
      {
         g_RG_GUI_JournalReportOpen=false;
         g_RG_GUI_JournalReportEditField=0;
         g_RG_GUI_JournalReportEditFocused=false;
         RG_GUI_DeleteJournalReportObjects();
         ChartRedraw();
         return;
      }
      if(sparam==RG_GUI_JV_REPORT_TODAY)
      {
         g_RG_GUI_JournalReportFrom=TimeToString(TimeCurrent(),TIME_DATE);
         g_RG_GUI_JournalReportTo=g_RG_GUI_JournalReportFrom;
         if(ObjectFind(0,RG_GUI_JV_REPORT_FROM)>=0) ObjectSetString(0,RG_GUI_JV_REPORT_FROM,OBJPROP_TEXT,g_RG_GUI_JournalReportFrom);
         if(ObjectFind(0,RG_GUI_JV_REPORT_TO)>=0) ObjectSetString(0,RG_GUI_JV_REPORT_TO,OBJPROP_TEXT,g_RG_GUI_JournalReportTo);
         ChartRedraw();
         return;
      }
      if(sparam==RG_GUI_JV_REPORT_WEEK)
      {
         datetime now=TimeCurrent();
         int dow=TimeDayOfWeek(now);
         int back=(dow==0 ? 6 : dow-1);
         datetime monday=now-back*86400;
         g_RG_GUI_JournalReportFrom=TimeToString(monday,TIME_DATE);
         g_RG_GUI_JournalReportTo=TimeToString(now,TIME_DATE);
         if(ObjectFind(0,RG_GUI_JV_REPORT_FROM)>=0) ObjectSetString(0,RG_GUI_JV_REPORT_FROM,OBJPROP_TEXT,g_RG_GUI_JournalReportFrom);
         if(ObjectFind(0,RG_GUI_JV_REPORT_TO)>=0) ObjectSetString(0,RG_GUI_JV_REPORT_TO,OBJPROP_TEXT,g_RG_GUI_JournalReportTo);
         ChartRedraw();
         return;
      }
      if(sparam==RG_GUI_JV_REPORT_GEN)
      {
         RG_DoJournalExcelExport();
         return;
      }

      if(sparam==RG_GUI_JV_DESC_SAVE)
      {
         string d=(ObjectFind(0,RG_GUI_JV_DESC_EDIT)>=0 ? ObjectGetString(0,RG_GUI_JV_DESC_EDIT,OBJPROP_TEXT) : g_RG_GUI_JournalDescriptionBuffer);
         RG_JournalSetDescription(g_RG_GUI_JournalDescriptionTicket,d);
         RG_GUI_DeleteJournalDescriptionPanel();
         RG_CreatePanel();
         RG_UpdateGUI();
         ChartRedraw();
         return;
      }
      if(sparam==RG_GUI_JV_DESC_SKIP)
      {
         RG_GUI_DeleteJournalDescriptionPanel();
         RG_CreatePanel();
         RG_UpdateGUI();
         ChartRedraw();
         return;
      }

      if(sparam==RG_GUI_TRADE_TAB)
      {
         g_RG_GUI_ToolsOpen=false;
         g_RG_GUI_JournalTabOpen=false;
         // Persist the selected main tab so a timeframe/symbol chart
         // reinitialization restores TRADE instead of the previous tab.
         RG_GUI_SaveToolsPreferences();
         RG_CreatePanel();
         return;
      }
      if(sparam==RG_GUI_TOOLS_TAB)
      {
         g_RG_GUI_ToolsOpen=true;
         g_RG_GUI_JournalTabOpen=false;
         // Persist the selected main tab so a timeframe/symbol chart
         // reinitialization restores TOOLS when that is the user's choice.
         RG_GUI_SaveToolsPreferences();
         RG_CreatePanel();
         return;
      }
       if(sparam==RG_GUI_JOURNAL_TAB)
       {
          RG_GUI_ToggleJournalTab();
          return;
       }
      //=================================================
      // J-02 REV2 JOURNAL CONTROLS
      //=================================================
      if(sparam==RG_GUI_JV_ADD)
      {
         g_RG_GUI_JournalEditIndex=-1;
         g_RG_GUI_JournalEditType=g_RG_GUI_JournalConfigMode;
         RG_GUI_CreateJournalRenameDialog();
         ChartRedraw();
         return;
      }
      if(sparam==RG_GUI_JV_NAMEEDIT)
      {
         g_RG_GUI_JournalEditFocused=true;
         g_RG_GUI_JournalEditBuffer=ObjectGetString(0,RG_GUI_JV_NAMEEDIT,OBJPROP_TEXT);
         return;
      }
      if(sparam==RG_GUI_JV_CLEAR)
      {
         g_RG_GUI_JournalEditFocused=true;
         g_RG_GUI_JournalEditReplaceFirst=false;
         RG_GUI_JournalSetEditText("");
         return;
      }
      if(sparam==RG_GUI_JV_OK)
      {
         string nm=RG_JournalClean(ObjectGetString(0,RG_GUI_JV_NAMEEDIT,OBJPROP_TEXT));
         if(nm!="")
         {
            if(g_RG_GUI_JournalEditIndex<0)
            {
               if(g_RG_GUI_JournalEditType==0) RG_JournalAddCondition(nm);
               else if(g_RG_GUI_JournalEditType==1) RG_JournalAddPattern(nm);
               else if(g_RG_GUI_JournalEditType==2) RG_JournalAddTrigger(nm);
            }
            else
            {
               if(g_RG_GUI_JournalEditType==0) RG_JournalRenameItem(g_RG_JournalConditions,g_RG_JournalConditionCount,g_RG_GUI_JournalEditIndex,nm);
               else if(g_RG_GUI_JournalEditType==1) RG_JournalRenameItem(g_RG_JournalPatterns,g_RG_JournalPatternCount,g_RG_GUI_JournalEditIndex,nm);
               else if(g_RG_GUI_JournalEditType==2) RG_JournalRenameItem(g_RG_JournalTriggers,g_RG_JournalTriggerCount,g_RG_GUI_JournalEditIndex,nm);
            }
         }
         RG_GUI_JournalRestoreChartObjects();
         ObjectDelete(0,RG_GUI_JV_CFG); ObjectDelete(0,RG_GUI_JV_CFG+"_T"); ObjectDelete(0,RG_GUI_JV_NAMEEDIT); ObjectDelete(0,RG_GUI_JV_OK); ObjectDelete(0,RG_GUI_JV_CANCEL); ObjectDelete(0,RG_GUI_JV_CLEAR);
         g_RG_GUI_JournalEditIndex=-1; g_RG_GUI_JournalEditType=-1; g_RG_GUI_JournalEditFocused=false;
         if(RG_JournalHasPendingSync())
         {
            RG_JournalHandleSettingsSync();
            RG_JournalClearPendingSync();
         }
         RG_CreatePanel();
         ChartRedraw();
         return;
      }
      if(sparam==RG_GUI_JV_CANCEL)
      {
         RG_GUI_JournalRestoreChartObjects();
         ObjectDelete(0,RG_GUI_JV_CFG); ObjectDelete(0,RG_GUI_JV_CFG+"_T"); ObjectDelete(0,RG_GUI_JV_NAMEEDIT); ObjectDelete(0,RG_GUI_JV_OK); ObjectDelete(0,RG_GUI_JV_CANCEL); ObjectDelete(0,RG_GUI_JV_CLEAR);
         g_RG_GUI_JournalEditIndex=-1; g_RG_GUI_JournalEditType=-1; g_RG_GUI_JournalEditFocused=false;
         if(RG_JournalHasPendingSync())
         {
            RG_JournalHandleSettingsSync();
            RG_JournalClearPendingSync();
         }
         ChartRedraw();
         return;
      }
      if(sparam==RG_GUI_JV_ON)
      {
         RG_JournalToggleEnabled();
         RG_CreatePanel();
         return;
      }
      if(sparam==RG_GUI_JV_CFG)
      {
         g_RG_GUI_JournalSettingsOpen=!g_RG_GUI_JournalSettingsOpen;
         RG_UpdateGUI();
         ChartRedraw();
         return;
      }
      if(sparam==RG_GUI_JV_CLOSE)
      {
         g_RG_GUI_JournalSettingsOpen=false;
         RG_UpdateGUI();
         ChartRedraw();
         return;
      }
      // Settings category tabs.
      if(sparam==RG_GUI_JV_MODE+"0" || sparam==RG_GUI_JV_MODE+"1" || sparam==RG_GUI_JV_MODE+"2")
      {
         g_RG_GUI_JournalConfigMode=(int)StringToInteger(StringSubstr(sparam,StringLen(RG_GUI_JV_MODE)));
         g_RG_GUI_JournalConfigPage=0;
         RG_CreatePanel();
         return;
      }
      for(int jei=0;jei<100;jei++)
      {
         if(sparam==RG_GUI_JV_Edit(jei))
         {
            g_RG_GUI_JournalEditIndex=jei;
            g_RG_GUI_JournalEditType=g_RG_GUI_JournalConfigMode;
            RG_GUI_CreateJournalRenameDialog();
            ChartRedraw();
            return;
         }
         if(sparam==RG_GUI_JV_Del(jei))
         {
            if(g_RG_GUI_JournalConfigMode==0 && jei<g_RG_JournalConditionCount) RG_JournalDeleteItem(g_RG_JournalConditions,g_RG_JournalConditionCount,jei);
            else if(g_RG_GUI_JournalConfigMode==1 && jei<g_RG_JournalPatternCount) RG_JournalDeleteItem(g_RG_JournalPatterns,g_RG_JournalPatternCount,jei);
            else if(g_RG_GUI_JournalConfigMode==2 && jei<g_RG_JournalTriggerCount) RG_JournalDeleteItem(g_RG_JournalTriggers,g_RG_JournalTriggerCount,jei);
            RG_CreatePanel();
            return;
         }
      }
      if(sparam==RG_GUI_JV_PREV || sparam==RG_GUI_JV_NEXT)
      {
         int count=(g_RG_GUI_JournalConfigMode==0?g_RG_JournalConditionCount:(g_RG_GUI_JournalConfigMode==1?g_RG_JournalPatternCount:g_RG_JournalTriggerCount));
         int maxPage=(count<=0?0:(count-1)/6);
         if(sparam==RG_GUI_JV_PREV && g_RG_GUI_JournalConfigPage>0) g_RG_GUI_JournalConfigPage--;
         if(sparam==RG_GUI_JV_NEXT && g_RG_GUI_JournalConfigPage<maxPage) g_RG_GUI_JournalConfigPage++;
         RG_CreatePanel();
         return;
      }
      // Small page controls in the preview drawer.
      if(sparam==RG_GUI_JV_PREFIX+"PP" || sparam==RG_GUI_JV_PREFIX+"PN")
      {
         int maxp=(g_RG_JournalPatternCount<=0?0:(g_RG_JournalPatternCount-1)/3);
         if(sparam==RG_GUI_JV_PREFIX+"PP" && g_RG_GUI_JournalPreviewPatPage>0) g_RG_GUI_JournalPreviewPatPage--;
         if(sparam==RG_GUI_JV_PREFIX+"PN" && g_RG_GUI_JournalPreviewPatPage<maxp) g_RG_GUI_JournalPreviewPatPage++;
         RG_GUI_DeleteJournalRev2Objects(); RG_GUI_CreateJournalPreviewPopup(); return;
      }
      if(sparam==RG_GUI_JV_PREFIX+"TPP" || sparam==RG_GUI_JV_PREFIX+"TPN")
      {
         int maxp=(g_RG_JournalTriggerCount<=0?0:(g_RG_JournalTriggerCount-1)/3);
         if(sparam==RG_GUI_JV_PREFIX+"TPP" && g_RG_GUI_JournalPreviewTrgPage>0) g_RG_GUI_JournalPreviewTrgPage--;
         if(sparam==RG_GUI_JV_PREFIX+"TPN" && g_RG_GUI_JournalPreviewTrgPage<maxp) g_RG_GUI_JournalPreviewTrgPage++;
         RG_GUI_DeleteJournalRev2Objects(); RG_GUI_CreateJournalPreviewPopup(); return;
      }
      if(sparam==RG_GUI_JV_PREFIX+"CPP" || sparam==RG_GUI_JV_PREFIX+"CPN")
      {
         int maxp=(g_RG_JournalConditionCount<=0?0:(g_RG_JournalConditionCount-1)/3);
         if(sparam==RG_GUI_JV_PREFIX+"CPP" && g_RG_GUI_JournalPreviewCondPage>0) g_RG_GUI_JournalPreviewCondPage--;
         if(sparam==RG_GUI_JV_PREFIX+"CPN" && g_RG_GUI_JournalPreviewCondPage<maxp) g_RG_GUI_JournalPreviewCondPage++;
         RG_GUI_DeleteJournalRev2Objects(); RG_GUI_CreateJournalPreviewPopup(); return;
      }
      for(int jpi=0;jpi<100;jpi++)
      {
         if(sparam==RG_GUI_JV_Pat(jpi) && jpi<g_RG_JournalPatternCount)
         { RG_JournalTogglePattern(jpi); RG_GUI_RefreshJournalPreviewState(); ChartRedraw(); return; }
         if(sparam==RG_GUI_JV_Trg(jpi) && jpi<g_RG_JournalTriggerCount)
         { RG_JournalToggleTrigger(jpi); RG_GUI_RefreshJournalPreviewState(); ChartRedraw(); return; }
      }
      for(int jti=0;jti<9;jti++)
      {
         if(sparam==RG_GUI_JV_TFItem(jti))
         { RG_JournalToggleTF(jti); RG_GUI_RefreshJournalPreviewState(); ChartRedraw(); return; }
      }
      for(int jci=0;jci<100;jci++)
      {
         if(sparam==RG_GUI_JV_Cond(jci))
         { RG_JournalToggleCondition(jci); RG_GUI_RefreshJournalPreviewState(); ChartRedraw(); return; }
      }
      //=================================================
      // MARKET SESSIONS CONTROLS
      //=================================================
      if(sparam==RG_GUI_SessionControlName("SECTION"))
      {
         RG_GUI_ToggleSessionsSection();
         return;
      }
      if(sparam==RG_GUI_SessionControlName("ON_VALUE"))
      {
         RG_GUI_ToggleSessionsEnabled();
         return;
      }
      if(sparam==RG_GUI_SessionControlName("CURRENT_VALUE"))
      {
         RG_GUI_ToggleSessionsCurrent();
         return;
      }
      if(sparam==RG_GUI_SessionControlName("FUTURE_VALUE"))
      {
         RG_GUI_CycleSessionsFuture();
         return;
      }
      if(sparam==RG_GUI_SessionControlName("LABELS_VALUE"))
      {
         RG_GUI_ToggleSessionsLabels();
         return;
      }

      if(sparam==RG_GUI_ST_SpecialTimesSectionName())
      {
         RG_GUI_ToggleSpecialTimes();
         return;
      }
      //=================================================
      // NEWS CONTROLS
      //=================================================
      if(sparam==RG_GUI_NewsSectionName())
      {
         RG_GUI_ToggleNewsPanel();
         return;
      }
      if(sparam==RG_GUI_JournalSectionName())
      {
         RG_GUI_ToggleJournal();
         return;
      }
      if(sparam==RG_GUI_NewsEnableName())
      {
         RG_GUI_ToggleNews();
         return;
      }
      if(sparam==RG_GUI_NewsCurrencyName())
      {
         RG_GUI_CycleNewsCurrency();
         return;
      }
      if(sparam==RG_GUI_NewsImpactName())
      {
         RG_GUI_CycleNewsImpact();
         return;
      }
      if(sparam==RG_GUI_NewsDoneName())
      {
         RG_GUI_FinishNewsSelector();
         return;
      }
      for(int nci=0;nci<9;nci++)
      {
         if(sparam==RG_GUI_NewsCurrencyItemName(nci))
         {
            RG_GUI_ToggleNewsCurrency(nci);
            return;
         }
      }
      for(int nii=0;nii<4;nii++)
      {
         if(sparam==RG_GUI_NewsImpactItemName(nii))
         {
            RG_GUI_SelectNewsImpact(nii);
            return;
         }
      }
      if(sparam==RG_GUI_ST_DisplayWindowName())
      {
         RG_ST_DisplayWindowMode mode=RG_SpecialTimesGetDisplayWindow();
         mode=(mode==RG_ST_DISPLAY_MAIN_CHART ? RG_ST_DISPLAY_FIRST_INDICATOR : RG_ST_DISPLAY_MAIN_CHART);
         RG_SpecialTimesSetDisplayWindow(mode);
         RG_GUI_UpdateToolsPanel();
         return;
      }
      if(sparam==RG_GUI_ST_LabelModeName())
      {
         RG_ST_LabelDisplayMode mode=RG_SpecialTimesGetLabelMode();
         mode=(mode==RG_ST_LABEL_TIME_AND_LABEL ? RG_ST_LABEL_TIME_ONLY : RG_ST_LABEL_TIME_AND_LABEL);
         RG_SpecialTimesSetLabelMode(mode);
         RG_GUI_UpdateToolsPanel();
         return;
      }

      for(int sti2=0;sti2<10;sti2++)
      {
         if(sparam==RG_GUI_ST_EnableName(sti2))
         {
            RG_SpecialTimesToggleEvent(sti2);
            RG_GUI_UpdateToolsPanel();
            return;
         }
      }
      // Time / Label fields are standard MT4 OBJ_EDIT controls.
      // MT4 handles focus and typing natively; saving occurs on ENDEDIT.
      // PANEL TITLE = collapse / expand the complete panel
      if(sparam==RG_GUI_PANEL_TOGGLE)
      {
         if(RG_GUI_ConsumePanelToggleClick())
            return;

         RG_GUI_TogglePanel();
         return;
      }

      // OPEN POSITIONS = collapse / expand section
      if(sparam==RG_GUI_SECTION_TOGGLE)
      {
         RG_GUI_TogglePositions();
         RG_UpdateGUI();
         RG_UpdateFooter();
         return;
      }

      // BUY = MARKET PREVIEW ONLY
      if(sparam==RG_GUI_BUY)
      {
         RG_ClearPendingMode();

         if(!RG_GUI_CreateRiskPreview(OP_BUY))
         {
            RG_MainStatus("BUY Preview failed - ATR/risk unavailable");
            return;
         }

         RG_MainStatus("BUY Preview - drag Entry / SL / TP then SET");
         RG_JournalBeginPreview(OP_BUY);
         RG_TV_ShowPreview(OP_BUY);
         RG_GUI_UpdateRiskInfo();
         return;
      }

      // SELL = MARKET PREVIEW ONLY
      if(sparam==RG_GUI_SELL)
      {
         RG_ClearPendingMode();

         if(!RG_GUI_CreateRiskPreview(OP_SELL))
         {
            RG_MainStatus("SELL Preview failed - ATR/risk unavailable");
            return;
         }

         RG_MainStatus("SELL Preview - drag Entry / SL / TP then SET");
         RG_JournalBeginPreview(OP_SELL);
         RG_TV_ShowPreview(OP_SELL);
         RG_GUI_UpdateRiskInfo();
         return;
      }

      // PENDING BUY: direction only; STOP/LIMIT is automatic.
      // V2: initial preview is captured from the current Ask exactly once.
      if(sparam==RG_GUI_PENDING_BUY)
      {
         if(!RG_CreatePendingPreview(OP_BUY))
         {
            RG_MainStatus("Pending BUY Preview failed - ATR/risk unavailable");
            return;
         }

         RG_MainStatus("Pending BUY Preview - drag Entry / SL / TP then SET");
         RG_JournalBeginPreview(OP_BUY);
         return;
      }

      // PENDING SELL: direction only; STOP/LIMIT is automatic.
      // V2: initial preview is captured from the current Bid exactly once.
      if(sparam==RG_GUI_PENDING_SELL)
      {
         if(!RG_CreatePendingPreview(OP_SELL))
         {
            RG_MainStatus("Pending SELL Preview failed - ATR/risk unavailable");
            return;
         }

         RG_MainStatus("Pending SELL Preview - drag Entry / SL / TP then SET");
         RG_JournalBeginPreview(OP_SELL);
         return;
      }

      // PRICE / PIPS toggle
      if(sparam==RG_GUI_MODE)
      {
         RG_GUI_ToggleProtectionMode();

         if(RG_RuntimePreviewActive())
         {
            RG_TV_ShowPreview(
               RG_RuntimePreviewDirection()
            );

            RG_MainStatus(
               "Preview mode changed - review then SET"
            );
         }

         return;
      }

      // Risk value minus / plus
      if(sparam==RG_GUI_RISK_MINUS)
      {
         RG_GUI_AdjustRisk(-1);
         if(RG_RuntimePreviewActive())
            RG_TV_ShowPreview(RG_RuntimePreviewDirection());
         RG_MainStatus("Risk decreased");
         return;
      }

      if(sparam==RG_GUI_RISK_PLUS)
      {
         RG_GUI_AdjustRisk(1);
         if(RG_RuntimePreviewActive())
            RG_TV_ShowPreview(RG_RuntimePreviewDirection());
         RG_MainStatus("Risk increased");
         return;
      }

      if(sparam==RG_GUI_RISK_PERCENT)
      {
         RG_GUI_SetRiskMode(RG_RISK_PERCENT);
         if(RG_RuntimePreviewActive())
            RG_TV_ShowPreview(RG_RuntimePreviewDirection());
         RG_MainStatus("Risk mode: %");
         return;
      }

      if(sparam==RG_GUI_RISK_DOLLAR)
      {
         RG_GUI_SetRiskMode(RG_RISK_DOLLAR);
         if(RG_RuntimePreviewActive())
            RG_TV_ShowPreview(RG_RuntimePreviewDirection());
         RG_MainStatus("Risk mode: $");
         return;
      }

      if(sparam==RG_GUI_RISK_LOT)
      {
         RG_GUI_SetRiskMode(RG_RISK_LOT);
         if(RG_RuntimePreviewActive())
            RG_TV_ShowPreview(RG_RuntimePreviewDirection());
         RG_MainStatus("Risk mode: Lot");
         return;
      }

      // CANCEL = clear preview, no order
      if(sparam==RG_GUI_CANCEL)
      {
         RG_JournalEndPreview();
         RG_ClearPendingMode();
         RG_RuntimeClearPreview();
         RG_RuntimeClearPreviewSnapshot();
         RG_ClearMainPreviewState();
         RG_TrailingSetupClose();
         RG_TV_DeleteTradeVisualization();
         RG_GUI_DeleteJournalRev2Objects();
         RG_CreatePanel();

         RG_SetEditText(
            RG_GUI_ENTRY_INPUT,
            ""
         );

         RG_SetEditText(
            RG_GUI_SL_INPUT,
            ""
         );

         RG_SetEditText(
            RG_GUI_TP_INPUT,
            ""
         );

         RG_GUI_UpdateRiskInfo();

         RG_MainStatus(
            "Preview cancelled"
         );

         RG_UpdateGUI();
         RG_UpdateFooter();

         return;
      }

      // SET = EXECUTE SELECTED PREVIEW
      if(sparam==RG_GUI_SET)
      {
         int direction=RG_RuntimePreviewDirection();

         if(direction!=OP_BUY && direction!=OP_SELL)
         {
            RG_MainStatus("SET: select BUY / SELL or PENDING first");
            return;
         }

         RG_MainStatus("SET: validating...");

         if(!RG_GUI_ApplySettings())
         {
            RG_MainStatus("SET failed: check Preview / Risk / ATR");
            return;
         }

         int ticket=-1;

         if(g_RG_PendingPreview &&
            g_RG_PendingDirection==direction)
         {
            double entry=RG_RuntimePreviewEntry();
            double sl=RG_RuntimePreviewSL();
            double tp=RG_RuntimePreviewTP();

            double lot=RG_GUI_CalculateRiskLot(
               direction,entry,sl
            );

            int pendingType=RG_DetectPendingType(
               direction,entry
            );

            if(pendingType<0)
            {
               RG_MainStatus(
                  "Pending SET failed: Entry must be above/below market"
               );
               RG_TV_ShowPreview(direction);
               return;
            }

            if(lot<=0.0)
            {
               RG_MainStatus("Pending SET failed: invalid allowed lot");
               RG_TV_ShowPreview(direction);
               return;
            }

            RG_MainStatus(
               "SET: Sending "+
               RG_PendingTypeName(pendingType)+
               "..."
            );

            ticket=RG_SendPendingOrder(
               Symbol(),
               pendingType,
               lot,
               entry,
               sl,
               tp,
               "RiskGuard Pending"
            );

            if(ticket>0)
            {
               if(RG_JournalEnabled())
               {
                  if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                     RG_JournalAttachEntryMeta(ticket,OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit(),OrderLots());
               }
               RG_GUI_OpenJournalDescription(ticket);
               RG_JournalEndPreview();
               RG_RuntimeClearPreview();
               RG_RuntimeClearPreviewSnapshot();
               RG_ClearMainPreviewState();
               RG_TrailingSetupClose();
   RG_TV_DeleteTradeVisualization();
               RG_ClearPendingMode();

               RG_MainStatus(
                  RG_PendingTypeName(pendingType)+
                  " #"+
                  IntegerToString(ticket)
               );
            }
            else
            {
               RG_MainStatus(
                  "Pending order failed - SET retry available"
               );
               RG_TV_ShowPreview(direction);
            }
         }
         else
         {
            if(direction==OP_BUY)
            {
               RG_MainStatus("SET: Sending BUY...");
               ticket=RG_SendBuyOrder();
            }
            else
            {
               RG_MainStatus("SET: Sending SELL...");
               ticket=RG_SendSellOrder();
            }

            if(ticket>0)
            {
               if(RG_JournalEnabled())
               {
                  if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                     RG_JournalAttachEntryMeta(ticket,OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit(),OrderLots());
               }
               RG_JournalEndPreview();
               RG_RuntimeClearPreview();
               RG_RuntimeClearPreviewSnapshot();
               RG_ClearMainPreviewState();
               RG_TrailingSetupClose();
   RG_TV_DeleteTradeVisualization();
               RG_EnableNativeTradeLevels();
               RG_ClearPendingMode();
               RG_GUI_DeleteJournalRev2Objects();
               RG_CreatePanel();
               RG_GUI_OpenJournalDescription(ticket);

               RG_MainStatus(
                  (direction==OP_BUY ? "BUY Opened #" : "SELL Opened #")+
                  IntegerToString(ticket)
               );
            }
            else
            {
               RG_MainStatus("Order failed - SET retry available");
               RG_TV_ShowPreview(direction);
            }
         }

         RG_ProcessPositionManager();

         if(ticket>0)
            RG_CreatePanel();
         else
         {
            RG_UpdateGUI();
            RG_UpdateFooter();
         }

         return;
      }

      // Position P/L display: toggle dollars <-> percent of account balance.
      if(RG_GUI_IsPositionObject(
         sparam,RG_GUI_POS_PL))
      {
         RG_GUI_TogglePositionPL();
         RG_UpdateGUI();
         RG_UpdateFooter();
         return;
      }

      // Position BE
      if(RG_GUI_IsPositionObject(
         sparam,RG_GUI_POS_BE))
      {
         int ticket=
            RG_GUI_TicketFromPositionObject(
               sparam,RG_GUI_POS_BE
            );

         if(ticket>0)
         {
            if(RG_PanelBreakEvenTicket(ticket))
               RG_MainStatus(
                  "BE applied"
               );
            else
               RG_MainStatus(
                  "BE failed - check position state"
               );
         }

         RG_UpdateGUI();
         RG_UpdateFooter();

         return;
      }

      // Position RiskFree
      if(RG_GUI_IsPositionObject(
         sparam,RG_GUI_POS_RF))
      {
         int ticket=
            RG_GUI_TicketFromPositionObject(
               sparam,RG_GUI_POS_RF
            );

         if(ticket>0)
         {
            if(RG_PanelRiskFreeTicket(ticket))
               RG_MainStatus(
                  "RF applied"
               );
            else
               RG_MainStatus(
                  "RF failed - position/broker distance not valid"
               );
         }

         RG_ProcessPositionManager();
         RG_UpdateGUI();
         RG_UpdateFooter();

         return;
      }

      // Fast partial close: one third of CURRENT lots
      if(RG_GUI_IsPositionObject(
         sparam,RG_GUI_POS_THIRD))
      {
         int ticket=
            RG_GUI_TicketFromPositionObject(
               sparam,RG_GUI_POS_THIRD
            );

         if(ticket>0)
         {
            if(RG_CloseOneThird(ticket))
               RG_MainStatus("1/3 closed");
            else
               RG_MainStatus("1/3 close failed - lot step/min lot");
         }

         RG_ProcessPositionManager();
         RG_UpdateGUI();
         RG_UpdateFooter();
         return;
      }

      // Fast partial close: one half of CURRENT lots
      if(RG_GUI_IsPositionObject(
         sparam,RG_GUI_POS_HALF))
      {
         int ticket=
            RG_GUI_TicketFromPositionObject(
               sparam,RG_GUI_POS_HALF
            );

         if(ticket>0)
         {
            if(RG_CloseHalf(ticket))
               RG_MainStatus("1/2 closed");
            else
               RG_MainStatus("1/2 close failed - lot step/min lot");
         }

         RG_ProcessPositionManager();
         RG_UpdateGUI();
         RG_UpdateFooter();
         return;
      }

      // Position close
      if(RG_GUI_IsPositionObject(
         sparam,RG_GUI_POS_CLOSE))
      {
         int ticket=
            RG_GUI_TicketFromPositionObject(
               sparam,RG_GUI_POS_CLOSE
            );

         if(ticket>0)
         {
            if(RG_ClosePosition(ticket))
               RG_MainStatus(
                  "Position closed"
               );
            else
               RG_MainStatus(
                  "Close failed"
               );
         }

         RG_ProcessPositionManager();
         RG_UpdateGUI();
         RG_UpdateFooter();

         return;
      }

      // Per-position trailing setup
      if(RG_GUI_IsPositionObject(
         sparam,RG_GUI_POS_TRAILING))
      {
         int ticket=
            RG_GUI_TicketFromPositionObject(
               sparam,RG_GUI_POS_TRAILING
            );

         if(ticket>0)
         {
            RG_TrailingSetupOpen(ticket);
            RG_MainStatus("Trailing setup");
         }

         RG_UpdateGUI();
         RG_UpdateFooter();
         ChartRedraw();
         return;
      }

      // Trailing setup window controls
      if(RG_TrailingSetupHandleClick(sparam))
      {
         RG_UpdateGUI();
         RG_UpdateFooter();
         ChartRedraw();
         return;
      }

      // Close all
      if(sparam==RG_GUI_CLOSE)
      {
         RG_MainStatus("Closing all...");

         RG_CloseAll();

         RG_ProcessPositionManager();
         RG_UpdateGUI();
         RG_UpdateFooter();

         RG_MainStatus("Close All complete");

         return;
      }

      // AUTO RISK FREE toggle
      if(sparam==RG_GUI_AUTO_RF)
      {
         RG_GUI_ToggleAutoRiskFree();
         RG_MainStatus(
            RG_AutoRiskFreeEnabled() ?
            "Auto Risk Free ON" :
            "Auto Risk Free OFF"
         );
         RG_UpdateGUI();
         RG_UpdateFooter();
         return;
      }
   }

   if(id==CHARTEVENT_OBJECT_DELETE)
   {
      RG_UpdateGUI();
      RG_UpdateFooter();

      return;
   }
}