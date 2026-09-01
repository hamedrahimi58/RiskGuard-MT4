#ifndef __RG_TRAILING_MQH__
#define __RG_TRAILING_MQH__

#include <RG_Settings.mqh>

//====================================================
// RiskGuard MT4
// Position-based Trailing Engine
//
// TR is armed per ticket. Sequence:
//   1) User configures TR for this ticket.
//   2) Position must be genuinely Risk Free.
//   3) Price must move TrailingStartAfterRFPips from Entry.
//   4) Selected trailing method manages the SL.
//
// Methods:
//   Distance / Candle / Moving Average / Fractal
//====================================================

#define RG_TR_DEFAULT_START_PIPS       50.0
#define RG_TR_DEFAULT_DISTANCE_PIPS   100.0
#define RG_TR_DEFAULT_MA_PERIOD        20
#define RG_TR_DEFAULT_MA_METHOD        MODE_EMA
#define RG_TR_DEFAULT_TIMEFRAME        0
#define RG_TR_BUFFER_PIPS               1.0

enum ENUM_RG_TR_TIMEFRAME
{
   RG_TR_TF_CURRENT = 0,
   RG_TR_TF_M1      = PERIOD_M1,
   RG_TR_TF_M5      = PERIOD_M5,
   RG_TR_TF_M15     = PERIOD_M15,
   RG_TR_TF_M30     = PERIOD_M30,
   RG_TR_TF_H1      = PERIOD_H1,
   RG_TR_TF_H4      = PERIOD_H4,
   RG_TR_TF_D1      = PERIOD_D1
};

string RG_TrailingKey(string suffix,int ticket)
{
   return("RG_TR_"+suffix+"_"+IntegerToString(ticket));
}

string RG_TrailingStateKey(int ticket)
{
   return(RG_TrailingKey("ON",ticket));
}

string RG_TrailingStartKey(int ticket)
{
   return(RG_TrailingKey("START",ticket));
}

string RG_TrailingDistanceKey(int ticket)
{
   return(RG_TrailingKey("DIST",ticket));
}

string RG_TrailingMethodKey(int ticket)
{
   return(RG_TrailingKey("METHOD",ticket));
}

string RG_TrailingTFKey(int ticket)
{
   return(RG_TrailingKey("TF",ticket));
}

string RG_TrailingMAPeriodKey(int ticket)
{
   return(RG_TrailingKey("MAPER",ticket));
}

string RG_TrailingMAMethodKey(int ticket)
{
   return(RG_TrailingKey("MAMETHOD",ticket));
}

string RG_TrailingLastBarKey(int ticket)
{
   return(RG_TrailingKey("LASTBAR",ticket));
}

bool RG_TrailingIsEnabled(int ticket)
{
   string key=RG_TrailingStateKey(ticket);
   return(ticket>0 && GlobalVariableCheck(key) && GlobalVariableGet(key)>0.5);
}

void RG_TrailingDeleteConfig(int ticket)
{
   if(ticket<=0)
      return;

   GlobalVariableDel(RG_TrailingStateKey(ticket));
   GlobalVariableDel(RG_TrailingStartKey(ticket));
   GlobalVariableDel(RG_TrailingDistanceKey(ticket));
   GlobalVariableDel(RG_TrailingMethodKey(ticket));
   GlobalVariableDel(RG_TrailingTFKey(ticket));
   GlobalVariableDel(RG_TrailingMAPeriodKey(ticket));
   GlobalVariableDel(RG_TrailingMAMethodKey(ticket));
   GlobalVariableDel(RG_TrailingLastBarKey(ticket));
}

void RG_TrailingSetConfig(
   int ticket,
   ENUM_RG_TRAILING_METHOD method,
   double startPips,
   double distancePips,
   int timeframe,
   int maPeriod,
   int maMethod)
{
   if(ticket<=0)
      return;

   if(startPips<0.0) startPips=0.0;
   if(distancePips<=0.0) distancePips=RG_TR_DEFAULT_DISTANCE_PIPS;
   if(maPeriod<2) maPeriod=2;

   GlobalVariableSet(RG_TrailingMethodKey(ticket),(double)method);
   GlobalVariableSet(RG_TrailingStartKey(ticket),startPips);
   GlobalVariableSet(RG_TrailingDistanceKey(ticket),distancePips);
   GlobalVariableSet(RG_TrailingTFKey(ticket),(double)timeframe);
   GlobalVariableSet(RG_TrailingMAPeriodKey(ticket),(double)maPeriod);
   GlobalVariableSet(RG_TrailingMAMethodKey(ticket),(double)maMethod);
}

