#property strict

//====================================================
// RiskGuard MT4
// Main Expert Advisor
// Stage 3: Multi-Symbol Positions
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

   EventSetTimer(1);
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);

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

   RG_TrailingSetupClose();
   RG_TV_DeleteTradeVisualization();
   RG_DeletePanel();

   RG_RestoreChartState();
}

//====================================================
// TIMER
//====================================================

void OnTimer()
{
   if(!RG_LicenseIsValid())
   {
      RG_UpdateGUI();
      RG_UpdateFooter();
      RG_LicenseApplyStatus();
      return;
   }

   RG_RuntimeSyncInputDefaults();
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

   if(!RG_LicenseIsValid())
   {
      RG_UpdateGUI();
      RG_UpdateFooter();
      RG_LicenseApplyStatus();
      return;
   }

   RG_RuntimeSyncInputDefaults();
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

//====================================================
// CHART EVENT
//====================================================

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

         RG_UpdateGUI();
         RG_UpdateFooter();
         ChartRedraw();
         return;
      }
   }

   //=================================================
   // CLICK
   //=================================================

   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      // Focus exactly one editable OBJ_EDIT control.
      // OBJPROP_SELECTED is used only for the clicked edit control.
      if(
         sparam==RG_GUI_ENTRY_INPUT ||
         sparam==RG_GUI_SL_INPUT ||
         sparam==RG_GUI_TP_INPUT ||
         sparam==RG_GUI_LOT_INPUT
      )
      {
         string editNames[4];
         editNames[0]=RG_GUI_ENTRY_INPUT;
         editNames[1]=RG_GUI_LOT_INPUT;
         editNames[2]=RG_GUI_SL_INPUT;
         editNames[3]=RG_GUI_TP_INPUT;

         for(int ei=0;ei<4;ei++)
         {
            if(ObjectFind(0,editNames[ei])>=0)
            {
               ObjectSetInteger(0,editNames[ei],OBJPROP_READONLY,false);
               ObjectSetInteger(0,editNames[ei],OBJPROP_SELECTABLE,true);
               ObjectSetInteger(0,editNames[ei],OBJPROP_HIDDEN,true);
               ObjectSetInteger(0,editNames[ei],OBJPROP_ZORDER,60000);
               ObjectSetInteger(0,editNames[ei],OBJPROP_SELECTED,
                                editNames[ei]==sparam);
            }
         }

         ChartRedraw();
         return;
      }

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
         RG_ClearPendingMode();
         RG_RuntimeClearPreview();
         RG_RuntimeClearPreviewSnapshot();
         RG_ClearMainPreviewState();
         RG_TrailingSetupClose();
   RG_TV_DeleteTradeVisualization();

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
               RG_RuntimeClearPreview();
               RG_RuntimeClearPreviewSnapshot();
               RG_ClearMainPreviewState();
               RG_TrailingSetupClose();
   RG_TV_DeleteTradeVisualization();
               RG_EnableNativeTradeLevels();
               RG_ClearPendingMode();

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