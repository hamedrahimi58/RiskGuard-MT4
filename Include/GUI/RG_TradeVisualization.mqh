#ifndef __RG_TRADE_VISUALIZATION_MQH__
#define __RG_TRADE_VISUALIZATION_MQH__

#include <RG_Settings.mqh>
#include <RG_Runtime.mqh>
#include <GUI/RG_Edit.mqh>

//====================================================
// RiskGuard MT4
// PRE-TRADE PREVIEW ONLY
//
// BUY / SELL creates one frozen preview.
// SET clears it after successful market execution.
// CANCEL clears it without trading.
//
// This module never writes broker SL / TP levels.
// Native MT4 trade levels own the live position.
//====================================================

#define RG_TV_PREFIX "RGTV_"
#define RG_TV_FONT   "Arial"

#define RG_TV_BUY_ENTRY  RG_TV_PREFIX+"PREVIEW_BUY_ENTRY"
#define RG_TV_BUY_SL     RG_TV_PREFIX+"PREVIEW_BUY_SL"
#define RG_TV_BUY_TP     RG_TV_PREFIX+"PREVIEW_BUY_TP"

#define RG_TV_SELL_ENTRY RG_TV_PREFIX+"PREVIEW_SELL_ENTRY"
#define RG_TV_SELL_SL    RG_TV_PREFIX+"PREVIEW_SELL_SL"
#define RG_TV_SELL_TP    RG_TV_PREFIX+"PREVIEW_SELL_TP"

#define RG_TV_BUY_ENTRY_LABEL  RG_TV_PREFIX+"LABEL_BUY_ENTRY"
#define RG_TV_BUY_SL_LABEL     RG_TV_PREFIX+"LABEL_BUY_SL"
#define RG_TV_BUY_TP_LABEL     RG_TV_PREFIX+"LABEL_BUY_TP"

#define RG_TV_SELL_ENTRY_LABEL RG_TV_PREFIX+"LABEL_SELL_ENTRY"
#define RG_TV_SELL_SL_LABEL    RG_TV_PREFIX+"LABEL_SELL_SL"
#define RG_TV_SELL_TP_LABEL    RG_TV_PREFIX+"LABEL_SELL_TP"

#define RG_TV_DECISION_LABEL   RG_TV_PREFIX+"DECISION"

int    g_RG_TV_LastDirection=-1;
double g_RG_TV_LastEntry=0.0;
double g_RG_TV_LastSL=0.0;
double g_RG_TV_LastTP=0.0;

//====================================================
// Delete
//====================================================

void RG_TV_DeleteObject(string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);
}

void RG_TV_DeleteTradeVisualization()
{
   for(int i=ObjectsTotal()-1;i>=0;i--)
   {
      string name=ObjectName(i);

      if(StringFind(name,RG_TV_PREFIX,0)==0)
         ObjectDelete(0,name);
   }

   g_RG_TV_LastDirection=-1;
   g_RG_TV_LastEntry=0.0;
   g_RG_TV_LastSL=0.0;
   g_RG_TV_LastTP=0.0;

   ChartRedraw();
}

//====================================================
// Preview line
//====================================================

bool RG_TV_CreateLine(
   string name,
   double price,
   color lineColor,
   ENUM_LINE_STYLE lineStyle)
{
   if(price<=0)
      return(false);

   datetime t=TimeCurrent();

   if(t<=0)
      t=TimeLocal();

   datetime t2=
      t+PeriodSeconds()*20;

   if(t2<=t)
      t2=t+3600;

   if(ObjectFind(0,name)<0)
   {
      if(!ObjectCreate(
         0,name,OBJ_TREND,0,
         t,price,t2,price))
         return(false);
   }
   else
   {
      ObjectMove(0,name,0,t,price);
      ObjectMove(0,name,1,t2,price);
   }

   ObjectSetInteger(0,name,OBJPROP_COLOR,lineColor);
   ObjectSetInteger(0,name,OBJPROP_STYLE,lineStyle);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,true);

   // Preview is visual only and is not selectable.
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);

   return(true);
}