void RG_TrailingGetConfig(
   int ticket,
   ENUM_RG_TRAILING_METHOD &method,
   double &startPips,
   double &distancePips,
   int &timeframe,
   int &maPeriod,
   int &maMethod)
{
   method=RG_TRAILING_DISTANCE;
   startPips=RG_TR_DEFAULT_START_PIPS;
   distancePips=RG_TR_DEFAULT_DISTANCE_PIPS;
   timeframe=RG_TR_DEFAULT_TIMEFRAME;
   maPeriod=RG_TR_DEFAULT_MA_PERIOD;
   maMethod=RG_TR_DEFAULT_MA_METHOD;

   if(ticket<=0)
      return;

   string k=RG_TrailingMethodKey(ticket);
   if(GlobalVariableCheck(k)) method=(ENUM_RG_TRAILING_METHOD)(int)GlobalVariableGet(k);
   k=RG_TrailingStartKey(ticket);
   if(GlobalVariableCheck(k)) startPips=GlobalVariableGet(k);
   k=RG_TrailingDistanceKey(ticket);
   if(GlobalVariableCheck(k)) distancePips=GlobalVariableGet(k);
   k=RG_TrailingTFKey(ticket);
   if(GlobalVariableCheck(k)) timeframe=(int)GlobalVariableGet(k);
   k=RG_TrailingMAPeriodKey(ticket);
   if(GlobalVariableCheck(k)) maPeriod=(int)GlobalVariableGet(k);
   k=RG_TrailingMAMethodKey(ticket);
   if(GlobalVariableCheck(k)) maMethod=(int)GlobalVariableGet(k);
}

void RG_SetTrailingEnabled(int ticket,bool enabled)
{
   if(ticket<=0)
      return;

   if(enabled)
   {
      GlobalVariableSet(RG_TrailingStateKey(ticket),1.0);

      ENUM_RG_TRAILING_METHOD method;
      double startPips,distancePips;
      int timeframe,maPeriod,maMethod;
      RG_TrailingGetConfig(ticket,method,startPips,distancePips,timeframe,maPeriod,maMethod);
      RG_TrailingSetConfig(ticket,method,startPips,distancePips,timeframe,maPeriod,maMethod);
   }
   else
   {
      GlobalVariableSet(RG_TrailingStateKey(ticket),0.0);
      GlobalVariableDel(RG_TrailingLastBarKey(ticket));
   }
}

void RG_ToggleTrailing(int ticket)
{
   RG_SetTrailingEnabled(ticket,!RG_TrailingIsEnabled(ticket));
}

string RG_TrailingMethodName(ENUM_RG_TRAILING_METHOD method)
{
   if(method==RG_TRAILING_CANDLE)  return("Candle");
   if(method==RG_TRAILING_MOVING)  return("Moving Average");
   if(method==RG_TRAILING_FRACTAL) return("Fractal");
   return("Distance");
}

string RG_TrailingTimeframeName(int tf)
{
   if(tf==0) return("Current TF");
   if(tf==PERIOD_M1) return("M1");
   if(tf==PERIOD_M5) return("M5");
   if(tf==PERIOD_M15) return("M15");
   if(tf==PERIOD_M30) return("M30");
   if(tf==PERIOD_H1) return("H1");
   if(tf==PERIOD_H4) return("H4");
   if(tf==PERIOD_D1) return("D1");
   return(IntegerToString(tf));
}

string RG_TrailingMAMethodName(int method)
{
   if(method==MODE_SMA)  return("SMA");
   if(method==MODE_SMMA) return("SMMA");
   if(method==MODE_LWMA) return("LWMA");
   return("EMA");
}

double RG_TrailingPipSize(string symbol)
{
   double point=MarketInfo(symbol,MODE_POINT);
   int digits=(int)MarketInfo(symbol,MODE_DIGITS);
   if(point<=0.0) return(0.0);
   return(point*((digits==3 || digits==5)?10.0:1.0));
}

