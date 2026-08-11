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

   if(UseTakeProfit)
      RG_ProcessTakeProfits();

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
   // CLICK
   //=================================================

   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      // PANEL TITLE = collapse / expand the complete panel
      if(sparam==RG_GUI_PANEL_TOGGLE)
      {
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
         RG_RuntimeSetPreviewDirection(OP_BUY);
         RG_GUI_SetPreviewPriceFields(OP_BUY);

         RG_MainStatus(
            "BUY Preview - edit values then SET"
         );

         RG_TV_ShowPreview(OP_BUY);
         RG_GUI_UpdateRiskInfo();

         return;
      }

      // SELL = PREVIEW ONLY
      if(sparam==RG_GUI_SELL)
      {
         RG_RuntimeSetPreviewDirection(OP_SELL);
         RG_GUI_SetPreviewPriceFields(OP_SELL);

         RG_MainStatus(
            "SELL Preview - edit values then SET"
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
               "SET failed: check Entry / SL / TP / Lot"
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
            if(RG_ApplyManualRiskFree(ticket))
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

   //=================================================
   // EDIT FINISHED
   //=================================================

   if(id==CHARTEVENT_OBJECT_ENDEDIT)
   {
      if(
         sparam==RG_GUI_LOT_INPUT ||
         sparam==RG_GUI_ENTRY_INPUT ||
         sparam==RG_GUI_SL_INPUT ||
         sparam==RG_GUI_TP_INPUT
      )
      {
         if(RG_RuntimePreviewActive())
         {
            if(RG_GUI_SyncPreviewFromFields())
            {
               RG_TV_ShowPreview(
                  RG_RuntimePreviewDirection()
               );

               RG_GUI_UpdateRiskInfo();

               RG_MainStatus(
                  "Values changed - review then SET"
               );
            }
            else
            {
               RG_MainStatus(
                  "Invalid preview values"
               );
            }
         }

         return;
      }
   }

   //=================================================
   // Native MT4 trade-level drag
   //
   // No custom TP/SL drag handling.
   // Native MT4 owns live order level movement.
   //=================================================

   if(id==CHARTEVENT_OBJECT_DRAG)
   {
      RG_UpdateGUI();
      RG_UpdateFooter();

      return;
   }

   if(id==CHARTEVENT_OBJECT_DELETE)
   {
      RG_UpdateGUI();
      RG_UpdateFooter();

      return;
   }
}
