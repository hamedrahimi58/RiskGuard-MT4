#ifndef __RG_TRADE_VISUALIZATION_MQH__
#define __RG_TRADE_VISUALIZATION_MQH__

#include <RG_Settings.mqh>
#include <RG_Runtime.mqh>
#include <GUI/RG_Edit.mqh>
#include <Trade/RG_PositionSizer.mqh>

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
#define RG_TV_FONT   "Times New Roman"

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
#define RG_TV_BUY_RISK_ZONE     RG_TV_PREFIX+"BUY_RISK_ZONE"
#define RG_TV_BUY_REWARD_ZONE   RG_TV_PREFIX+"BUY_REWARD_ZONE"
#define RG_TV_SELL_RISK_ZONE    RG_TV_PREFIX+"SELL_RISK_ZONE"
#define RG_TV_SELL_REWARD_ZONE  RG_TV_PREFIX+"SELL_REWARD_ZONE"

// Soft, eye-friendly preview zone colors.
#define RG_TV_RISK_ZONE_COLOR   C'145,62,62'
#define RG_TV_REWARD_ZONE_COLOR C'72,132,91'
#define RG_TV_ZONE_BARS         36
#define RG_TV_GRADIENT_STEPS    12

int    g_RG_TV_LastDirection=-1;
bool   g_RG_TV_PendingPreview=false;
double g_RG_TV_LastEntry=0.0;
double g_RG_TV_LastSL=0.0;
double g_RG_TV_LastTP=0.0;

// Pending Preview V2 snapshot: captured once when the Pending action is
// pressed. These values are never refreshed by ticks.
double g_RG_TV_PendingBidSnapshot=0.0;
double g_RG_TV_PendingAskSnapshot=0.0;

int RG_TV_GetPendingTypeFromSnapshot(int direction,double entry)
{
   if(direction==OP_BUY)
   {
      if(g_RG_TV_PendingAskSnapshot>0.0)
      {
         if(entry>g_RG_TV_PendingAskSnapshot) return(OP_BUYSTOP);
         if(entry<g_RG_TV_PendingAskSnapshot) return(OP_BUYLIMIT);
      }
   }
   else if(direction==OP_SELL)
   {
      if(g_RG_TV_PendingBidSnapshot>0.0)
      {
         if(entry<g_RG_TV_PendingBidSnapshot) return(OP_SELLSTOP);
         if(entry>g_RG_TV_PendingBidSnapshot) return(OP_SELLLIMIT);
      }
   }

   return(-1);
}

void RG_TV_CapturePendingMarketSnapshot()
{
   g_RG_TV_PendingBidSnapshot=MarketInfo(Symbol(),MODE_BID);
   g_RG_TV_PendingAskSnapshot=MarketInfo(Symbol(),MODE_ASK);
}


void RG_TV_SetPendingMarketSnapshot(double bid,double ask)
{
   g_RG_TV_PendingBidSnapshot=bid;
   g_RG_TV_PendingAskSnapshot=ask;
}

double RG_TV_PendingBidSnapshot()
{
   return(g_RG_TV_PendingBidSnapshot);
}

double RG_TV_PendingAskSnapshot()
{
   return(g_RG_TV_PendingAskSnapshot);
}

//====================================================
// Pending preview mode
//====================================================

void RG_TV_SetPendingPreview(bool enabled)
{
   g_RG_TV_PendingPreview=enabled;
}

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
   g_RG_TV_PendingPreview=false;
   g_RG_TV_LastEntry=0.0;
   g_RG_TV_LastSL=0.0;
   g_RG_TV_LastTP=0.0;

   ChartRedraw();
}

//====================================================
// Invisible draggable price handle
//====================================================