//====================================================
// Genuine RF detection
// RF means the live SL is beyond Entry by enough price
// distance to cover current spread + commission.
//====================================================

double RG_TrailingCommissionDistance(int ticket)
{
   if(ticket<=0 || !OrderSelect(ticket,SELECT_BY_TICKET))
      return(0.0);

   double lots=OrderLots();
   double commission=MathAbs(OrderCommission());
   string sym=OrderSymbol();
   double tickValue=MarketInfo(sym,MODE_TICKVALUE);
   double tickSize=MarketInfo(sym,MODE_TICKSIZE);

   if(lots<=0.0 || commission<=0.0 || tickValue<=0.0 || tickSize<=0.0)
      return(0.0);

   return(commission*tickSize/(tickValue*lots));
}

bool RG_TrailingIsRiskFreeNow(int ticket)
{
   if(ticket<=0 || !OrderSelect(ticket,SELECT_BY_TICKET))
      return(false);

   int type=OrderType();
   if(type!=OP_BUY && type!=OP_SELL)
      return(false);

   double sl=OrderStopLoss();
   double entry=OrderOpenPrice();
   string sym=OrderSymbol();
   double bid=MarketInfo(sym,MODE_BID);
   double ask=MarketInfo(sym,MODE_ASK);
   double pip=RG_TrailingPipSize(sym);

   if(sl<=0.0 || entry<=0.0 || bid<=0.0 || ask<=0.0 || pip<=0.0)
      return(false);

   double spreadDistance=ask-bid;
   double commissionDistance=RG_TrailingCommissionDistance(ticket);
   double rfDistance=spreadDistance+commissionDistance;

   if(type==OP_BUY)
      return(sl>=entry+rfDistance-(0.1*pip));

   return(sl<=entry-rfDistance+(0.1*pip));
}

bool RG_TrailingHasReachedStart(int ticket)
{
   if(ticket<=0 || !OrderSelect(ticket,SELECT_BY_TICKET))
      return(false);

   if(!RG_TrailingIsRiskFreeNow(ticket))
      return(false);

   ENUM_RG_TRAILING_METHOD method;
   double startPips,distancePips;
   int timeframe,maPeriod,maMethod;
   RG_TrailingGetConfig(ticket,method,startPips,distancePips,timeframe,maPeriod,maMethod);

   string sym=OrderSymbol();
   double pip=RG_TrailingPipSize(sym);
   double startDistance=startPips*pip;
   double entry=OrderOpenPrice();

   if(OrderType()==OP_BUY)
      return(MarketInfo(sym,MODE_BID)-entry>=startDistance);

   if(OrderType()==OP_SELL)
      return(entry-MarketInfo(sym,MODE_ASK)>=startDistance);

   return(false);
}

bool RG_TrailingBrokerAllowsSL(string sym,int type,double sl)
{
   double point=MarketInfo(sym,MODE_POINT);
   double bid=MarketInfo(sym,MODE_BID);
   double ask=MarketInfo(sym,MODE_ASK);
   int minLevel=MathMax((int)MarketInfo(sym,MODE_STOPLEVEL),(int)MarketInfo(sym,MODE_FREEZELEVEL));

   if(point<=0.0 || bid<=0.0 || ask<=0.0)
      return(false);

   if(type==OP_BUY)
      return(sl<bid && (minLevel<=0 || bid-sl>=minLevel*point));

   if(type==OP_SELL)
      return(sl>ask && (minLevel<=0 || sl-ask>=minLevel*point));

   return(false);
}

bool RG_TrailingModify(int ticket,double newSL)
{
   if(!OrderSelect(ticket,SELECT_BY_TICKET))
      return(false);

   string sym=OrderSymbol();
   int digits=(int)MarketInfo(sym,MODE_DIGITS);
   newSL=NormalizeDouble(newSL,digits);

   if(!RG_TrailingBrokerAllowsSL(sym,OrderType(),newSL))
      return(false);

   double oldSL=OrderStopLoss();

   if(OrderType()==OP_BUY)
   {
      if(oldSL>0.0 && newSL<=oldSL)
         return(false);
   }
   else
   {
      if(oldSL>0.0 && newSL>=oldSL)
         return(false);
   }

   ResetLastError();
   bool ok=OrderModify(ticket,OrderOpenPrice(),newSL,OrderTakeProfit(),0,clrNONE);

   if(!ok)
      Print("RG Trailing modify failed. Ticket=",ticket," Error=",GetLastError());

   return(ok);
}