//====================================================
// Preview text
//====================================================

bool RG_TV_CreateText(
   string name,
   string text,
   double price,
   color textColor)
{
   datetime t=TimeCurrent();

   if(t<=0)
      t=TimeLocal();

   if(ObjectFind(0,name)<0)
   {
      if(!ObjectCreate(
         0,name,OBJ_TEXT,0,t,price))
         return(false);
   }
   else
   {
      ObjectMove(0,name,0,t,price);
   }

   ObjectSetString(
      0,name,OBJPROP_TEXT,text);

   ObjectSetString(
      0,name,OBJPROP_FONT,RG_TV_FONT);

   ObjectSetInteger(
      0,name,OBJPROP_FONTSIZE,8);

   ObjectSetInteger(
      0,name,OBJPROP_COLOR,textColor);

   ObjectSetInteger(
      0,name,OBJPROP_ANCHOR,ANCHOR_LEFT);

   ObjectSetInteger(
      0,name,OBJPROP_SELECTABLE,false);

   ObjectSetInteger(
      0,name,OBJPROP_SELECTED,false);

   ObjectSetInteger(
      0,name,OBJPROP_HIDDEN,true);

   ObjectSetInteger(
      0,name,OBJPROP_BACK,true);

   return(true);
}

//====================================================
// Draw ONE selected preview
//====================================================

void RG_TV_DrawPreviewSet(
   string prefix,
   double entry,
   double sl,
   double tp,
   string side)
{
   if(entry<=0)
      return;

   int digits=
      (int)MarketInfo(Symbol(),MODE_DIGITS);

   entry=NormalizeDouble(entry,digits);

   if(sl>0)
      sl=NormalizeDouble(sl,digits);

   if(tp>0)
      tp=NormalizeDouble(tp,digits);

   string e=prefix+"_ENTRY";
   string s=prefix+"_SL";
   string t=prefix+"_TP";

   string el=e+"_LABEL";
   string sln=s+"_LABEL";
   string tl=t+"_LABEL";

   RG_TV_CreateLine(
      e,entry,clrWhite,STYLE_DOT);

   RG_TV_CreateText(
      el,
      side+" ENTRY "+DoubleToString(entry,digits),
      entry,
      clrWhite
   );

   if(sl>0)
   {
      RG_TV_CreateLine(
         s,sl,clrTomato,STYLE_DASH);

      RG_TV_CreateText(
         sln,
         side+" SL "+DoubleToString(sl,digits),
         sl,
         clrTomato
      );
   }
   else
   {
      RG_TV_DeleteObject(s);
      RG_TV_DeleteObject(sln);
   }

   if(tp>0)
   {
      RG_TV_CreateLine(
         t,tp,clrLime,STYLE_DASH);

      RG_TV_CreateText(
         tl,
         side+" TP "+DoubleToString(tp,digits),
         tp,
         clrLime
      );
   }
   else
   {
      RG_TV_DeleteObject(t);
      RG_TV_DeleteObject(tl);
   }
}

double RG_TV_DollarPerPoint(double lot)
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

void RG_TV_DrawDecision(
   double entry,
   double sl,
   double tp,
   double lot,
   int direction,
   int digits)
{
   RG_TV_DeleteObject(RG_TV_DECISION_LABEL);

   if(entry<=0 ||
      lot<=0)
      return;

   double dpp=
      RG_TV_DollarPerPoint(lot);

   if(dpp<=0)
      return;

   double risk=0.0;
   double reward=0.0;

   if(UseStopLoss && sl>0)
      risk=
         MathAbs(entry-sl)/Point*dpp;

   if(UseTakeProfit && tp>0)
      reward=
         MathAbs(tp-entry)/Point*dpp;

   string text=
      (direction==OP_BUY?"BUY":"SELL")+
      "  Risk $"+
      DoubleToString(risk,2)+
      "  Reward $"+
      DoubleToString(reward,2);

   if(risk>0 && reward>0)
   {
      double rr=reward/risk;

      text+=
         "  R:R 1:"+
         DoubleToString(rr,2);
   }

   double decisionPrice=entry;

   if(sl>0 && tp>0)
      decisionPrice=(sl+tp)/2.0;
   else
   if(sl>0)
      decisionPrice=sl;
   else
   if(tp>0)
      decisionPrice=tp;

   RG_TV_CreateText(
      RG_TV_DECISION_LABEL,
      text,
      decisionPrice,
      clrGold
   );
}