bool RG_TV_CreateLine(
   string name,
   double price,
   color lineColor,
   ENUM_LINE_STYLE lineStyle)
{
   if(price<=0)
      return(false);

   // Use OBJ_HLINE intentionally.
   // MQL4 provides native mouse movement for HLINE objects when
   // OBJPROP_SELECTABLE is enabled. This avoids the two-anchor
   // ambiguity of OBJ_TREND for a price-only Entry/SL/TP line.

   if(ObjectFind(0,name)<0)
   {
      if(!ObjectCreate(
         0,name,OBJ_HLINE,0,0,price))
         return(false);
   }
   else
   {
      if(!ObjectMove(
         0,name,0,0,price))
         return(false);
   }

   ObjectSetInteger(0,name,OBJPROP_COLOR,lineColor);
   ObjectSetInteger(0,name,OBJPROP_STYLE,lineStyle);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);

   // Foreground + selectable = mouse-draggable.
   ObjectSetInteger(0,name,OBJPROP_BACK,false);

   // IMPORTANT:
   // MQL4's official HLINE example enables BOTH properties:
   // SELECTABLE=true and SELECTED=true.
   // SELECTABLE makes the object movable; SELECTED makes it
   // immediately highlighted/eligible for mouse movement.
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,true);

   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,65000);

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
   datetime labelTime=TimeCurrent();
   if(labelTime<=0)
      labelTime=TimeLocal();

   int sec=PeriodSeconds();
   if(sec<=0)
      sec=60;

   // Put labels a few bars to the right of the current bar.
   labelTime += sec*3;

   if(ObjectFind(0,name)<0)
   {
      if(!ObjectCreate(
         0,name,OBJ_TEXT,0,labelTime,price))
         return(false);
   }
   else
   {
      ObjectMove(0,name,0,labelTime,price);
   }

   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,RG_TV_FONT);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT);

   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);

   return(true);
}

color RG_TV_MixColor(
   color fromColor,
   color toColor,
   double amount)
{
   if(amount<0.0) amount=0.0;
   if(amount>1.0) amount=1.0;

   int c1=(int)fromColor;
   int c2=(int)toColor;

   int r1=c1 & 0xFF;
   int g1=(c1 >> 8) & 0xFF;
   int b1=(c1 >> 16) & 0xFF;

   int r2=c2 & 0xFF;
   int g2=(c2 >> 8) & 0xFF;
   int b2=(c2 >> 16) & 0xFF;

   int r=(int)MathRound(r1+(r2-r1)*amount);
   int g=(int)MathRound(g1+(g2-g1)*amount);
   int b=(int)MathRound(b1+(b2-b1)*amount);

   return((color)(r | (g << 8) | (b << 16)));
}

bool RG_TV_CreateZone(
   string name,
   double price1,
   double price2,
   color zoneColor)
{
   if(price1<=0.0 || price2<=0.0)
      return(false);

   double top=MathMax(price1,price2);
   double bottom=MathMin(price1,price2);

   datetime t1=iTime(Symbol(),Period(),0);
   if(t1<=0)
      t1=TimeCurrent();

   int sec=PeriodSeconds();
   if(sec<=0)
      sec=60;

   // V13: twice the V12 width.
   datetime t2=t1+(sec*RG_TV_ZONE_BARS);

   // A subtle left-to-right gradient:
   // slightly stronger near the market/entry side and softer toward
   // the right edge. Each strip is a normal filled MT4 rectangle.
   color edgeColor;

   int base=(int)zoneColor;
   int br=base & 0xFF;
   int bg=(base >> 8) & 0xFF;
   int bb=(base >> 16) & 0xFF;

   // Blend toward black only mildly so the gradient remains soft.
   edgeColor=(color)(
      (int)MathRound(br*0.62) |
      ((int)MathRound(bg*0.62) << 8) |
      ((int)MathRound(bb*0.62) << 16)
   );

   for(int i=0;i<RG_TV_GRADIENT_STEPS;i++)
   {
      string partName=
         name+"_G"+IntegerToString(i);

      double a0=(double)i/RG_TV_GRADIENT_STEPS;
      double a1=(double)(i+1)/RG_TV_GRADIENT_STEPS;

      datetime x0=
         t1+(int)MathRound((t2-t1)*a0);

      datetime x1=
         t1+(int)MathRound((t2-t1)*a1);

      if(ObjectFind(0,partName)<0)
      {
         if(!ObjectCreate(
            0,partName,OBJ_RECTANGLE,0,
            x0,top,
            x1,bottom))
            continue;
      }
      else
      {
         ObjectMove(0,partName,0,x0,top);
         ObjectMove(0,partName,1,x1,bottom);
      }

      // Slightly darker on the left, softer on the right.
      double mix=0.20+(0.55*a0);

      color c=RG_TV_MixColor(
         edgeColor,
         zoneColor,
         mix
      );

      ObjectSetInteger(0,partName,OBJPROP_COLOR,c);
      ObjectSetInteger(0,partName,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,partName,OBJPROP_WIDTH,1);
      ObjectSetInteger(0,partName,OBJPROP_FILL,true);
      ObjectSetInteger(0,partName,OBJPROP_BACK,true);
      ObjectSetInteger(0,partName,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,partName,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,partName,OBJPROP_HIDDEN,true);
   }

   return(true);
}