bool RG_TrailingDistance(int ticket)
{
   if(!OrderSelect(ticket,SELECT_BY_TICKET)) return(false);

   ENUM_RG_TRAILING_METHOD method;
   double startPips,distancePips;
   int timeframe,maPeriod,maMethod;
   RG_TrailingGetConfig(ticket,method,startPips,distancePips,timeframe,maPeriod,maMethod);

   string sym=OrderSymbol();
   double pip=RG_TrailingPipSize(sym);
   int digits=(int)MarketInfo(sym,MODE_DIGITS);
   if(pip<=0.0 || distancePips<=0.0) return(false);

   double distance=distancePips*pip;
   double candidate;

   if(OrderType()==OP_BUY)
      candidate=NormalizeDouble(MarketInfo(sym,MODE_BID)-distance,digits);
   else if(OrderType()==OP_SELL)
      candidate=NormalizeDouble(MarketInfo(sym,MODE_ASK)+distance,digits);
   else return(false);

   return(RG_TrailingModify(ticket,candidate));
}

bool RG_TrailingCandle(int ticket)
{
   if(!OrderSelect(ticket,SELECT_BY_TICKET)) return(false);

   ENUM_RG_TRAILING_METHOD method;
   double startPips,distancePips;
   int timeframe,maPeriod,maMethod;
   RG_TrailingGetConfig(ticket,method,startPips,distancePips,timeframe,maPeriod,maMethod);

   string sym=OrderSymbol();
   int tf=(timeframe==0 ? Period() : timeframe);
   datetime barTime=iTime(sym,tf,1);
   if(barTime<=0) return(false);

   // User rule: use one candle BEFORE the latest closed candle => shift 2.
   double low=iLow(sym,tf,2);
   double high=iHigh(sym,tf,2);
   double pip=RG_TrailingPipSize(sym);
   int digits=(int)MarketInfo(sym,MODE_DIGITS);
   if(low<=0.0 || high<=0.0 || pip<=0.0) return(false);

   double candidate;
   if(OrderType()==OP_BUY)
      candidate=NormalizeDouble(low-RG_TR_BUFFER_PIPS*pip,digits);
   else if(OrderType()==OP_SELL)
      candidate=NormalizeDouble(high+RG_TR_BUFFER_PIPS*pip,digits);
   else return(false);

   return(RG_TrailingModify(ticket,candidate));
}

bool RG_TrailingMovingAverage(int ticket)
{
   if(!OrderSelect(ticket,SELECT_BY_TICKET)) return(false);

   ENUM_RG_TRAILING_METHOD method;
   double startPips,distancePips;
   int timeframe,maPeriod,maMethod;
   RG_TrailingGetConfig(ticket,method,startPips,distancePips,timeframe,maPeriod,maMethod);

   string sym=OrderSymbol();
   int tf=(timeframe==0 ? Period() : timeframe);
   datetime closedBar=iTime(sym,tf,1);
   if(closedBar<=0) return(false);

   string lastKey=RG_TrailingLastBarKey(ticket);
   datetime lastBar=0;
   if(GlobalVariableCheck(lastKey)) lastBar=(datetime)GlobalVariableGet(lastKey);
   if(lastBar==closedBar) return(false);
   GlobalVariableSet(lastKey,(double)closedBar);

   double ma=iMA(sym,tf,maPeriod,0,maMethod,PRICE_CLOSE,1);
   double close=iClose(sym,tf,1);
   double pip=RG_TrailingPipSize(sym);
   int digits=(int)MarketInfo(sym,MODE_DIGITS);
   if(ma<=0.0 || close<=0.0 || pip<=0.0) return(false);

   double candidate;

   // BUY: a closed candle below MA triggers SL to its Low - 1 pip.
   if(OrderType()==OP_BUY && close<ma)
   {
      double low=iLow(sym,tf,1);
      candidate=NormalizeDouble(low-RG_TR_BUFFER_PIPS*pip,digits);
      return(RG_TrailingModify(ticket,candidate));
   }

   // SELL: a closed candle above MA triggers SL to its High + 1 pip.
   if(OrderType()==OP_SELL && close>ma)
   {
      double high=iHigh(sym,tf,1);
      candidate=NormalizeDouble(high+RG_TR_BUFFER_PIPS*pip,digits);
      return(RG_TrailingModify(ticket,candidate));
   }

   return(false);
}