//====================================================
// Check whether redraw is actually required
//====================================================

bool RG_TV_ObjectsExist(int direction)
{
   if(direction==OP_BUY)
   {
      return(
         ObjectFind(0,RG_TV_BUY_ENTRY)>=0 &&
         ObjectFind(0,RG_TV_BUY_ENTRY_LABEL)>=0
      );
   }

   if(direction==OP_SELL)
   {
      return(
         ObjectFind(0,RG_TV_SELL_ENTRY)>=0 &&
         ObjectFind(0,RG_TV_SELL_ENTRY_LABEL)>=0
      );
   }

   return(false);
}

//====================================================
// Show selected preview
//
// IMPORTANT:
// No RefreshRates() and no current Ask/Bid calculation.
// Preview prices come exclusively from Runtime snapshot.
//====================================================

void RG_TV_ShowPreview(int direction)
{
   if(!RG_RuntimePreviewActive())
   {
      RG_TV_DeleteTradeVisualization();
      return;
   }

   if(direction!=OP_BUY &&
      direction!=OP_SELL)
   {
      RG_TV_DeleteTradeVisualization();
      return;
   }

   double entry=
      RG_RuntimePreviewEntry();

   double sl=
      RG_RuntimePreviewSL();

   double tp=
      RG_RuntimePreviewTP();

   if(entry<=0)
      return;

   if(direction==g_RG_TV_LastDirection &&
      MathAbs(entry-g_RG_TV_LastEntry)<Point/2.0 &&
      MathAbs(sl-g_RG_TV_LastSL)<Point/2.0 &&
      MathAbs(tp-g_RG_TV_LastTP)<Point/2.0 &&
      RG_TV_ObjectsExist(direction))
   {
      return;
   }

   RG_TV_DeleteTradeVisualization();

   if(direction==OP_BUY)
   {
      RG_TV_DrawPreviewSet(
         RG_TV_PREFIX+"BUY",
         entry,sl,tp,"BUY"
      );
   }
   else
   {
      RG_TV_DrawPreviewSet(
         RG_TV_PREFIX+"SELL",
         entry,sl,tp,"SELL"
      );
   }

   double lots=
      StrToDouble(
         RG_GetEditText("RG_LOT_INPUT")
      );

   if(lots<=0)
      lots=RG_RuntimeFixedLot();

   int digits=
      (int)MarketInfo(Symbol(),MODE_DIGITS);

   RG_TV_DrawDecision(
      entry,sl,tp,lots,
      direction,digits
   );

   g_RG_TV_LastDirection=direction;
   g_RG_TV_LastEntry=entry;
   g_RG_TV_LastSL=sl;
   g_RG_TV_LastTP=tp;

   ChartRedraw();
}

//====================================================
// Tick / timer compatibility
//====================================================

void RG_ProcessTradeVisualization()
{
   if(!RG_RuntimePreviewActive())
   {
      if(g_RG_TV_LastDirection!=-1)
         RG_TV_DeleteTradeVisualization();

      return;
   }

   int direction=
      RG_RuntimePreviewDirection();

   if(direction!=OP_BUY &&
      direction!=OP_SELL)
   {
      RG_TV_DeleteTradeVisualization();
      return;
   }

   // Rendering is based on frozen Runtime values.
   RG_TV_ShowPreview(direction);
}

// No custom TP / SL drag.
// Native MT4 owns live order level movement.
bool RG_TV_HandleTPDrag(string objectName)
{
   return(false);
}

#endif