//====================================================
// Zone information labels
//====================================================

bool RG_TV_CreateZoneText(
   string name,
   string text,
   double price,
   color textColor)
{
   datetime t1=iTime(Symbol(),Period(),0);
   if(t1<=0)
      t1=TimeCurrent();

   int sec=PeriodSeconds();
   if(sec<=0)
      sec=60;

   // Shift the zone information slightly to the right so the full
   // text remains comfortably inside the wide gradient zone.
   datetime labelTime=t1+(sec*12);

   if(ObjectFind(0,name)<0)
   {
      if(!ObjectCreate(
         0,name,OBJ_TEXT,0,
         labelTime,price))
         return(false);
   }
   else
   {
      ObjectMove(0,name,0,labelTime,price);
   }

   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,RG_TV_FONT);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,9);
   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_CENTER);

   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);

   return(true);
}

void RG_TV_DrawZones(
   string side,
   double entry,
   double sl,
   double tp,
   double risk,
   double reward,
   double rr,
   int digits)
{
   string riskName;
   string rewardName;
   string riskInfoName;
   string rewardInfoName;

   if(side=="BUY")
   {
      riskName=RG_TV_BUY_RISK_ZONE;
      rewardName=RG_TV_BUY_REWARD_ZONE;
   }
   else
   {
      riskName=RG_TV_SELL_RISK_ZONE;
      rewardName=RG_TV_SELL_REWARD_ZONE;
   }

   riskInfoName=riskName+"_INFO";
   rewardInfoName=rewardName+"_INFO";

   // Risk zone: Entry <-> SL.
   if(sl>0.0)
   {
      RG_TV_CreateZone(
         riskName,
         entry,
         sl,
         RG_TV_RISK_ZONE_COLOR
      );

      // Keep SL information comfortably inside the lower part of the risk zone.
      double riskInfoPrice=sl+(entry-sl)*0.28;

      RG_TV_CreateZoneText(
         riskInfoName,
         "SL  "+DoubleToString(sl,digits)+
         "   "+DoubleToString(risk,2)+"$",
         riskInfoPrice,
         clrWhite
      );
   }
   else
   {
      RG_TV_DeleteObject(riskName);
      RG_TV_DeleteObject(riskInfoName);
   }

   // Reward zone: Entry <-> TP.
   if(tp>0.0)
   {
      RG_TV_CreateZone(
         rewardName,
         entry,
         tp,
         RG_TV_REWARD_ZONE_COLOR
      );

      // Keep TP information comfortably inside the upper part of the reward zone.
      double rewardInfoPrice=entry+(tp-entry)*0.78;

      RG_TV_CreateZoneText(
         rewardInfoName,
         "TP  "+DoubleToString(tp,digits)+
         "   "+DoubleToString(reward,2)+"$",
         rewardInfoPrice,
         clrWhite
      );
   }
   else
   {
      RG_TV_DeleteObject(rewardName);
      RG_TV_DeleteObject(rewardInfoName);
   }
}