bool RG_TrailingFractal(int ticket)
{
   if(!OrderSelect(ticket,SELECT_BY_TICKET)) return(false);

   ENUM_RG_TRAILING_METHOD method;
   double startPips,distancePips;
   int timeframe,maPeriod,maMethod;
   RG_TrailingGetConfig(ticket,method,startPips,distancePips,timeframe,maPeriod,maMethod);

   string sym=OrderSymbol();
   int tf=(timeframe==0 ? Period() : timeframe);
   datetime closedBar=iTime(sym,tf,1);
   if(closedBar<=0) return(false);

   string lastKey=RG_TrailingLastBarKey(ticket);
   datetime lastBar=0;
   if(GlobalVariableCheck(lastKey)) lastBar=(datetime)GlobalVariableGet(lastKey);
   if(lastBar==closedBar) return(false);
   GlobalVariableSet(lastKey,(double)closedBar);

   double pip=RG_TrailingPipSize(sym);
   int digits=(int)MarketInfo(sym,MODE_DIGITS);
   if(pip<=0.0) return(false);

   // Confirmed MT4 fractal is at shift 2. Confirmation rule:
   // BUY low fractal becomes actionable after price crosses the high of
   // the candle immediately before the fractal. SELL is the mirror image.
   double upper=iFractals(sym,tf,MODE_UPPER,2);
   double lower=iFractals(sym,tf,MODE_LOWER,2);
   double prevHigh=iHigh(sym,tf,3);
   double prevLow=iLow(sym,tf,3);

   if(OrderType()==OP_BUY && lower>0.0 && prevHigh>0.0 && MarketInfo(sym,MODE_BID)>prevHigh)
   {
      double candidate=NormalizeDouble(lower-RG_TR_BUFFER_PIPS*pip,digits);
      return(RG_TrailingModify(ticket,candidate));
   }

   if(OrderType()==OP_SELL && upper>0.0 && prevLow>0.0 && MarketInfo(sym,MODE_ASK)<prevLow)
   {
      double candidate=NormalizeDouble(upper+RG_TR_BUFFER_PIPS*pip,digits);
      return(RG_TrailingModify(ticket,candidate));
   }

   return(false);
}

bool RG_ProcessTrailingTicket(int ticket)
{
   if(ticket<=0 || !RG_TrailingIsEnabled(ticket))
      return(false);

   if(!OrderSelect(ticket,SELECT_BY_TICKET))
      return(false);

   if(OrderType()!=OP_BUY && OrderType()!=OP_SELL)
      return(false);

   // TR never moves SL before genuine RF and the post-RF entry trigger.
   if(!RG_TrailingHasReachedStart(ticket))
      return(false);

   ENUM_RG_TRAILING_METHOD method;
   double startPips,distancePips;
   int timeframe,maPeriod,maMethod;
   RG_TrailingGetConfig(ticket,method,startPips,distancePips,timeframe,maPeriod,maMethod);

   if(method==RG_TRAILING_CANDLE)
      return(RG_TrailingCandle(ticket));
   if(method==RG_TRAILING_MOVING)
      return(RG_TrailingMovingAverage(ticket));
   if(method==RG_TRAILING_FRACTAL)
      return(RG_TrailingFractal(ticket));

   return(RG_TrailingDistance(ticket));
}

void RG_ProcessTrailing()
{
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;

      if(OrderType()!=OP_BUY && OrderType()!=OP_SELL)
         continue;

      int ticket=OrderTicket();
      if(RG_TrailingIsEnabled(ticket))
         RG_ProcessTrailingTicket(ticket);
   }
}

#endif
