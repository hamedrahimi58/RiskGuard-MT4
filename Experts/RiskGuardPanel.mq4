#property strict

//====================================================
// RiskGuard MT4
// Main Expert Advisor
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
#include <GUI/RG_TradeVisualization.mqh>

//====================================================
// Chart state owned by the EA while it is attached
//====================================================

bool   g_RG_OriginalChartShift=false;
double g_RG_OriginalShiftSize=0.0;
bool   g_RG_ChartStateCaptured=false;

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

   if(OrderSymbol()!=Symbol() ||
      OrderMagicNumber()!=MagicNumber)
      return(false);

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return(false);

   RefreshRates();

   double openPrice=
      NormalizeDouble(OrderOpenPrice(),Digits);

   double newSL=openPrice;

   if(OrderType()==OP_BUY)
   {
      if(newSL>=Bid)
         return(false);

      if(OrderStopLoss()>0 &&
         OrderStopLoss()>=newSL)
         return(true);
   }
   else
   {
      if(newSL<=Ask)
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
// Manual RiskFree = Break Even + commission coverage
// Recalculates the target from the ORIGINAL open price every time.
// It intentionally does not depend on the current SL or a "done" flag,
// so RF remains usable after BE or after a manual SL change.
//====================================================
bool RG_PanelRiskFreeTicket(int ticket)
{
   if(ticket<=0)
      return(false);

   if(!OrderSelect(ticket,SELECT_BY_TICKET))
      return(false);

   if(OrderSymbol()!=Symbol() ||
      OrderMagicNumber()!=MagicNumber)
      return(false);

   int type=OrderType();
   if(type!=OP_BUY && type!=OP_SELL)
      return(false);

   RefreshRates();

   double lots=OrderLots();
   if(lots<=0.0)
      return(false);

   double commissionCost=MathAbs(OrderCommission());
   if(commissionCost<=0.0)
   {
      // No commission means commission-neutral RF is exactly BE.
      return(RG_PanelBreakEvenTicket(ticket));
   }

   double tickValue=MarketInfo(OrderSymbol(),MODE_TICKVALUE);
   double tickSize =MarketInfo(OrderSymbol(),MODE_TICKSIZE);
   if(tickValue<=0.0 || tickSize<=0.0)
      return(false);

   // Price distance whose monetary value equals the commission.
   double commissionDistance=
      commissionCost*tickSize/(tickValue*lots);

   double openPrice=OrderOpenPrice();
   double newSL=0.0;
   double stopLevel=MarketInfo(OrderSymbol(),MODE_STOPLEVEL)*Point;

   if(type==OP_BUY)
   {
      newSL=NormalizeDouble(openPrice+commissionDistance,Digits);

      // The stop must be below the current Bid by the broker's minimum distance.
      if(newSL>=Bid-stopLevel)
         return(false);
   }
   else
   {
      newSL=NormalizeDouble(openPrice-commissionDistance,Digits);

      // The stop must be above the current Ask by the broker's minimum distance.
      if(newSL<=Ask+stopLevel)
         return(false);
   }

   ResetLastError();
   bool result=OrderModify(
      ticket,
      OrderOpenPrice(),
      newSL,
      OrderTakeProfit(),
      0,
      clrNONE
   );

   if(!result)
   {
      Print(
         "RiskGuard RF failed. Ticket=",ticket,
         " TargetSL=",DoubleToString(newSL,Digits),
         " Commission=",DoubleToString(commissionCost,2),
         " Error=",GetLastError()
      );
      return(false);
   }

   return(true);
}

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

   RG_RuntimeInit();
   RG_RuntimeClearPreview();
   RG_TV_DeleteTradeVisualization();

   // Remove stale synthetic preview objects from older versions.
   RG_TV_DeleteTradeVisualization();

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
   RG_ProcessPositionManager();
   RG_UpdateGUI();
   RG_UpdateFooter();

   ChartRedraw();

   return(INIT_SUCCEEDED);
}

//====================================================
// DEINIT
//====================================================

void OnDeinit(const int reason)
{
   EventKillTimer();
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,false);

   RG_TV_DeleteTradeVisualization();
   RG_DeletePanel();

   RG_RestoreChartState();
}

//====================================================
// TIMER
//====================================================

void OnTimer()
{
   RG_ProcessPositionManager();

   RG_UpdateGUI();
   RG_UpdateFooter();

   // Only the selected frozen preview is drawn.
   RG_ProcessTradeVisualization();

   ChartRedraw();
}

//====================================================
// TICK
//====================================================

void OnTick()
{
   RefreshRates();

   RG_ProcessPositionManager();

   if(UseRiskFree)
      RG_ProcessRiskFree();

   if(UseTrailing)
      RG_ProcessTrailing();

   RG_UpdateGUI();
   RG_UpdateFooter();

   // Preview values are not recalculated from Ask/Bid.
   RG_ProcessTradeVisualization();

   ChartRedraw();
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
               ObjectSetInteger(0,editNames[ei],OBJPROP_HIDDEN,false);
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

      // BUY = PREVIEW ONLY
      if(sparam==RG_GUI_BUY)
      {
         if(!RG_GUI_CreateRiskPreview(OP_BUY))
         {
            RG_MainStatus("BUY Preview failed - ATR/risk unavailable");
            return;
         }

         RG_MainStatus(
            "BUY Preview - drag Entry / SL / TP then SET"
         );

         RG_TV_ShowPreview(OP_BUY);
         RG_GUI_UpdateRiskInfo();

         return;
      }

      // SELL = PREVIEW ONLY
      if(sparam==RG_GUI_SELL)
      {
         if(!RG_GUI_CreateRiskPreview(OP_SELL))
         {
            RG_MainStatus("SELL Preview failed - ATR/risk unavailable");
            return;
         }

         RG_MainStatus(
            "SELL Preview - drag Entry / SL / TP then SET"
         );

         RG_TV_ShowPreview(OP_SELL);
         RG_GUI_UpdateRiskInfo();

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
         RG_RuntimeClearPreview();
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
         int direction=
            RG_RuntimePreviewDirection();

         if(direction!=OP_BUY &&
            direction!=OP_SELL)
         {
            RG_MainStatus(
               "SET: select BUY or SELL first"
            );

            return;
         }

         RG_MainStatus("SET: validating...");

         if(!RG_GUI_ApplySettings())
         {
            RG_MainStatus(
               "SET failed: check Preview / Risk / ATR"
            );

            return;
         }

         int ticket=-1;

         if(direction==OP_BUY)
         {
            RG_MainStatus(
               "SET: Sending BUY..."
            );

            ticket=RG_SendBuyOrder();
         }
         else
         {
            RG_MainStatus(
               "SET: Sending SELL..."
            );

            ticket=RG_SendSellOrder();
         }

         if(ticket>0)
         {
            RG_RuntimeClearPreview();
            RG_TV_DeleteTradeVisualization();

            RG_EnableNativeTradeLevels();

            RG_MainStatus(
               (direction==OP_BUY ?
                "BUY Opened #" :
                "SELL Opened #")+
               IntegerToString(ticket)
            );
         }
         else
         {
            // Keep preview for retry.
            RG_MainStatus(
               "Order failed - SET retry available"
            );

            RG_TV_ShowPreview(direction);
         }

         RG_ProcessPositionManager();

         // Rebuild once after SET so the newly created position row,
         // market/account card and footer use one fresh geometry model.
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

      // Trailing
      if(sparam==RG_GUI_TRAILING)
      {
         RG_MainStatus("TRAILING...");

         RG_ProcessTrailing();

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