void RG_TV_DrawZones(
   string side,
   double entry,
   double sl,
   double tp)
{
   string riskName;
   string rewardName;

   if(side=="BUY")
   {
      riskName=RG_TV_BUY_RISK_ZONE;
      rewardName=RG_TV_BUY_REWARD_ZONE;
   }
   else
   {
      riskName=RG_TV_SELL_RISK_ZONE;
      rewardName=RG_TV_SELL_REWARD_ZONE;
   }

   // Risk zone: Entry <-> SL.
   if(sl>0.0)
      RG_TV_CreateZone(
         riskName,
         entry,
         sl,
         RG_TV_RISK_ZONE_COLOR
      );
   else
      RG_TV_DeleteObject(riskName);

   // Reward zone: Entry <-> TP.
   if(tp>0.0)
      RG_TV_CreateZone(
         rewardName,
         entry,
         tp,
         RG_TV_REWARD_ZONE_COLOR
      );
   else
      RG_TV_DeleteObject(rewardName);
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

   // Use the canonical object names that the drag handler checks.
   string e;
   string s;
   string t;

   string el;
   string sln;
   string tl;

   if(side=="BUY")
   {
      e=RG_TV_BUY_ENTRY;
      s=RG_TV_BUY_SL;
      t=RG_TV_BUY_TP;

      el=RG_TV_BUY_ENTRY_LABEL;
      sln=RG_TV_BUY_SL_LABEL;
      tl=RG_TV_BUY_TP_LABEL;
   }
   else
   {
      e=RG_TV_SELL_ENTRY;
      s=RG_TV_SELL_SL;
      t=RG_TV_SELL_TP;

      el=RG_TV_SELL_ENTRY_LABEL;
      sln=RG_TV_SELL_SL_LABEL;
      tl=RG_TV_SELL_TP_LABEL;
   }

   RG_TV_CreateLine(
      e,entry,clrNONE,STYLE_SOLID);

   if(sl>0)
   {
      RG_TV_CreateLine(
         s,sl,clrNONE,STYLE_SOLID);

   }
   else
   {
      RG_TV_DeleteObject(s);
      RG_TV_DeleteObject(sln);
   }

   if(tp>0)
   {
      RG_TV_CreateLine(
         t,tp,clrNONE,STYLE_SOLID);

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
   RG_TV_DeleteObject(RG_TV_PREFIX+"RISK_INFO");
   RG_TV_DeleteObject(RG_TV_PREFIX+"REWARD_INFO");
   RG_TV_DeleteObject(RG_TV_PREFIX+"ENTRY_INFO");

   if(entry<=0.0 || lot<=0.0)
      return;

   double dpp=RG_TV_DollarPerPoint(lot);

   if(dpp<=0.0)
      return;

   double risk=0.0;
   double reward=0.0;

   if(RG_RuntimeUseStopLoss() && sl>0.0)
      risk=MathAbs(entry-sl)/Point*dpp;

   if(RG_RuntimeUseTakeProfit() && tp>0.0)
      reward=MathAbs(tp-entry)/Point*dpp;

   double rr=0.0;

   if(risk>0.0 && reward>0.0)
      rr=reward/risk;

   string side=(direction==OP_BUY ? "BUY" : "SELL");

   // Entry is a line only: no Entry zone.
   // Its label stays attached to the Entry line.
   string entryText=
      "ENTRY  "+DoubleToString(entry,digits);

   if(g_RG_TV_PendingPreview)
   {
      // Pending Preview V2:
      // The preview is frozen at the market price captured when the
      // Pending button was pressed. Live ticks must NOT move or rewrite
      // the initial preview. The pending type is therefore also based on
      // the captured market reference until the trader drags Entry.
      int pendingType=RG_TV_GetPendingTypeFromSnapshot(direction,entry);

      if(pendingType==OP_BUYSTOP) entryText="BUY STOP  "+DoubleToString(entry,digits);
      else if(pendingType==OP_BUYLIMIT) entryText="BUY LIMIT  "+DoubleToString(entry,digits);
      else if(pendingType==OP_SELLSTOP) entryText="SELL STOP  "+DoubleToString(entry,digits);
      else if(pendingType==OP_SELLLIMIT) entryText="SELL LIMIT  "+DoubleToString(entry,digits);
      else entryText="PENDING  "+DoubleToString(entry,digits);
   }

   if(rr>0.0)
      entryText+="   R:R 1:"+DoubleToString(rr,2);

   // Entry remains a line only. Put its text just inside the reward area.
   double entryInfoPrice=entry;
   if(tp>entry)
      entryInfoPrice=entry+(tp-entry)*0.045;
   else if(sl>0.0 && entry>sl)
      entryInfoPrice=entry-(entry-sl)*0.045;

   RG_TV_CreateZoneText(
      RG_TV_PREFIX+"ENTRY_INFO",
      entryText,
      entryInfoPrice,
      clrWhite
   );

   // Two colored zones only: Risk and Reward.
   RG_TV_DrawZones(
      side,
      entry,
      sl,
      tp,
      risk,
      reward,
      rr,
      digits
   );
}

//====================================================
// Check whether redraw is actually required
//====================================================

bool RG_TV_ObjectsExist(int direction)
{
   if(direction==OP_BUY)
      return(ObjectFind(0,RG_TV_BUY_ENTRY)>=0);

   if(direction==OP_SELL)
      return(ObjectFind(0,RG_TV_SELL_ENTRY)>=0);

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

   //=================================================
   // ALLOWED LOT is the single source for monetary display.
   // Do NOT recalculate a new lot from Entry/SL here.
   // The Runtime fixed-lot value is the lot already allowed
   // by the active RiskGuard risk settings.
   //=================================================
   double lots=RG_RuntimeFixedLot();

   if(lots<=0.0)
      return;

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

//====================================================
// Preview drag helpers
//====================================================

bool RG_TV_IsPreviewLine(string objectName,int direction)
{
   if(direction==OP_BUY)
      return(
         objectName==RG_TV_BUY_ENTRY ||
         objectName==RG_TV_BUY_SL ||
         objectName==RG_TV_BUY_TP
      );

   if(direction==OP_SELL)
      return(
         objectName==RG_TV_SELL_ENTRY ||
         objectName==RG_TV_SELL_SL ||
         objectName==RG_TV_SELL_TP
      );

   return(false);
}

bool RG_TV_IsPreviewEntry(string objectName,int direction)
{
   return(
      objectName==
      (direction==OP_BUY ? RG_TV_BUY_ENTRY : RG_TV_SELL_ENTRY)
   );
}

bool RG_TV_IsPreviewSL(string objectName,int direction)
{
   return(
      objectName==
      (direction==OP_BUY ? RG_TV_BUY_SL : RG_TV_SELL_SL)
   );
}

bool RG_TV_IsPreviewTP(string objectName,int direction)
{
   return(
      objectName==
      (direction==OP_BUY ? RG_TV_BUY_TP : RG_TV_SELL_TP)
   );
}

// Read the actual price of the dragged preview object.
// OBJ_HLINE has one price coordinate, exposed as OBJPROP_PRICE.
bool RG_TV_ReadDraggedPrice(
   string objectName,
   double &price)
{
   price=0.0;

   if(ObjectFind(0,objectName)<0)
      return(false);

   price=ObjectGetDouble(
      0,
      objectName,
      OBJPROP_PRICE
   );

   if(price<=0.0)
      return(false);

   int digits=
      (int)MarketInfo(Symbol(),MODE_DIGITS);

   price=NormalizeDouble(price,digits);

   return(price>0.0);
}

bool RG_TV_ValidatePreviewPrices(
   int direction,
   double entry,
   double sl,
   double tp)
{
   if(direction!=OP_BUY &&
      direction!=OP_SELL)
      return(false);

   if(entry<=0.0)
      return(false);

   if(RG_RuntimeUseStopLoss())
   {
      if(sl<=0.0)
         return(false);

      if(direction==OP_BUY && sl>=entry)
         return(false);

      if(direction==OP_SELL && sl<=entry)
         return(false);
   }

   if(RG_RuntimeUseTakeProfit())
   {
      if(tp<=0.0)
         return(false);

      if(direction==OP_BUY && tp<=entry)
         return(false);

      if(direction==OP_SELL && tp>=entry)
         return(false);
   }

   return(true);
}

//====================================================
// Handle draggable PREVIEW lines
//
// Design rules:
// 1) Only the active frozen preview can be dragged.
// 2) Entry drag changes ONLY Entry.
//    SL and TP remain independently draggable.
// 3) SL or TP drag changes only that protection level.
// 4) Invalid geometry is rejected and the visual object
//    is immediately restored to the Runtime snapshot.
// 5) No broker order is modified by this handler.
//====================================================

bool RG_TV_HandlePreviewDrag(string objectName)
{
   if(!RG_RuntimePreviewActive())
      return(false);

   int direction=
      RG_RuntimePreviewDirection();

   if(direction!=OP_BUY &&
      direction!=OP_SELL)
      return(false);

   if(!RG_TV_IsPreviewLine(
      objectName,
      direction))
   {
      return(false);
   }

   double draggedPrice=0.0;

   if(!RG_TV_ReadDraggedPrice(
      objectName,
      draggedPrice))
   {
      RG_TV_ShowPreview(direction);
      return(true);
   }

   double entry=
      RG_RuntimePreviewEntry();

   double sl=
      RG_RuntimePreviewSL();

   double tp=
      RG_RuntimePreviewTP();

   int digits=
      (int)MarketInfo(Symbol(),MODE_DIGITS);

   //=================================================
   // ENTRY DRAG
   //=================================================
   // Entry is an independent draggable level.
   // IMPORTANT: moving Entry MUST NOT move SL or TP.
   //
   // SL and TP are independently draggable objects and their
   // Runtime values must remain exactly where the user placed them.
   //=================================================

   if(RG_TV_IsPreviewEntry(
      objectName,
      direction))
   {
      entry=draggedPrice;
   }
   else
   //=================================================
   // SL DRAG
   //=================================================
   if(RG_TV_IsPreviewSL(
      objectName,
      direction))
   {
      sl=draggedPrice;
   }
   else
   //=================================================
   // TP DRAG
   //=================================================
   if(RG_TV_IsPreviewTP(
      objectName,
      direction))
   {
      tp=draggedPrice;
   }

   entry=NormalizeDouble(entry,digits);

   if(sl>0.0)
      sl=NormalizeDouble(sl,digits);

   if(tp>0.0)
      tp=NormalizeDouble(tp,digits);

   //=================================================
   // Reject invalid geometry.
   //=================================================

   if(!RG_TV_ValidatePreviewPrices(
      direction,
      entry,
      sl,
      tp))
   {
      // The user moved the visual object into an invalid geometry.
      // Runtime must remain untouched, so force a redraw from the
      // original frozen snapshot instead of leaving the line displaced.
      RG_TV_DeleteTradeVisualization();
      RG_TV_ShowPreview(direction);
      return(true);
   }

   //=================================================
   // Commit ONLY to Runtime preview state.
   //=================================================

   RG_RuntimeSetPreviewPrices(
      entry,
      sl,
      tp
   );

   //=================================================
   // Recalculate risk-derived lot information.
   //
   // % / $ modes:
   //   risk budget stays fixed, lot changes.
   //
   // Lot mode:
   //   configured fixed lot remains unchanged.
   //=================================================

   // Monetary display is always based on the ALLOWED LOT.
   // Dragging Entry/SL/TP must not silently replace that lot.
   double lot=RG_RuntimeFixedLot();
   if(lot<=0.0)
   {
      RG_TV_ShowPreview(direction);
      return(true);
   }

   // Draw from the newly committed Runtime snapshot.
   RG_TV_ShowPreview(direction);

   return(true);
}

// No custom TP / SL drag for live orders.
// Native MT4 owns live position level movement.
bool RG_TV_HandleTPDrag(string objectName)
{
   return(false);
}

#endif
