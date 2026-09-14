#ifndef __RG_GUI_MQH__
#define __RG_GUI_MQH__

#include <RG_Settings.mqh>
#include <RG_Runtime.mqh>
#include <GUI/RG_Label.mqh>
#include <GUI/RG_Edit.mqh>
#include <Trade/RG_PositionCloser.mqh>
#include <Trade/RG_RiskFree.mqh>
#include <RG_SpecialTimes.mqh>

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
#define RG_GUI_AUTO_RF         RG_PREFIX+"AUTO_RF"
#define RG_GUI_TRADE_TAB       RG_PREFIX+"TRADE_TAB"
#define RG_GUI_TOOLS_TAB       RG_PREFIX+"TOOLS_TAB"
#define RG_GUI_TOOLS_PREFIX    RG_PREFIX+"TOOLS_ST_"
#define RG_GUI_NEWS_PREFIX     RG_PREFIX+"TOOLS_NEWS_"

//====================================================
// NEWS ENGINE - ForexFactory JSON / TODAY ONLY
//====================================================
#define RG_NEWS_FF_URL "https://nfs.faireconomy.media/ff_calendar_thisweek.json"
#define RG_NEWS_MAX_EVENTS 128
#define RG_NEWS_MAX_DISPLAY 12
#define RG_NEWS_MAX_ROWS 2
#define RG_NEWS_REFRESH_SEC 300
#define RG_GUI_FONT_NEWS "Times New Roman"
#define RG_GUI_FONT "Times New Roman"
#define RG_NEWS_OBJ_PREFIX RG_GUI_NEWS_PREFIX+"EV_"

struct RG_NewsEvent
{
   datetime brokerTime;
   string   currency;
   string   impact;
};

RG_NewsEvent g_RG_NewsEvents[RG_NEWS_MAX_EVENTS];
int g_RG_NewsEventCount=0;
datetime g_RG_NewsLastFetch=0;
datetime g_RG_NewsLastAttempt=0;
string g_RG_NewsRawJson="";
int g_RG_NewsAppliedCurrency=-1;
int g_RG_NewsAppliedImpact=-1;
int g_RG_NewsAppliedTimeframe=-1;
int g_RG_NewsLastPeriod=-1;
int g_RG_NewsLastDrawMinute=-1;
datetime g_RG_NewsNextEventTime=0;
int g_RG_NewsLastFirstBar=-1;
int g_RG_NewsLastWidth=-1;
bool g_RG_NewsDrawDirty=true;
int g_RG_NewsLastChartHeight=-1;
double g_RG_NewsLastPriceMax=0.0;
double g_RG_NewsLastPriceMin=0.0;
int g_RG_NewsLastDayKey=-1;

//====================================================
// MARKET SESSIONS - RG-067-054
//====================================================
#define RG_GUI_SESSION_OBJECT_PREFIX "RGSESSION_"

bool g_RG_GUI_SessionsEnabled=true;
bool g_RG_GUI_SessionsCurrent=true;
int  g_RG_GUI_SessionsFuture=3;
bool g_RG_GUI_SessionsLabels=true;
bool g_RG_GUI_SessionsOpen=true;
int  g_RG_GUI_SessionsLastMinute=-1;

struct RGSessionOccurrence
{
   string name;
   datetime startTime;
   datetime endTime;
   color lineColor;
   bool current;
};

void RG_GUI_DeleteSessionObjects()
{
   for(int i=ObjectsTotal()-1;i>=0;i--)
   {
      string name=ObjectName(i);
      if(StringFind(name,RG_GUI_SESSION_OBJECT_PREFIX,0)==0)
         ObjectDelete(0,name);
   }
}

string RG_GUI_SessionName(int index)
{
   if(index==0) return("Sydney");
   if(index==1) return("Tokyo");
   if(index==2) return("London");
   return("New York");
}

color RG_GUI_SessionColor(int index)
{
   if(index==0) return(C'0,120,210');
   if(index==1) return(C'50,170,70');
   if(index==2) return(C'220,150,0');
   return(C'175,75,190');
}

datetime RG_GUI_ServerMidnight(datetime serverTime)
{
   MqlDateTime dt; ZeroMemory(dt);
   if(!TimeToStruct(serverTime,dt)) return(0);
   dt.hour=0; dt.min=0; dt.sec=0;
   return(StructToTime(dt));
}

datetime RG_GUI_NthSunday(int year,int month,int nth)
{
   MqlDateTime dt; ZeroMemory(dt);
   dt.year=year; dt.mon=month; dt.day=1;
   datetime first=StructToTime(dt);
   int dow=TimeDayOfWeek(first);
   dt.day=1+(7-dow)%7+(nth-1)*7;
   return(StructToTime(dt));
}

datetime RG_GUI_LastSunday(int year,int month)
{
   MqlDateTime dt; ZeroMemory(dt);
   dt.year=year; dt.mon=month+1; dt.day=1;
   datetime firstNext=StructToTime(dt);
   datetime lastDay=firstNext-86400;
   return(lastDay-TimeDayOfWeek(lastDay)*86400);
}

bool RG_GUI_LondonDST(datetime utcDate)
{
   MqlDateTime dt; ZeroMemory(dt); TimeToStruct(utcDate,dt);
   datetime a=RG_GUI_LastSunday(dt.year,3);
   datetime b=RG_GUI_LastSunday(dt.year,10);
   return(utcDate>=a && utcDate<b);
}

bool RG_GUI_NewYorkDST(datetime utcDate)
{
   MqlDateTime dt; ZeroMemory(dt); TimeToStruct(utcDate,dt);
   datetime a=RG_GUI_NthSunday(dt.year,3,2);
   datetime b=RG_GUI_NthSunday(dt.year,11,1);
   return(utcDate>=a && utcDate<b);
}

bool RG_GUI_SydneyDST(datetime utcDate)
{
   MqlDateTime dt; ZeroMemory(dt); TimeToStruct(utcDate,dt);
   datetime currentStart=RG_GUI_NthSunday(dt.year,10,1);
   datetime currentFinish=RG_GUI_NthSunday(dt.year,4,1);
   datetime previousStart=RG_GUI_NthSunday(dt.year-1,10,1);
   if(utcDate>=currentStart) return(true);
   return(utcDate>=previousStart && utcDate<currentFinish);
}

int RG_GUI_SessionStartUTC(int index,datetime utcDate)
{
   if(index==0) return(RG_GUI_SydneyDST(utcDate)?22:21);
   if(index==1) return(0);
   if(index==2) return(RG_GUI_LondonDST(utcDate)?7:8);
   return(RG_GUI_NewYorkDST(utcDate)?12:13);
}

#define RG_GUI_SESSION_BROKER_OFFSET_GV "RG_GUI_SESSION_BROKER_UTC_OFFSET"

int RG_GUI_GetSessionBrokerOffset()
{
   // TimeCurrent() stops at the last broker tick during Saturday/Sunday.
   // Therefore TimeCurrent()-TimeGMT() is NOT valid on the weekend.
   // Store the real broker offset on a weekday and reuse it while the market
   // is closed.  A GMT+3 fallback is used only on the very first weekend run.
   int serverDow=TimeDayOfWeek(TimeCurrent());
   if(serverDow>=1 && serverDow<=5)
   {
      int off=(int)MathRound((TimeCurrent()-TimeGMT())/3600.0);
      if(off>=-14 && off<=14)
      {
         GlobalVariableSet(RG_GUI_SESSION_BROKER_OFFSET_GV,(double)off);
         return(off);
      }
   }

   if(GlobalVariableCheck(RG_GUI_SESSION_BROKER_OFFSET_GV))
   {
      int saved=(int)MathRound(GlobalVariableGet(RG_GUI_SESSION_BROKER_OFFSET_GV));
      if(saved>=-14 && saved<=14) return(saved);
   }

   return(3);
}

datetime RG_GUI_GetSessionReferenceNow()
{
   // AUTHORITATIVE SESSION CLOCK:
   // During the trading week the value shown by MT4 as Server Time is
   // TimeCurrent().  Never replace it with PC/local time while the market
   // is open.  Doing so can move the session engine into another hour/day
   // and make an actually CURRENT session disappear.
   datetime serverNow=TimeCurrent();
   int dow=TimeDayOfWeek(serverNow);

   if(dow>=1 && dow<=5)
   {
      // Refresh the stored broker UTC offset from the same authoritative
      // server clock. This offset is used only to determine DST dates.
      RG_GUI_GetSessionBrokerOffset();
      return(serverNow);
   }

   // Weekend: TimeCurrent() can remain frozen at Friday's last tick.
   // Here, and only here, advance the broker wall clock using PC time and
   // the last known broker UTC offset.
   datetime localNow=TimeLocal();
   int localOffset=TimeGMTOffset();
   int brokerOffset=RG_GUI_GetSessionBrokerOffset();
   return(localNow-localOffset+brokerOffset*3600);
}

datetime RG_GUI_SessionStartForDate(datetime serverMidnight,int sessionIndex,int dayShift)
{
   // Build the Session start directly on the BROKER calendar clock.
   // The previous implementation converted broker-midnight -> UTC-midnight
   // and then converted back. That is fragile in MT4 because datetime values
   // are timezone-neutral while TimeCurrent/TimeToStruct are presented in the
   // terminal's server clock. At the London/New York boundary this could make
   // a valid current session look like a future occurrence.
   //
   // We therefore keep the requested broker date as the anchor, determine the
   // UTC calendar date only for DST evaluation, and then add the broker offset
   // to the UTC session hour. The resulting datetime is guaranteed to use the
   // requested broker calendar date (or the adjacent date for Sydney when its
   // UTC start converts past midnight).
   int brokerOffset=RG_GUI_GetSessionBrokerOffset();
   datetime wantedServerMidnight=serverMidnight+dayShift*86400;

   // Calendar date used to evaluate DST. Offset conversion is only used to
   // select the correct UTC date; no UTC-midnight reconstruction is required.
   datetime utcProbe=wantedServerMidnight-brokerOffset*3600;
   int utcSessionHour=RG_GUI_SessionStartUTC(sessionIndex,utcProbe);

   int serverHour=utcSessionHour+brokerOffset;
   int dateShift=0;

   while(serverHour>=24)
   {
      serverHour-=24;
      dateShift++;
   }
   while(serverHour<0)
   {
      serverHour+=24;
      dateShift--;
   }

   return(wantedServerMidnight+dateShift*86400+serverHour*3600);
}

int RG_GUI_SessionDurationHours(int index) { return(9); }

void RG_GUI_AddSessionOccurrence(RGSessionOccurrence &items[],int &count,string name,datetime startTime,datetime endTime,color lineColor,bool current)
{
   if(count>=32) return;
   items[count].name=name; items[count].startTime=startTime; items[count].endTime=endTime;
   items[count].lineColor=lineColor; items[count].current=current; count++;
}

void RG_GUI_SortSessionOccurrences(RGSessionOccurrence &items[],int count)
{
   for(int i=1;i<count;i++)
   {
      RGSessionOccurrence key=items[i];
      int j=i-1;
      while(j>=0 && items[j].startTime>key.startTime)
      {
         items[j+1]=items[j];
         j--;
      }
      items[j+1]=key;
   }
}

int RG_GUI_CurrentTFSeconds()
{
   int tf=Period();
   if(tf==PERIOD_M1)  return(60);
   if(tf==PERIOD_M5)  return(300);
   if(tf==PERIOD_M15) return(900);
   if(tf==PERIOD_M30) return(1800);
   if(tf==PERIOD_H1)  return(3600);
   if(tf==PERIOD_H4)  return(14400);
   return(0);
}

bool RG_GUI_GetSessionCandleRange(datetime startTime,datetime endTime,double &sessionHigh,double &sessionLow)
{
   sessionHigh=0.0; sessionLow=0.0;
   int tf=Period();
   int tfSec=RG_GUI_CurrentTFSeconds();
   if(tfSec<=0) return(false);

   int firstVisible=WindowFirstVisibleBar();
   int visibleBars=WindowBarsPerChart();
   if(firstVisible<0 || visibleBars<=0) return(false);

   int lastVisible=firstVisible-visibleBars+1;
   if(lastVisible<0) lastVisible=0;

   bool found=false;
   int bars=iBars(Symbol(),tf);
   if(bars<=0) return(false);

   int from=firstVisible;
   if(from>=bars) from=bars-1;
   int to=lastVisible;
   if(to<0) to=0;

   for(int shift=from;shift>=to;shift--)
   {
      datetime bt=iTime(Symbol(),tf,shift);
      if(bt<=0) continue;
      datetime be=bt+tfSec;

      // Include a chart candle when it overlaps the session interval.
      if(be<=startTime || bt>=endTime) continue;

      double hi=iHigh(Symbol(),tf,shift);
      double lo=iLow(Symbol(),tf,shift);
      if(hi<=0.0 || lo<=0.0) continue;

      if(!found)
      {
         sessionHigh=hi;
         sessionLow=lo;
         found=true;
      }
      else
      {
         if(hi>sessionHigh) sessionHigh=hi;
         if(lo<sessionLow) sessionLow=lo;
      }
   }
   return(found && sessionHigh>=sessionLow);
}

bool RG_GUI_GetPreviousSessionRange(datetime serverMidnight,int sessionIndex,double &sessionHigh,double &sessionLow)
{
   sessionHigh=0.0;
   sessionLow=0.0;

   // Use the latest completed occurrence of the same session that is
   // actually represented by the currently visible chart.
   for(int dayShift=-1;dayShift>=-14;dayShift--)
   {
      datetime st=RG_GUI_SessionStartForDate(serverMidnight,sessionIndex,dayShift);
      datetime en=st+RG_GUI_SessionDurationHours(sessionIndex)*3600;
      if(RG_GUI_GetSessionCandleRange(st,en,sessionHigh,sessionLow))
         return(true);
   }
   return(false);
}

void RG_GUI_CreateSessionLine(string name,datetime t1,double p1,datetime t2,double p2,color lineColor)
{
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
   if(!ObjectCreate(0,name,OBJ_TREND,0,t1,p1,t2,p2)) return;
   ObjectSetInteger(0,name,OBJPROP_COLOR,lineColor);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_RAY,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
}

void RG_GUI_CreateSessionFrame(string base,datetime t1,double top,datetime t2,double bottom,color lineColor)
{
   // Four independent dotted lines are used instead of OBJ_RECTANGLE.
   // This guarantees that the session has NO filled background.
   RG_GUI_CreateSessionLine(base+"TOP",   t1,top,   t2,top,   lineColor);
   RG_GUI_CreateSessionLine(base+"RIGHT", t2,top,   t2,bottom,lineColor);
   RG_GUI_CreateSessionLine(base+"BOTTOM",t2,bottom,t1,bottom,lineColor);
   RG_GUI_CreateSessionLine(base+"LEFT",  t1,bottom,t1,top,   lineColor);
}

void RG_GUI_CreateSessionLabel(string name,string text,datetime when,double price,color textColor)
{
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
   if(!ObjectCreate(0,name,OBJ_TEXT,0,when,price)) return;
   ObjectSetText(name,text,8,RG_GUI_FONT_NEWS,textColor);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
}


bool RG_GUI_GetLast120M15Range(double &rangeHigh,double &rangeLow)
{
   rangeHigh=0.0;
   rangeLow=0.0;

   const int count=120;
   const int startShift=1; // completed M15 candles only
   int bars=iBars(Symbol(),PERIOD_M15);
   if(bars<=startShift) return(false);

   int available=bars-startShift;
   int useCount=available;
   if(useCount>count) useCount=count;
   if(useCount<=0) return(false);

   int hiShift=iHighest(Symbol(),PERIOD_M15,MODE_HIGH,useCount,startShift);
   int loShift=iLowest(Symbol(),PERIOD_M15,MODE_LOW,useCount,startShift);
   if(hiShift<0 || loShift<0) return(false);

   double hi=iHigh(Symbol(),PERIOD_M15,hiShift);
   double lo=iLow(Symbol(),PERIOD_M15,loShift);
   if(hi<=0.0 || lo<=0.0 || hi<lo) return(false);

   rangeHigh=hi;
   rangeLow=lo;
   return(true);
}

void RG_GUI_DrawMarketSessions()
{
   RG_GUI_DeleteSessionObjects();
   if(!g_RG_GUI_SessionsEnabled) return;

   int tf=Period();
   if(tf!=PERIOD_M1 && tf!=PERIOD_M5 && tf!=PERIOD_M15 && tf!=PERIOD_M30 &&
      tf!=PERIOD_H1 && tf!=PERIOD_H4) return;

   datetime now=RG_GUI_GetSessionReferenceNow();
   int nowDow=TimeDayOfWeek(now);

   // Saturday/Sunday are a chart gap, not trading-session days. Do not place
   // Sydney/Tokyo/London/New York frames into the empty weekend area. On
   // Monday the broker wall clock above automatically advances even if the
   // first Monday tick has not arrived yet.
   if(nowDow==0 || nowDow==6) return;

   datetime midnight=RG_GUI_ServerMidnight(now);
   RGSessionOccurrence all[32]; int allCount=0;

   // Build occurrences around the current BROKER date, then sort by their
   // actual server time.  This guarantees Sydney -> Tokyo -> London -> New York
   // order instead of allowing a cross-midnight session to jump to the front.
   for(int day=-2;day<=3;day++)
      for(int si=0;si<4;si++)
      {
         datetime st=RG_GUI_SessionStartForDate(midnight,si,day);
         if(st<=0) continue;

         // Never render an occurrence whose server-calendar start is on the
         // weekend. This is the key difference from a normal 7-day calendar:
         // the visible chart has a Friday->Monday gap, so the session engine
         // must not manufacture boxes inside that gap.
         int stDow=TimeDayOfWeek(st);
         if(stDow==0 || stDow==6) continue;

         datetime en=st+RG_GUI_SessionDurationHours(si)*3600;
         bool current=(st<=now && now<en);
         bool future=(st>now);
         if(!current && !future) continue;
         RG_GUI_AddSessionOccurrence(all,allCount,RG_GUI_SessionName(si),st,en,RG_GUI_SessionColor(si),current);
      }
   RG_GUI_SortSessionOccurrences(all,allCount);

   RGSessionOccurrence selected[16]; int selectedCount=0, futureCount=0;

   // CURRENT is independent for every session.  Do not stop after finding
   // one active session: London and New York can legitimately overlap.
   // Build the current set first, then add the requested future sessions.
   if(g_RG_GUI_SessionsCurrent)
   {
      for(int i=0;i<allCount && selectedCount<16;i++)
      {
         if(!all[i].current) continue;

         bool duplicate=false;
         for(int j=0;j<selectedCount;j++)
         {
            if(selected[j].name==all[i].name &&
               selected[j].startTime==all[i].startTime)
            {
               duplicate=true;
               break;
            }
         }
         if(!duplicate)
            selected[selectedCount++]=all[i];
      }
   }

   for(int i=0;i<allCount && selectedCount<16;i++)
   {
      if(all[i].startTime<=now) continue;
      if(futureCount>=g_RG_GUI_SessionsFuture) continue;

      bool duplicate=false;
      for(int j=0;j<selectedCount;j++)
      {
         if(selected[j].name==all[i].name &&
            selected[j].startTime==all[i].startTime)
         {
            duplicate=true;
            break;
         }
      }
      if(duplicate) continue;

      selected[selectedCount++]=all[i];
      futureCount++;
   }

   // Session height is based on the high-low range of the latest 120
   // COMPLETED M15 candles of the current symbol.  The same height is used
   // for every session so the boxes remain visually comparable.
   double rangeHigh=0.0;
   double rangeLow=0.0;
   if(!RG_GUI_GetLast120M15Range(rangeHigh,rangeLow)) return;

   double sessionRange=rangeHigh-rangeLow;
   if(sessionRange<=0.0) return;

   // Keep the same centered presentation used by the previous stable version,
   // but derive the height from the requested M15/120-candle market range.
   double chartTop=WindowPriceMax();
   double chartBottom=WindowPriceMin();
   if(chartTop<=chartBottom) return;
   double center=(chartTop+chartBottom)/2.0;
   double halfHeight=sessionRange/2.0;

   for(int i=0;i<selectedCount;i++)
   {
      RGSessionOccurrence q=selected[i];
      int si=3;
      if(q.name=="Sydney") si=0;
      else if(q.name=="Tokyo") si=1;
      else if(q.name=="London") si=2;

      // All four sessions use exactly the same height.
      double top=center+halfHeight;
      double bottom=center-halfHeight;

      string base=RG_GUI_SESSION_OBJECT_PREFIX+IntegerToString(i)+"_";
      RG_GUI_CreateSessionFrame(base+"FRAME",q.startTime,top,q.endTime,bottom,q.lineColor);

      if(g_RG_GUI_SessionsLabels)
      {
         string cap=q.name;
         if(q.current) cap+="  NOW";
         else cap+="  NEXT";
         RG_GUI_CreateSessionLabel(base+"LABEL",cap,q.startTime,top,q.lineColor);
      }
   }
   ChartRedraw();
}

void RG_GUI_UpdateSessionVisualization()
{
   static int lastPeriod=-1;
   datetime now=RG_GUI_GetSessionReferenceNow();
   int minute=(int)(now/60);
   if(minute==g_RG_GUI_SessionsLastMinute && lastPeriod==Period()) return;
   g_RG_GUI_SessionsLastMinute=minute;
   lastPeriod=Period();
   RG_GUI_DrawMarketSessions();
}

string RG_GUI_SessionControlName(string key) { return(RG_PREFIX+"SESSION_"+key); }

string RG_NewsObjName(int i)
{
   return(RG_NEWS_OBJ_PREFIX+"TXT_"+IntegerToString(i));
}

string RG_NewsPinName(int i)
{
   return(RG_NEWS_OBJ_PREFIX+"PIN_"+IntegerToString(i));
}

string RG_NewsLineName(int i)
{
   return(RG_NEWS_OBJ_PREFIX+"LINE_"+IntegerToString(i));
}

void RG_NewsDeleteObjects()
{
   // Delete every News chart object by prefix, not only the currently
   // allocated display indexes. This also clears stale objects left by
   // a previous EA instance/reinitialization.
   for(int i=ObjectsTotal()-1;i>=0;i--)
   {
      string name=ObjectName(i);
      if(StringFind(name,RG_NEWS_OBJ_PREFIX,0)==0)
         ObjectDelete(0,name);
   }
}
bool RG_NewsCurrencyAllowed(string cur)
{
   if(g_RG_GUI_NewsCurrencyMode==255) return(true);
   string names[8]={"USD","EUR","GBP","JPY","AUD","CAD","CHF","NZD"};
   for(int i=0;i<8;i++)
   {
      if(cur==names[i])
         return((g_RG_GUI_NewsCurrencyMode & (1<<i))!=0);
   }
   return(false);
}

bool RG_NewsImpactAllowed(string impact)
{
   int bit=0;
   if(impact=="High") bit=1;
   else if(impact=="Medium") bit=2;
   else if(impact=="Low") bit=4;
   if(bit==0) return(false);
   return((g_RG_GUI_NewsImpactMode & bit)!=0);
}

bool RG_NewsTimeframeAllowed()
{
   // News is always CURRENT timeframe. It is displayed only on
   // intraday charts up to H1; H4/D1 and higher are intentionally excluded.
   int tf=Period();
   if(tf==PERIOD_M1 || tf==PERIOD_M5 || tf==PERIOD_M15 ||
      tf==PERIOD_M30 || tf==PERIOD_H1)
      return(true);
   return(false);
}

datetime RG_NewsParseISO(string iso)
{
   // ForexFactory returns an ISO-8601 timestamp with an explicit UTC
   // offset. Convert that timestamp to MT4 broker/server time.
   // The broker offset is measured directly from the terminal server clock
   // versus UTC, so the PC local timezone is not used for the conversion.
   if(StringLen(iso)<19) return(0);

   MqlDateTime dt;
   ZeroMemory(dt);
   dt.year=(int)StringToInteger(StringSubstr(iso,0,4));
   dt.mon =(int)StringToInteger(StringSubstr(iso,5,2));
   dt.day =(int)StringToInteger(StringSubstr(iso,8,2));
   dt.hour=(int)StringToInteger(StringSubstr(iso,11,2));
   dt.min =(int)StringToInteger(StringSubstr(iso,14,2));
   dt.sec =(int)StringToInteger(StringSubstr(iso,17,2));

   if(dt.year<2000 || dt.mon<1 || dt.mon>12 || dt.day<1 || dt.day>31 ||
      dt.hour<0 || dt.hour>23 || dt.min<0 || dt.min>59 || dt.sec<0 || dt.sec>59)
      return(0);

   datetime wall=StructToTime(dt);
   if(wall<=0) return(0);

   int sign=0;
   if(StringLen(iso)>19 && StringGetChar(iso,19)=='-') sign=-1;
   else if(StringLen(iso)>19 && StringGetChar(iso,19)=='+') sign=1;

   int sourceOffset=0;
   if(sign!=0 && StringLen(iso)>=25)
   {
      int oh=(int)StringToInteger(StringSubstr(iso,20,2));
      int om=(int)StringToInteger(StringSubstr(iso,23,2));
      if(oh>23 || om>59) return(0);
      sourceOffset=sign*(oh*3600+om*60);
   }

   // TimeCurrent() is broker/server time. TimeGMT() is UTC according to
   // the terminal. Their difference is the broker server UTC offset.
   int brokerOffset=(int)(TimeCurrent()-TimeGMT());

   // source local -> UTC -> broker server time
   return(wall-sourceOffset+brokerOffset);
}


string RG_NewsJsonField(string obj,string key)
{
   string tag="\""+key+"\":\"";
   int p=StringFind(obj,tag);
   if(p<0) return("");
   p+=StringLen(tag);
   int e=StringFind(obj,"\"",p);
   if(e<0) return("");
   return(StringSubstr(obj,p,e-p));
}

int RG_NewsDayKey(datetime t)
{
   MqlDateTime d;
   ZeroMemory(d);
   if(!TimeToStruct(t,d)) return(-1);
   return(d.year*10000+d.mon*100+d.day);
}

bool RG_NewsIsToday(datetime t,datetime now)
{
   return(RG_NewsDayKey(t)==RG_NewsDayKey(now));
}

void RG_NewsApplyFilters()
{
   g_RG_NewsEventCount=0;
   if(g_RG_NewsRawJson=="") return;

   int pos=0;
   int len=StringLen(g_RG_NewsRawJson);
   datetime now=TimeCurrent();

   while(pos<len && g_RG_NewsEventCount<RG_NEWS_MAX_EVENTS)
   {
      int a=StringFind(g_RG_NewsRawJson,"{",pos);
      if(a<0) break;
      int b=StringFind(g_RG_NewsRawJson,"}",a+1);
      if(b<0) break;

      string obj=StringSubstr(g_RG_NewsRawJson,a,b-a+1);
      string cur=RG_NewsJsonField(obj,"country");
      string date=RG_NewsJsonField(obj,"date");
      string impact=RG_NewsJsonField(obj,"impact");

      if(cur!="" && date!="" && impact!="")
      {
         datetime bt=RG_NewsParseISO(date);
         if(bt>now && RG_NewsIsToday(bt,now) && RG_NewsCurrencyAllowed(cur) && RG_NewsImpactAllowed(impact))
         {
            // Ignore exact duplicates that can occur in the feed.
            bool duplicate=false;
            for(int k=0;k<g_RG_NewsEventCount;k++)
            {
               if(g_RG_NewsEvents[k].brokerTime==bt &&
                  g_RG_NewsEvents[k].currency==cur &&
                  g_RG_NewsEvents[k].impact==impact)
               {
                  duplicate=true;
                  break;
               }
            }
            if(!duplicate)
            {
               g_RG_NewsEvents[g_RG_NewsEventCount].brokerTime=bt;
               g_RG_NewsEvents[g_RG_NewsEventCount].currency=cur;
               g_RG_NewsEvents[g_RG_NewsEventCount].impact=impact;
               g_RG_NewsEventCount++;
            }
         }
      }
      pos=b+1;
   }

   // Sort nearest future event first.
   for(int i=0;i<g_RG_NewsEventCount-1;i++)
   {
      int best=i;
      for(int j=i+1;j<g_RG_NewsEventCount;j++)
      {
         if(g_RG_NewsEvents[j].brokerTime < g_RG_NewsEvents[best].brokerTime)
            best=j;
      }
      if(best!=i)
      {
         RG_NewsEvent tmp=g_RG_NewsEvents[i];
         g_RG_NewsEvents[i]=g_RG_NewsEvents[best];
         g_RG_NewsEvents[best]=tmp;
      }
   }

   g_RG_NewsNextEventTime=0;
   if(g_RG_NewsEventCount>0)
      g_RG_NewsNextEventTime=g_RG_NewsEvents[0].brokerTime;

   g_RG_NewsLastDayKey=RG_NewsDayKey(now);
}

bool RG_NewsFetch()
{
   char data[];
   char result[];
   string headers="";
   string resultHeaders="";
   ResetLastError();
   g_RG_NewsLastAttempt=TimeCurrent();

   int code=WebRequest("GET",RG_NEWS_FF_URL,headers,1500,data,result,resultHeaders);
   if(code!=200)
      return(false);

   string json=CharArrayToString(result,0,-1,CP_UTF8);
   if(StringLen(json)<20)
      return(false);

   g_RG_NewsRawJson=json;
   g_RG_NewsLastFetch=TimeCurrent();
   RG_NewsApplyFilters();
   g_RG_NewsAppliedCurrency=g_RG_GUI_NewsCurrencyMode;
   g_RG_NewsAppliedImpact=g_RG_GUI_NewsImpactMode;
   return(true);
}

string RG_NewsImpactLetter(string impact)
{
   if(impact=="High") return("H");
   if(impact=="Medium") return("M");
   return("L");
}

color RG_NewsImpactColor(string impact)
{
   if(impact=="High") return(clrRed);
   if(impact=="Medium") return(clrOrange);
   return(clrSilver);
}

void RG_NewsDraw()
{
   RG_NewsDeleteObjects();
   g_RG_NewsNextEventTime=0;

   if(!g_RG_GUI_NewsEnabled || !RG_NewsTimeframeAllowed())
   {
      g_RG_NewsDrawDirty=false;
      g_RG_NewsLastDrawMinute=-1;
      return;
   }

   int chartWidth=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   int chartHeight=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   if(chartWidth<=0 || chartHeight<=0)
   {
      g_RG_NewsDrawDirty=false;
      return;
   }

   // News markers are screen-positioned vertically: they stay attached to
   // the bottom of the chart and therefore never follow the live price.
   // Their X coordinate is recalculated from the real event datetime, so
   // scrolling/zooming the chart keeps them aligned with the news time.
   #define RG_NEWS_LANES 12
   #define RG_NEWS_LABEL_W 62
   #define RG_NEWS_LANE_H 15
   #define RG_NEWS_BOTTOM_GAP 24
   #define RG_NEWS_PIN_GAP 12

   // Use CORNER_LEFT_LOWER for the actual objects.  This makes their
   // vertical position independent of price, chart scale and chart height.
   int bottomY=RG_NEWS_BOTTOM_GAP;
   int pinY=bottomY+RG_NEWS_PIN_GAP;

   int laneRight[RG_NEWS_LANES];
   for(int l=0;l<RG_NEWS_LANES;l++)
      laneRight[l]=-1000000;

   datetime now=TimeCurrent();
   int row=0;

   for(int i=0;i<g_RG_NewsEventCount && row<RG_NEWS_MAX_DISPLAY;i++)
   {
      datetime t=g_RG_NewsEvents[i].brokerTime;
      if(t<=now) continue;

      // Price is used only as a neutral mapping point to obtain the exact
      // screen X for the event time. The created objects themselves are
      // OBJ_LABEL objects and are therefore independent of chart price.
      double mapPrice=(WindowPriceMax(0)+WindowPriceMin(0))/2.0;
      int x=0,py=0;
      if(!ChartTimePriceToXY(0,0,t,mapPrice,x,py))
         continue;
      if(x<2 || x>chartWidth-2)
         continue;

      if(g_RG_NewsNextEventTime==0)
         g_RG_NewsNextEventTime=t;

      int halfW=RG_NEWS_LABEL_W/2;
      int chosen=-1;
      for(int lane=0;lane<RG_NEWS_LANES;lane++)
      {
         if(x-halfW > laneRight[lane]+3)
         {
            chosen=lane;
            break;
         }
      }
      if(chosen<0)
      {
         chosen=0;
         for(int lane=1;lane<RG_NEWS_LANES;lane++)
            if(laneRight[lane]<laneRight[chosen])
               chosen=lane;
      }

      int labelY=bottomY-(chosen*RG_NEWS_LANE_H);
      if(labelY<2) labelY=2;

      string txt=TimeToString(t,TIME_MINUTES)+" "+g_RG_NewsEvents[i].currency;
      color eventColor=RG_NewsImpactColor(g_RG_NewsEvents[i].impact);

      // Pin is also screen-anchored. It marks the same event X and stays
      // in the bottom chart zone regardless of price movement.
      string pinName=RG_NewsPinName(row);
      if(ObjectCreate(0,pinName,OBJ_LABEL,0,0,0))
      {
         ObjectSetInteger(0,pinName,OBJPROP_CORNER,CORNER_LEFT_LOWER);
         ObjectSetInteger(0,pinName,OBJPROP_XDISTANCE,x);
         ObjectSetInteger(0,pinName,OBJPROP_YDISTANCE,pinY);
         ObjectSetString(0,pinName,OBJPROP_TEXT,"^");
         ObjectSetString(0,pinName,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pinName,OBJPROP_FONTSIZE,RG_GUI_FS(9));
         ObjectSetInteger(0,pinName,OBJPROP_COLOR,eventColor);
         ObjectSetInteger(0,pinName,OBJPROP_ANCHOR,ANCHOR_CENTER);
         ObjectSetInteger(0,pinName,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,pinName,OBJPROP_SELECTED,false);
         ObjectSetInteger(0,pinName,OBJPROP_HIDDEN,true);
         ObjectSetInteger(0,pinName,OBJPROP_BACK,false);
      }

      string name=RG_NewsObjName(row);
      if(ObjectCreate(0,name,OBJ_LABEL,0,0,0))
      {
         ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
         ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
         ObjectSetInteger(0,name,OBJPROP_YDISTANCE,labelY);
         ObjectSetString(0,name,OBJPROP_TEXT,txt);
         ObjectSetString(0,name,OBJPROP_FONT,RG_GUI_FONT_NEWS);
         ObjectSetInteger(0,name,OBJPROP_FONTSIZE,RG_GUI_FS(8));
         ObjectSetInteger(0,name,OBJPROP_COLOR,eventColor);
         ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_CENTER);
         ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
         ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
         ObjectSetInteger(0,name,OBJPROP_BACK,false);
      }

      laneRight[chosen]=x+halfW;
      row++;
   }

   g_RG_NewsLastDrawMinute=(int)(now/60);
   g_RG_NewsLastPeriod=Period();
   g_RG_NewsAppliedTimeframe=1;
   g_RG_NewsLastFirstBar=(int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0);
   g_RG_NewsLastWidth=chartWidth;
   g_RG_NewsLastChartHeight=chartHeight;
   g_RG_NewsDrawDirty=false;
   ChartRedraw();
}

void RG_NewsEngineUpdate()
{
   if(!g_RG_GUI_NewsEnabled)
   {
      if(g_RG_NewsLastDrawMinute>=0)
      {
         RG_NewsDeleteObjects();
         g_RG_NewsLastDrawMinute=-1;
      }
      g_RG_NewsDrawDirty=false;
      return;
   }

   if(!RG_NewsTimeframeAllowed())
   {
      if(g_RG_NewsLastDrawMinute>=0)
      {
         RG_NewsDeleteObjects();
         g_RG_NewsLastDrawMinute=-1;
      }
      g_RG_NewsDrawDirty=false;
      return;
   }

   if(g_RG_NewsLastPeriod!=Period())
      g_RG_NewsDrawDirty=true;

   // Rebuild the filtered list when the broker trading day changes.
   // News is intentionally limited to the current broker/server date.
   datetime now=TimeCurrent();
   int dayKey=RG_NewsDayKey(now);
   if(g_RG_NewsLastDayKey!=dayKey)
   {
      if(g_RG_NewsRawJson!="")
         RG_NewsApplyFilters();
      g_RG_NewsDrawDirty=true;
   }

   int firstBar=(int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0);
   if(g_RG_NewsLastFirstBar!=firstBar)
      g_RG_NewsDrawDirty=true;

   int chartWidth=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   int chartHeight=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   if(g_RG_NewsLastWidth!=chartWidth || g_RG_NewsLastChartHeight!=chartHeight)
      g_RG_NewsDrawDirty=true;

   // Redraw only when the nearest displayed event has expired.
   if(g_RG_NewsNextEventTime>0 && TimeCurrent()>=g_RG_NewsNextEventTime)
      g_RG_NewsDrawDirty=true;

   if(g_RG_NewsAppliedCurrency!=g_RG_GUI_NewsCurrencyMode ||
      g_RG_NewsAppliedImpact!=g_RG_GUI_NewsImpactMode)
   {
      RG_NewsApplyFilters();
      g_RG_NewsAppliedCurrency=g_RG_GUI_NewsCurrencyMode;
      g_RG_NewsAppliedImpact=g_RG_GUI_NewsImpactMode;
      g_RG_NewsDrawDirty=true;
   }

   // Network access is deliberately performed only from the 1-second timer,
   // never from RG_UpdateGUI/OnTick. A short timeout prevents MT4 from
   // becoming unresponsive when the feed is unreachable.
   if(g_RG_NewsLastFetch==0 || TimeCurrent()-g_RG_NewsLastFetch>=RG_NEWS_REFRESH_SEC)
   {
      if(g_RG_NewsLastAttempt==0 || TimeCurrent()-g_RG_NewsLastAttempt>=120)
      {
         if(RG_NewsFetch())
            g_RG_NewsDrawDirty=true;
      }
   }

   if(g_RG_NewsDrawDirty)
      RG_NewsDraw();
}

// Called immediately after a News selector/toggle action. It never performs
// network access; this keeps the panel responsive. Existing cached data is
// applied/drawn immediately and a fresh feed is picked up by the timer.
void RG_NewsUiChanged()
{
   g_RG_NewsDrawDirty=true;
   if(g_RG_GUI_NewsEnabled && g_RG_NewsRawJson!="")
   {
      RG_NewsApplyFilters();
      g_RG_NewsAppliedCurrency=g_RG_GUI_NewsCurrencyMode;
      g_RG_NewsAppliedImpact=g_RG_GUI_NewsImpactMode;
      if(RG_NewsTimeframeAllowed())
         RG_NewsDraw();
   }
   else if(!g_RG_GUI_NewsEnabled)
   {
      RG_NewsDeleteObjects();
      g_RG_NewsLastDrawMinute=-1;
   }
}

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
#define RG_GUI_BALANCE_TEXT    RG_PREFIX+"BALANCE_TEXT"
#define RG_GUI_PL_TEXT         RG_PREFIX+"PL_TEXT"
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
#define RG_GUI_POS_TRAILING    "TR_"
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
#define RG_GUI_TAB_H           RG_GUI_S(42)

#define RG_GUI_INPUT_W         RG_GUI_S(270)
#define RG_GUI_INPUT_H         RG_GUI_S(42)

#define RG_GUI_BUTTON_W        RG_GUI_S(169)
#define RG_GUI_BUTTON_H        RG_GUI_S(39)
#define RG_GUI_SMALL_BUTTON_W  RG_GUI_S(149)
#define RG_GUI_SMALL_BUTTON_H  RG_GUI_S(40)

#define RG_GUI_ROW_H           RG_GUI_S(105)
#define RG_GUI_SECTION_H       RG_GUI_S(38)
#define RG_GUI_FOOTER_H        RG_GUI_S(46)
#define RG_GUI_MARKET_H        RG_GUI_S(128)

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

bool g_RG_GUI_ToolsOpen=false;
bool g_RG_GUI_SpecialTimesOpen=true;
bool g_RG_GUI_NewsOpen=true;
bool g_RG_GUI_NewsEnabled=false;
int  g_RG_GUI_NewsTimeframe=1;
int  g_RG_GUI_NewsCurrencyMode=255;
int  g_RG_GUI_NewsImpactMode=1;
int  g_RG_GUI_NewsSelector=0;
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

string RG_GUI_PosTrailing(int ticket)
{
   return(RG_GUI_PosName(RG_GUI_POS_TRAILING,ticket));
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
      y+RG_GUI_HEADER_H+RG_GUI_TAB_H+RG_GUI_S(8);

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
      RG_GUI_S(10);

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

   // Tools objects are part of the panel lifecycle. Remove them explicitly
   // so Trade and Tools surfaces can never remain visible behind each other.
   for(int ti=ObjectsTotal()-1;ti>=0;ti--)
   {
      string tn=ObjectName(ti);
      if(StringFind(tn,RG_GUI_TOOLS_PREFIX,0)==0 ||
         tn==RG_PREFIX+"TOOLS_BG" ||
         tn==RG_PREFIX+"TOOLS_TITLE" ||
         tn==RG_PREFIX+"TOOLS_CLOCK" ||
         tn==RG_PREFIX+"TOOLS_HINT")
         ObjectDelete(0,tn);
   }

   for(int i=ObjectsTotal()-1;i>=0;i--)
   {
      string stale=ObjectName(i);

      if(StringFind(
         stale,
         RG_PREFIX,
         0)==0)
      {
         // Special Times and News belong to the chart timeline, not to
         // the draggable panel. Never delete them during panel rebuilds.
         if(StringFind(stale,"RG_ST_",0)==0 ||
            StringFind(stale,RG_NEWS_OBJ_PREFIX,0)==0)
            continue;

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
      OrderType()==OP_BUY ||
      OrderType()==OP_SELL
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
      (buttonW*6)+
      (gap*5);

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
      clrBlack,
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
      clrBlack,
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
      clrBlack,
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
      clrBlack,
      RG_GUI_Z_BUTTON
   );

   RG_GUI_CreateButton(
      RG_GUI_PosTrailing(ticket),
      "TR",
      bx+
      ((buttonW+gap)*4),
      by,
      buttonW,
      buttonH,
      RG_GUI_YELLOW,
      clrBlack,
      RG_GUI_Z_BUTTON
   );

   RG_GUI_CreateButton(
      RG_GUI_PosClose(ticket),
      "X",
      bx+
      ((buttonW+gap)*5),
      by,
      buttonW,
      buttonH,
      RG_GUI_RED,
      clrBlack,
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

   if(ObjectFind(0,RG_GUI_PosTrailing(ticket))>=0)
   {
      bool trailingOn=RG_TrailingIsEnabled(ticket);

      ObjectSetInteger(
         0,
         RG_GUI_PosTrailing(ticket),
         OBJPROP_BGCOLOR,
         (trailingOn ? RG_GUI_GREEN : RG_GUI_YELLOW)
      );

      ObjectSetInteger(
         0,
         RG_GUI_PosTrailing(ticket),
         OBJPROP_COLOR,
         clrBlack
      );

      ObjectSetString(
         0,
         RG_GUI_PosTrailing(ticket),
         OBJPROP_TEXT,
         (trailingOn ? "TR ON" : "TR")
      );
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

   if(RG_RuntimeUseStopLoss())
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

   if(RG_RuntimeUseTakeProfit())
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

   if(RG_RuntimeMaxLot()>0 &&
      lot>RG_RuntimeMaxLot())
   {
      lot=RG_RuntimeMaxLot();
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

   if(RG_RuntimeMaxLot()>0 &&
      brokerMaxLot>RG_RuntimeMaxLot())
   {
      brokerMaxLot=RG_RuntimeMaxLot();
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
      RG_GUI_TAB_H+
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

   if(RG_RuntimeUseStopLoss())
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

   if(RG_RuntimeUseTakeProfit())
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

   if(RG_RuntimeMaxLot()>0 &&
      lot>RG_RuntimeMaxLot())
   {
      lot=RG_RuntimeMaxLot();
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

   double step=0.5;
   double minimum=0.5;

   if(mode==RG_RISK_DOLLAR)
   {
      step=5.0;
      minimum=5.0;
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

   // Each risk mode has its own independent value.
   // Switching mode must restore that mode's last/default value.
   double value=
      RG_RuntimeRiskValue();

   if(mode==RG_RISK_PERCENT)
   {
      if(value<=0.0 || value>100.0)
         value=1.0;
   }
   else
   if(mode==RG_RISK_DOLLAR)
   {
      if(value<=0.0)
         value=5.0;
   }
   else
   {
      value=RG_RuntimeFixedLot();

      if(value<=0.0)
      {
         value=MarketInfo(Symbol(),MODE_MINLOT);
         if(value<=0.0)
            value=0.01;
      }
   }

   RG_RuntimeSetRiskValue(value);
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
         RG_RuntimeATRPeriod(),
         0
      );

   if(atr<=0)
      return(false);

   double distance=
      atr*
      RG_RuntimeATRMultiplier();

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
         RG_RuntimeInitialRR() :
         entry-
         distance*
         RG_RuntimeInitialRR()
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

   if(RG_RuntimeMaxLot()>0 &&
      lot>RG_RuntimeMaxLot())
   {
      lot=RG_RuntimeMaxLot();
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

   // Trade layout must not resize or rewrite the panel while the Tools tab
   // is active. Tools owns the complete content area in that state.
   if(g_RG_GUI_ToolsOpen)
      return;

   int w=
      RG_GUI_GetPanelWidth();

   int x=
      RG_GUI_GetPanelX(w);

   int y=RG_GUI_GetPanelY();

   if(y<5)
      y=5;

   // Layout is based on ACTUAL open managed positions.
   // RG_RuntimeMaxOpenPositions() is a trading limit, not a UI row reservation.
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
         L.marketY+RG_GUI_S(78)
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
         L.marketY+RG_GUI_S(43)
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
         L.marketY+RG_GUI_S(43)
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
         L.marketY+RG_GUI_S(78)
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

   if(ObjectFind(0,RG_GUI_FOOTER_TEXT)>=0)
      ObjectSetInteger(0,RG_GUI_FOOTER_TEXT,OBJPROP_XDISTANCE,x+(w/2));

   if(ObjectFind(0,RG_GUI_BALANCE_TEXT)>=0)
   {
      ObjectSetInteger(0,RG_GUI_BALANCE_TEXT,OBJPROP_XDISTANCE,x+(w/4));
      ObjectSetInteger(0,RG_GUI_BALANCE_TEXT,OBJPROP_YDISTANCE,L.footerY+RG_GUI_S(27));
      ObjectSetInteger(0,RG_GUI_BALANCE_TEXT,OBJPROP_ANCHOR,ANCHOR_CENTER);
   }

   if(ObjectFind(0,RG_GUI_PL_TEXT)>=0)
   {
      ObjectSetInteger(0,RG_GUI_PL_TEXT,OBJPROP_XDISTANCE,x+((w*3)/4));
      ObjectSetInteger(0,RG_GUI_PL_TEXT,OBJPROP_YDISTANCE,L.footerY+RG_GUI_S(27));
      ObjectSetInteger(0,RG_GUI_PL_TEXT,OBJPROP_ANCHOR,ANCHOR_CENTER);
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

void RG_GUI_ToggleAutoRiskFree()
{
   RG_SetAutoRiskFreeEnabled(!RG_AutoRiskFreeEnabled());

   if(ObjectFind(0,RG_GUI_AUTO_RF)>=0)
   {
      bool autoRF=RG_AutoRiskFreeEnabled();

      ObjectSetInteger(
         0,
         RG_GUI_AUTO_RF,
         OBJPROP_BGCOLOR,
         (autoRF ? RG_GUI_GREEN : RG_GUI_HEADER_BG)
      );

      ObjectSetInteger(
         0,
         RG_GUI_AUTO_RF,
         OBJPROP_COLOR,
         (autoRF ? clrBlack : RG_GUI_TEXT)
      );

      ObjectSetString(
         0,
         RG_GUI_AUTO_RF,
         OBJPROP_TEXT,
         (autoRF ? "AUTO RF: ON" : "AUTO RF: OFF")
      );
   }
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
// TOOLS / MARKET SESSIONS
//====================================================

void RG_GUI_CreateToolsSessionsPanel(int x,int y,int w)
{
   int cx=x+RG_GUI_S(10);
   int cw=w-RG_GUI_S(20);
   int headerH=RG_GUI_S(32);

   string header=RG_GUI_SessionControlName("SECTION");
   RG_GUI_CreateButton(
      header,
      g_RG_GUI_SessionsOpen ? "MARKET SESSIONS   [ - ]" : "MARKET SESSIONS   [ + ]",
      x+RG_GUI_S(8),y,
      w-RG_GUI_S(16),headerH,
      RG_GUI_HEADER_BG,RG_GUI_TEXT,RG_GUI_Z_BUTTON+820
   );
   ObjectSetInteger(0,header,OBJPROP_FONTSIZE,RG_GUI_FS(9));

   if(!g_RG_GUI_SessionsOpen)
      return;

   int yy=y+RG_GUI_S(38);
   int gap=RG_GUI_S(6);
   int colGap=RG_GUI_S(8);
   int colW=(cw-colGap)/2;
   int rowH=RG_GUI_S(28);

   string names[4]={"Sessions","Current","Next Sessions","Labels"};
   string keys[4]={"ON_VALUE","CURRENT_VALUE","FUTURE_VALUE","LABELS_VALUE"};
   string vals[4];
   vals[0]=g_RG_GUI_SessionsEnabled ? "ON" : "OFF";
   vals[1]=g_RG_GUI_SessionsCurrent ? "ON" : "OFF";
   vals[2]=IntegerToString(g_RG_GUI_SessionsFuture);
   vals[3]=g_RG_GUI_SessionsLabels ? "ON" : "OFF";

   for(int i=0;i<4;i++)
   {
      int col=i%2;
      int row=i/2;
      int cx2=cx+col*(colW+colGap);
      int ry=yy+row*(rowH+gap);

      RG_GUI_CreateText(
         RG_GUI_SessionControlName(keys[i])+"_LABEL",
         names[i],
         cx2,ry+RG_GUI_S(18),
         RG_GUI_MUTED,RG_GUI_FS(8),RG_GUI_Z_TEXT
      );

      color bg=RG_GUI_HEADER_BG;
      color fg=RG_GUI_TEXT;
      if((i==0 && g_RG_GUI_SessionsEnabled) ||
         (i==1 && g_RG_GUI_SessionsCurrent) ||
         (i==3 && g_RG_GUI_SessionsLabels))
      {
         bg=RG_GUI_GREEN;
         fg=clrBlack;
      }

      RG_GUI_CreateButton(
         RG_GUI_SessionControlName(keys[i]),vals[i],
         cx2+colW-RG_GUI_S(60),ry,
         RG_GUI_S(60),rowH,
         bg,fg,RG_GUI_Z_BUTTON+830
      );
      ObjectSetInteger(0,RG_GUI_SessionControlName(keys[i]),OBJPROP_FONTSIZE,RG_GUI_FS(8));
   }

   RG_GUI_CreateText(
      RG_GUI_SessionControlName("INFO"),
      "Sydney | Tokyo | London | New York  |  Broker Server Time",
      cx,yy+2*(rowH+gap)+RG_GUI_S(2),
      RG_GUI_MUTED,RG_GUI_FS(6),RG_GUI_Z_TEXT
   );
}

void RG_GUI_ToggleSessionsSection()
{
   g_RG_GUI_SessionsOpen=!g_RG_GUI_SessionsOpen;
   RG_CreatePanel();
}

void RG_GUI_ToggleSessionsEnabled()
{
   g_RG_GUI_SessionsEnabled=!g_RG_GUI_SessionsEnabled;
   if(!g_RG_GUI_SessionsEnabled)
      RG_GUI_DeleteSessionObjects();
   else
      RG_GUI_DrawMarketSessions();
   RG_GUI_UpdateToolsPanel();
   ChartRedraw();
}

void RG_GUI_ToggleSessionsCurrent()
{
   g_RG_GUI_SessionsCurrent=!g_RG_GUI_SessionsCurrent;
   RG_GUI_DrawMarketSessions();
   RG_GUI_UpdateToolsPanel();
   ChartRedraw();
}

void RG_GUI_CycleSessionsFuture()
{
   g_RG_GUI_SessionsFuture++;
   if(g_RG_GUI_SessionsFuture>5)
      g_RG_GUI_SessionsFuture=0;
   RG_GUI_DrawMarketSessions();
   RG_GUI_UpdateToolsPanel();
   ChartRedraw();
}

void RG_GUI_ToggleSessionsLabels()
{
   g_RG_GUI_SessionsLabels=!g_RG_GUI_SessionsLabels;
   RG_GUI_DrawMarketSessions();
   RG_GUI_UpdateToolsPanel();
   ChartRedraw();
}


//====================================================
// TOOLS / SPECIAL TIMES
//====================================================

string RG_GUI_ST_TimeName(int i)
{
   return(RG_GUI_TOOLS_PREFIX+"TIME_"+IntegerToString(i+1));
}

string RG_GUI_ST_LabelName(int i)
{
   return(RG_GUI_TOOLS_PREFIX+"LABEL_"+IntegerToString(i+1));
}

string RG_GUI_ST_EnableName(int i)
{
   return(RG_GUI_TOOLS_PREFIX+"ENABLE_"+IntegerToString(i+1));
}

string RG_GUI_ST_ColorName(int i)
{
   return(RG_GUI_TOOLS_PREFIX+"COLOR_"+IntegerToString(i+1));
}

string RG_GUI_ST_DisplayWindowName()
{
   return(RG_GUI_TOOLS_PREFIX+"ST_DISPLAY_WINDOW");
}

string RG_GUI_ST_LabelModeName()
{
   return(RG_GUI_TOOLS_PREFIX+"ST_LABEL_MODE");
}

string RG_GUI_ST_SpecialTimesSectionName()
{
   return(RG_GUI_TOOLS_PREFIX+"SECTION_SPECIAL_TIMES");
}

//====================================================
// TOOLS / NEWS FOUNDATION
//====================================================

string RG_GUI_NewsSectionName()
{
   return(RG_GUI_NEWS_PREFIX+"SECTION");
}

string RG_GUI_NewsEnableName()
{
   return(RG_GUI_NEWS_PREFIX+"ENABLE");
}

string RG_GUI_NewsTimeframeName()
{
   return(RG_GUI_NEWS_PREFIX+"TIMEFRAME");
}

string RG_GUI_NewsCurrencyName()
{
   return(RG_GUI_NEWS_PREFIX+"CURRENCY");
}

string RG_GUI_NewsImpactName()
{
   return(RG_GUI_NEWS_PREFIX+"IMPACT");
}

string RG_GUI_NewsSourceName()
{
   return(RG_GUI_NEWS_PREFIX+"SOURCE");
}

string RG_GUI_NewsStatusName()
{
   return(RG_GUI_NEWS_PREFIX+"STATUS");
}

string RG_GUI_NewsTFItemName(int i)
{ return(RG_GUI_NEWS_PREFIX+"TF_ITEM_"+IntegerToString(i)); }
string RG_GUI_NewsCurrencyItemName(int i)
{ return(RG_GUI_NEWS_PREFIX+"CUR_ITEM_"+IntegerToString(i)); }
string RG_GUI_NewsImpactItemName(int i)
{ return(RG_GUI_NEWS_PREFIX+"IMP_ITEM_"+IntegerToString(i)); }
string RG_GUI_NewsDoneName()
{ return(RG_GUI_NEWS_PREFIX+"SELECT_DONE"); }

string RG_GUI_NewsTimeframeText()
{
   return("TF: CURRENT");
}

string RG_GUI_NewsCurrencyText()
{
   if(g_RG_GUI_NewsCurrencyMode==255) return("CUR: ALL");
   if(g_RG_GUI_NewsCurrencyMode==0) return("CUR: NONE");
   string result="CUR: ";
   string names[8]={"USD","EUR","GBP","JPY","AUD","CAD","CHF","NZD"};
   bool first=true;
   for(int i=0;i<8;i++)
   {
      if((g_RG_GUI_NewsCurrencyMode & (1<<i))!=0)
      {
         if(!first) result+="+";
         result+=names[i];
         first=false;
      }
   }
   return(result);
}

string RG_GUI_NewsImpactText()
{
   if(g_RG_GUI_NewsImpactMode==7) return("IMP: ALL");
   if(g_RG_GUI_NewsImpactMode==3) return("IMP: HIGH+MED");
   if(g_RG_GUI_NewsImpactMode==5) return("IMP: HIGH+LOW");
   if(g_RG_GUI_NewsImpactMode==6) return("IMP: MED+LOW");
   if(g_RG_GUI_NewsImpactMode==4) return("IMP: LOW");
   if(g_RG_GUI_NewsImpactMode==2) return("IMP: MED");
   return("IMP: HIGH");
}

void RG_GUI_DeleteNewsSelectorObjects()
{
   for(int i=0;i<8;i++)
      ObjectDelete(0,RG_GUI_NewsTFItemName(i));
   for(int i=0;i<9;i++)
      ObjectDelete(0,RG_GUI_NewsCurrencyItemName(i));
   for(int i=0;i<4;i++)
      ObjectDelete(0,RG_GUI_NewsImpactItemName(i));
   ObjectDelete(0,RG_GUI_NewsDoneName());
   ObjectDelete(0,RG_GUI_NEWS_PREFIX+"CURRENT");
}

void RG_GUI_DeleteNewsFooter()
{
   ObjectDelete(0,RG_GUI_NewsSourceName());
   ObjectDelete(0,RG_GUI_NewsStatusName());
   ObjectDelete(0,RG_GUI_NEWS_PREFIX+"FUTURE");
}

void RG_GUI_RefreshNewsPanel()
{
   if(!g_RG_GUI_ToolsOpen || !g_RG_GUI_PanelExpanded)
      return;

   int w=RG_GUI_GetPanelWidth();
   int x=RG_GUI_GetPanelX(w);
   int y=RG_GUI_GetPanelY();
   int pw=w;
   int sessionH=(g_RG_GUI_SessionsOpen ? RG_GUI_S(138) : RG_GUI_S(44));
   int specialH=(g_RG_GUI_SpecialTimesOpen ? RG_GUI_S(360) : RG_GUI_S(48));
   int newsH=RG_GUI_S(176);
   if(!g_RG_GUI_NewsOpen)
      newsH=RG_GUI_S(42);
   else if(g_RG_GUI_NewsSelector==2)
      newsH=RG_GUI_S(286);
   else if(g_RG_GUI_NewsSelector==3)
      newsH=RG_GUI_S(226);

   int ph=sessionH+specialH+newsH+RG_GUI_S(20);
   int top=y+RG_GUI_HEADER_H+RG_GUI_TAB_H+RG_GUI_S(10);

   // Keep the outer panel synchronized with the expanded selector.
   // Previously only TOOLS_BG was resized, so Currency/Impact/Time
   // option boxes could extend outside the main RiskGuard panel.
   string panelName=RG_GUI_PANEL;
   if(ObjectFind(0,panelName)>=0)
   {
      int outerH=RG_GUI_HEADER_H+RG_GUI_TAB_H+RG_GUI_S(12)+ph;
      ObjectSetInteger(0,panelName,OBJPROP_YSIZE,outerH);
   }
   string bg=RG_PREFIX+"TOOLS_BG";
   if(ObjectFind(0,bg)>=0)
   {
      ObjectSetInteger(0,bg,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,bg,OBJPROP_YDISTANCE,top);
      ObjectSetInteger(0,bg,OBJPROP_XSIZE,pw);
      ObjectSetInteger(0,bg,OBJPROP_YSIZE,ph);
   }

   int newsTop=top+sessionH+specialH+RG_GUI_S(8);
   string ns=RG_GUI_NewsSectionName();
   if(ObjectFind(0,ns)<0)
      RG_GUI_CreateButton(ns,g_RG_GUI_NewsOpen ? "NEWS   [ - ]" : "NEWS   [ + ]",x+RG_GUI_S(8),newsTop,pw-RG_GUI_S(16),RG_GUI_S(32),RG_GUI_HEADER_BG,RG_GUI_CYAN,RG_GUI_Z_BUTTON+800);
   else
   {
      ObjectSetInteger(0,ns,OBJPROP_XDISTANCE,x+RG_GUI_S(8));
      ObjectSetInteger(0,ns,OBJPROP_YDISTANCE,newsTop);
      ObjectSetInteger(0,ns,OBJPROP_XSIZE,pw-RG_GUI_S(16));
      ObjectSetInteger(0,ns,OBJPROP_YSIZE,RG_GUI_S(32));
      ObjectSetString(0,ns,OBJPROP_TEXT,g_RG_GUI_NewsOpen ? "NEWS   [ - ]" : "NEWS   [ + ]");
   }
   ObjectSetInteger(0,ns,OBJPROP_FONTSIZE,RG_GUI_FS(10));

   if(!g_RG_GUI_NewsOpen)
   {
      ObjectDelete(0,RG_GUI_NewsEnableName());
      ObjectDelete(0,RG_GUI_NewsTimeframeName());
      ObjectDelete(0,RG_GUI_NewsCurrencyName());
      ObjectDelete(0,RG_GUI_NewsImpactName());
      RG_GUI_DeleteNewsSelectorObjects();
      RG_GUI_DeleteNewsFooter();
      ChartRedraw();
      return;
   }

   int ny=newsTop+RG_GUI_S(42);
   int gap=RG_GUI_S(6);
   int bw=(pw-RG_GUI_S(20)-gap)/2;
   if(bw<100) bw=100;
   string ne=RG_GUI_NewsEnableName();
   string nc=RG_GUI_NewsCurrencyName();
   string ni=RG_GUI_NewsImpactName();

   // News timeframe is fixed to CURRENT. It is not configurable.
   // News is automatically suppressed on H4/D1/W1/MN1.
   RG_GUI_CreateButton(ne,g_RG_GUI_NewsEnabled?"NEWS: ON":"NEWS: OFF",x+RG_GUI_S(10),ny,bw,RG_GUI_S(30),g_RG_GUI_NewsEnabled?RG_GUI_GREEN:RG_GUI_HEADER_BG,g_RG_GUI_NewsEnabled?clrBlack:RG_GUI_TEXT,RG_GUI_Z_BUTTON+810);
   // Timeframe is intentionally not configurable. News always uses CURRENT
   // and is automatically disabled on H4 and higher.  Use plain text rather
   // than a button so no hidden Timeframe selector can open or overflow.
   RG_GUI_CreateButton(RG_GUI_NewsTimeframeName(), "TF: CURRENT", x+RG_GUI_S(10)+bw+gap, ny, bw, RG_GUI_S(30), RG_GUI_HEADER_BG, clrWhite, RG_GUI_Z_BUTTON+810);
   ObjectSetInteger(0,RG_GUI_NewsTimeframeName(),OBJPROP_FONTSIZE,RG_GUI_FS(9));
   ny+=RG_GUI_S(36);
   RG_GUI_CreateButton(nc,RG_GUI_NewsCurrencyText(),x+RG_GUI_S(10),ny,bw,RG_GUI_S(30),clrDarkGreen,clrWhite,RG_GUI_Z_BUTTON+810);
   RG_GUI_CreateButton(ni,RG_GUI_NewsImpactText(),x+RG_GUI_S(10)+bw+gap,ny,bw,RG_GUI_S(30),clrDarkRed,clrWhite,RG_GUI_Z_BUTTON+810);
   ny+=RG_GUI_S(42);

   RG_GUI_DeleteNewsSelectorObjects();
   RG_GUI_DeleteNewsFooter();

   if(g_RG_GUI_NewsSelector==2)
   {
      int sg=RG_GUI_S(5);
      int sw=(pw-RG_GUI_S(20)-2*sg)/3;
      string curNames[9]={"USD","EUR","GBP","JPY","AUD","CAD","CHF","NZD","ALL"};
      for(int i=0;i<9;i++)
      {
         int col=i%3; int row=i/3;
         int sx=x+RG_GUI_S(10)+col*(sw+sg);
         int sy=ny+row*RG_GUI_S(30);
         bool sel=(i==8 ? g_RG_GUI_NewsCurrencyMode==255 : g_RG_GUI_NewsCurrencyMode!=255 && (g_RG_GUI_NewsCurrencyMode&(1<<i))!=0);
         RG_GUI_CreateButton(RG_GUI_NewsCurrencyItemName(i),curNames[i],sx,sy,sw,RG_GUI_S(26),sel?RG_GUI_GREEN:RG_GUI_HEADER_BG,sel?clrBlack:RG_GUI_TEXT,RG_GUI_Z_BUTTON+850);
      }
      RG_GUI_CreateButton(RG_GUI_NewsDoneName(),"DONE",x+RG_GUI_S(10),ny+2*RG_GUI_S(30),pw-RG_GUI_S(20),RG_GUI_S(26),RG_GUI_HEADER_BG,RG_GUI_CYAN,RG_GUI_Z_BUTTON+850);
   }
   else if(g_RG_GUI_NewsSelector==3)
   {
      int sg=RG_GUI_S(5);
      int sw=(pw-RG_GUI_S(20)-2*sg)/3;
      string impNames[4]={"HIGH","MED","LOW","ALL"};
      for(int i=0;i<4;i++)
      {
         int col=i%3; int row=i/3;
         int sx=x+RG_GUI_S(10)+col*(sw+sg);
         int sy=ny+row*RG_GUI_S(30);
         bool sel=(i==0?((g_RG_GUI_NewsImpactMode&1)!=0):i==1?((g_RG_GUI_NewsImpactMode&2)!=0):i==2?((g_RG_GUI_NewsImpactMode&4)!=0):g_RG_GUI_NewsImpactMode==7);
         RG_GUI_CreateButton(RG_GUI_NewsImpactItemName(i),impNames[i],sx,sy,sw,RG_GUI_S(26),sel?RG_GUI_RED:RG_GUI_HEADER_BG,RG_GUI_TEXT,RG_GUI_Z_BUTTON+850);
      }
      RG_GUI_CreateButton(RG_GUI_NewsDoneName(),"DONE",x+RG_GUI_S(10),ny+2*RG_GUI_S(30),pw-RG_GUI_S(20),RG_GUI_S(26),RG_GUI_HEADER_BG,RG_GUI_CYAN,RG_GUI_Z_BUTTON+850);
   }
   else
   {
      int infoY=newsTop+RG_GUI_S(116);
      RG_GUI_CreateText(RG_GUI_NewsSourceName(),"SOURCE: FOREXFACTORY",x+RG_GUI_S(12),infoY,RG_GUI_MUTED,RG_GUI_FS(7),RG_GUI_Z_TEXT+20);
      RG_GUI_CreateText(RG_GUI_NewsStatusName(),"TIME + CURRENCY + IMPACT | SERVER TIME",x+RG_GUI_S(12),infoY+RG_GUI_S(14),RG_GUI_MUTED,RG_GUI_FS(6),RG_GUI_Z_TEXT+20);
      RG_GUI_CreateText(RG_GUI_NEWS_PREFIX+"FUTURE","TODAY NEWS ONLY",x+RG_GUI_S(12),infoY+RG_GUI_S(28),RG_GUI_MUTED,RG_GUI_FS(6),RG_GUI_Z_TEXT+20);
   }
   ChartRedraw();
}

void RG_GUI_ToggleNews()
{
   g_RG_GUI_NewsEnabled=!g_RG_GUI_NewsEnabled;
   RG_GUI_RefreshNewsPanel();
   RG_NewsUiChanged();
}
void RG_GUI_ToggleNewsPanel()
{
   g_RG_GUI_NewsTimeframe=1;
   g_RG_GUI_NewsOpen=!g_RG_GUI_NewsOpen;
   g_RG_GUI_NewsSelector=0;
   RG_GUI_RefreshNewsPanel();
   RG_NewsUiChanged();
}
void RG_GUI_OpenNewsSelector(int mode)
{
   // Timeframe selection was intentionally removed. News is always CURRENT.
   if(mode!=2 && mode!=3) return;
   g_RG_GUI_NewsSelector=(g_RG_GUI_NewsSelector==mode ? 0 : mode);
   RG_GUI_RefreshNewsPanel();
   RG_NewsUiChanged();
}

void RG_GUI_SelectNewsTimeframe(int index)
{
   // Intentionally disabled: News always uses CURRENT timeframe.
   g_RG_GUI_NewsTimeframe=1;
}

void RG_GUI_ToggleNewsCurrency(int index)
{
   if(index<0 || index>8) return;
   if(index==8) { g_RG_GUI_NewsCurrencyMode=255; RG_GUI_RefreshNewsPanel();
   RG_NewsUiChanged(); return; }
   if(g_RG_GUI_NewsCurrencyMode==255) g_RG_GUI_NewsCurrencyMode=0;
   int bit=(1<<index);
   if((g_RG_GUI_NewsCurrencyMode & bit)!=0) g_RG_GUI_NewsCurrencyMode &= ~bit;
   else g_RG_GUI_NewsCurrencyMode |= bit;
   RG_GUI_RefreshNewsPanel();
   RG_NewsUiChanged();
}
void RG_GUI_SelectNewsImpact(int index)
{
   if(index<0 || index>3) return;
   if(index==3)
   {
      g_RG_GUI_NewsImpactMode=7;
      RG_GUI_RefreshNewsPanel();
   RG_NewsUiChanged();
      return;
   }
   if(g_RG_GUI_NewsImpactMode==7)
      g_RG_GUI_NewsImpactMode=0;
   int bit=(1<<index);
   if((g_RG_GUI_NewsImpactMode & bit)!=0)
      g_RG_GUI_NewsImpactMode &= ~bit;
   else
      g_RG_GUI_NewsImpactMode |= bit;
   if(g_RG_GUI_NewsImpactMode==0)
      g_RG_GUI_NewsImpactMode=bit;
   RG_GUI_RefreshNewsPanel();
   RG_NewsUiChanged();
}
void RG_GUI_FinishNewsSelector()
{
   g_RG_GUI_NewsSelector=0;
   RG_GUI_RefreshNewsPanel();
   RG_NewsUiChanged();
}
void RG_GUI_CycleNewsTimeframe() { g_RG_GUI_NewsTimeframe=1; }
void RG_GUI_CycleNewsCurrency() { RG_GUI_OpenNewsSelector(2); }
void RG_GUI_CycleNewsImpact() { RG_GUI_OpenNewsSelector(3); }

string RG_GUI_ST_DisplayLabel(int i,string text)
{
   string t=text;
   StringTrimLeft(t);
   StringTrimRight(t);

   // NONE means no label at all.
   if(t=="NONE" || t=="None" || t=="none")
      return("");

   // The panel uses compact identifiers LB1 ... LB10.
   // The trader's real label text is still taken from MT4 Inputs and
   // is used unchanged by the chart Special Times engine.
   return("LB"+IntegerToString(i+1));
}

bool RG_GUI_CreateToolEdit(string name,string text,int x,int y,int w,int h)
{
   bool exists=(ObjectFind(0,name)>=0);
   if(!exists)
   {
      if(!ObjectCreate(0,name,OBJ_EDIT,0,0,0))
         return(false);
   }

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrBlack);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrDimGray);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,RG_GUI_FS(8));
   ObjectSetString(0,name,OBJPROP_FONT,RG_GUI_FONT);

   // RG-067-023: Time/Label are edited only from MT4 Inputs.
   // Keep the panel fields display-only and prevent mouse movement.
   ObjectSetInteger(0,name,OBJPROP_READONLY,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_ALIGN,ALIGN_LEFT);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,100);

   // Always refresh the displayed value.  Previously this was done only
   // when the object was first created, so Reset/Input changes could leave
   // stale text inside the edit box.
   ObjectSetString(0,name,OBJPROP_TEXT,text);

   return(true);
}

void RG_GUI_CreateTabButtons(int x,int y,int w)
{
   int gap=RG_GUI_S(6);
   int inset=RG_GUI_S(7);
   int bw=(w-(2*inset)-gap)/2;
   if(bw<80) bw=80;
   int ty=y+RG_GUI_HEADER_H+RG_GUI_S(5);
   int th=RG_GUI_TAB_H-RG_GUI_S(8);
   if(th<24) th=24;
   bool tools=g_RG_GUI_ToolsOpen;
   RG_GUI_CreateButton(RG_GUI_TRADE_TAB,"TRADE",x+inset,ty,bw,th,(!tools ? RG_GUI_BLUE : RG_GUI_HEADER_BG),RG_GUI_TEXT,RG_GUI_Z_BUTTON+50);
   RG_GUI_CreateButton(RG_GUI_TOOLS_TAB,"TOOLS",x+inset+bw+gap,ty,bw,th,(tools ? RG_GUI_BLUE : RG_GUI_HEADER_BG),RG_GUI_TEXT,RG_GUI_Z_BUTTON+50);
   ObjectSetInteger(0,RG_GUI_TRADE_TAB,OBJPROP_FONTSIZE,RG_GUI_BUTTON_SIZE);
   ObjectSetInteger(0,RG_GUI_TOOLS_TAB,OBJPROP_FONTSIZE,RG_GUI_BUTTON_SIZE);
}

void RG_GUI_CreateToolsPanel()
{
   if(!g_RG_GUI_ToolsOpen || !g_RG_GUI_PanelExpanded) return;

   int w=RG_GUI_GetPanelWidth();
   int x=RG_GUI_GetPanelX(w);
   int y=RG_GUI_GetPanelY();
   int pw=w;

   int sessionH=(g_RG_GUI_SessionsOpen ? RG_GUI_S(138) : RG_GUI_S(44));
   int specialH=(g_RG_GUI_SpecialTimesOpen ? RG_GUI_S(360) : RG_GUI_S(48));
   int newsH=RG_GUI_S(176);
   if(!g_RG_GUI_NewsOpen) newsH=RG_GUI_S(42);
   else if(g_RG_GUI_NewsSelector==2) newsH=RG_GUI_S(286);
   else if(g_RG_GUI_NewsSelector==3) newsH=RG_GUI_S(226);

   int ph=sessionH+specialH+newsH+RG_GUI_S(20);
   int top=y+RG_GUI_HEADER_H+RG_GUI_TAB_H+RG_GUI_S(10);

   RG_GUI_CreateRect(
      RG_PREFIX+"TOOLS_BG",
      x,
      top,
      pw,
      ph,
      RG_GUI_BG,
      RG_GUI_BORDER,
      RG_GUI_Z_PANEL+1
   );

   //=================================================
   // MARKET SESSIONS
   //=================================================
   int sessionTop=top+RG_GUI_S(8);
   RG_GUI_CreateToolsSessionsPanel(x,sessionTop,pw);

   //=================================================
   // SPECIAL TIMES
   //=================================================
   int specialTop=top+sessionH;

   string sec=RG_GUI_ST_SpecialTimesSectionName();
   RG_GUI_CreateButton(
      sec,
      g_RG_GUI_SpecialTimesOpen ? "SPECIAL TIMES   [ - ]" : "SPECIAL TIMES   [ + ]",
      x+RG_GUI_S(8),
      specialTop+RG_GUI_S(8),
      pw-RG_GUI_S(16),
      RG_GUI_S(32),
      RG_GUI_HEADER_BG,
      RG_GUI_YELLOW,
      RG_GUI_Z_BUTTON+800
   );
   ObjectSetInteger(0,sec,OBJPROP_FONTSIZE,RG_GUI_FS(10));

   if(g_RG_GUI_SpecialTimesOpen)
   {
      string dwn=RG_GUI_ST_DisplayWindowName();
      string lmn=RG_GUI_ST_LabelModeName();
      bool first=(RG_SpecialTimesGetDisplayWindow()==RG_ST_DISPLAY_FIRST_INDICATOR);
      bool timeOnly=(RG_SpecialTimesGetLabelMode()==RG_ST_LABEL_TIME_ONLY);

      int ctrlY=specialTop+RG_GUI_S(70);
      int ctrlGap=RG_GUI_S(8);
      int ctrlW=(pw-RG_GUI_S(28)-ctrlGap)/2;

      RG_GUI_CreateButton(
         dwn,
         first ? "WINDOW: 1ST INDICATOR" : "WINDOW: MAIN",
         x+RG_GUI_S(10),
         ctrlY,
         ctrlW,
         RG_GUI_S(30),
         clrDarkSlateBlue,
         clrWhite,
         RG_GUI_Z_BUTTON+800
      );
      ObjectSetInteger(0,dwn,OBJPROP_FONTSIZE,RG_GUI_FS(8));

      RG_GUI_CreateButton(
         lmn,
         timeOnly ? "LABEL: TIME ONLY" : "LABEL: TIME + LABEL",
         x+RG_GUI_S(10)+ctrlW+ctrlGap,
         ctrlY,
         ctrlW,
         RG_GUI_S(30),
         clrDarkGreen,
         clrWhite,
         RG_GUI_Z_BUTTON+800
      );
      ObjectSetInteger(0,lmn,OBJPROP_FONTSIZE,RG_GUI_FS(8));

      int rowH=RG_GUI_S(48);
      int rowY=specialTop+RG_GUI_S(112);
      int colGap=RG_GUI_S(10);
      int colW=(pw-RG_GUI_S(20)-colGap)/2;
      if(colW<170) colW=170;

      for(int i=0;i<10;i++)
      {
         int col=i/5;
         int row=i%5;
         int cx=x+RG_GUI_S(10)+col*(colW+colGap);
         int yy=rowY+row*rowH;

         string en=RG_GUI_ST_EnableName(i);
         string tn=RG_GUI_ST_TimeName(i);
         string ln=RG_GUI_ST_LabelName(i);
         string cn=RG_GUI_ST_ColorName(i);

         bool enabled=RG_SpecialTimesGetEnabled(i);
         color cc=RG_SpecialTimesGetColor(i);

         int onW=RG_GUI_S(38);
         int timeW=RG_GUI_S(60);
         int colorW=RG_GUI_S(22);
         int gap=RG_GUI_S(3);
         int labelW=RG_GUI_S(58);

         int maxLabelW=colW-onW-timeW-colorW-(gap*3);
         if(labelW>maxLabelW) labelW=maxLabelW;
         if(labelW<48) labelW=48;

         RG_GUI_CreateButton(
            en,
            enabled ? "ON" : "OFF",
            cx,
            yy,
            onW,
            RG_GUI_S(30),
            enabled ? RG_GUI_GREEN : RG_GUI_HEADER_BG,
            enabled ? clrBlack : RG_GUI_TEXT,
            RG_GUI_Z_BUTTON+20
         );

         RG_GUI_CreateToolEdit(
            tn,
            RG_SpecialTimesGetTime(i),
            cx+onW+gap,
            yy,
            timeW,
            RG_GUI_S(30)
         );
         ObjectSetInteger(0,tn,OBJPROP_FONTSIZE,RG_GUI_FS(7));

         RG_GUI_CreateToolEdit(
            ln,
            RG_SpecialTimesGetLabel(i),
            cx+onW+gap+timeW+gap,
            yy,
            labelW,
            RG_GUI_S(30)
         );
         ObjectSetString(
            0,
            ln,
            OBJPROP_TEXT,
            RG_GUI_ST_DisplayLabel(i,RG_SpecialTimesGetLabel(i))
         );
         ObjectSetInteger(0,ln,OBJPROP_FONTSIZE,RG_GUI_FS(7));

         RG_GUI_CreateButton(
            cn,
            " ",
            cx+colW-colorW,
            yy,
            colorW,
            RG_GUI_S(30),
            cc,
            clrBlack,
            RG_GUI_Z_BUTTON+20
         );
      }

      RG_GUI_CreateText(
         RG_PREFIX+"TOOLS_HINT",
         "Time / Label are edited from MT4 Inputs. Defaults use LB1 ... LB10.",
         x+RG_GUI_S(12),
         specialTop+specialH-RG_GUI_S(16),
         RG_GUI_MUTED,
         RG_GUI_FS(8),
         RG_GUI_Z_TEXT+10
      );
   }

   //=================================================
   // NEWS
   //=================================================
   int newsTop=specialTop+specialH+RG_GUI_S(8);

   string ns=RG_GUI_NewsSectionName();
   RG_GUI_CreateButton(
      ns,
      g_RG_GUI_NewsOpen ? "NEWS   [ - ]" : "NEWS   [ + ]",
      x+RG_GUI_S(8),
      newsTop,
      pw-RG_GUI_S(16),
      RG_GUI_S(32),
      RG_GUI_HEADER_BG,
      RG_GUI_CYAN,
      RG_GUI_Z_BUTTON+800
   );
   ObjectSetInteger(0,ns,OBJPROP_FONTSIZE,RG_GUI_FS(10));

   if(!g_RG_GUI_NewsOpen)
      return;

   int ny=newsTop+RG_GUI_S(42);
   int gap=RG_GUI_S(6);
   int bw=(pw-RG_GUI_S(20)-gap)/2;
   if(bw<100) bw=100;

   string ne=RG_GUI_NewsEnableName();
   string nc=RG_GUI_NewsCurrencyName();
   string ni=RG_GUI_NewsImpactName();

   RG_GUI_CreateButton(
      ne,
      g_RG_GUI_NewsEnabled ? "NEWS: ON" : "NEWS: OFF",
      x+RG_GUI_S(10),
      ny,
      bw,
      RG_GUI_S(30),
      g_RG_GUI_NewsEnabled ? RG_GUI_GREEN : RG_GUI_HEADER_BG,
      g_RG_GUI_NewsEnabled ? clrBlack : RG_GUI_TEXT,
      RG_GUI_Z_BUTTON+810
   );

   // News is always CURRENT timeframe and is suppressed on H4 and higher.
   RG_GUI_CreateButton(
      RG_GUI_NewsTimeframeName(),
      "TF: CURRENT",
      x+RG_GUI_S(10)+bw+gap,
      ny,
      bw,
      RG_GUI_S(30),
      RG_GUI_HEADER_BG,
      clrWhite,
      RG_GUI_Z_BUTTON+810
   );
   ObjectSetInteger(0,RG_GUI_NewsTimeframeName(),OBJPROP_FONTSIZE,RG_GUI_FS(9));

   ny+=RG_GUI_S(36);

   RG_GUI_CreateButton(
      nc,
      RG_GUI_NewsCurrencyText(),
      x+RG_GUI_S(10),
      ny,
      bw,
      RG_GUI_S(30),
      clrDarkGreen,
      clrWhite,
      RG_GUI_Z_BUTTON+810
   );

   RG_GUI_CreateButton(
      ni,
      RG_GUI_NewsImpactText(),
      x+RG_GUI_S(10)+bw+gap,
      ny,
      bw,
      RG_GUI_S(30),
      clrDarkRed,
      clrWhite,
      RG_GUI_Z_BUTTON+810
   );

   ny+=RG_GUI_S(42);

   if(g_RG_GUI_NewsSelector==2)
   {
      int sg=RG_GUI_S(5);
      int sw=(pw-RG_GUI_S(20)-2*sg)/3;
      string curNames[9]={"USD","EUR","GBP","JPY","AUD","CAD","CHF","NZD","ALL"};

      for(int i=0;i<9;i++)
      {
         int col=i%3;
         int row=i/3;
         int sx=x+RG_GUI_S(10)+col*(sw+sg);
         int sy=ny+row*RG_GUI_S(30);
         bool sel=(i==8
            ? g_RG_GUI_NewsCurrencyMode==255
            : g_RG_GUI_NewsCurrencyMode!=255 &&
              (g_RG_GUI_NewsCurrencyMode&(1<<i))!=0);

         RG_GUI_CreateButton(
            RG_GUI_NewsCurrencyItemName(i),
            curNames[i],
            sx,
            sy,
            sw,
            RG_GUI_S(26),
            sel ? RG_GUI_GREEN : RG_GUI_HEADER_BG,
            sel ? clrBlack : RG_GUI_TEXT,
            RG_GUI_Z_BUTTON+850
         );
      }

      RG_GUI_CreateButton(
         RG_GUI_NewsDoneName(),
         "DONE",
         x+RG_GUI_S(10),
         ny+2*RG_GUI_S(30),
         pw-RG_GUI_S(20),
         RG_GUI_S(26),
         RG_GUI_HEADER_BG,
         RG_GUI_CYAN,
         RG_GUI_Z_BUTTON+850
      );
   }
   else if(g_RG_GUI_NewsSelector==3)
   {
      int sg=RG_GUI_S(5);
      int sw=(pw-RG_GUI_S(20)-2*sg)/3;
      string impNames[4]={"HIGH","MED","LOW","ALL"};

      for(int i=0;i<4;i++)
      {
         int col=i%3;
         int row=i/3;
         int sx=x+RG_GUI_S(10)+col*(sw+sg);
         int sy=ny+row*RG_GUI_S(30);
         bool sel=(i==0
            ? ((g_RG_GUI_NewsImpactMode&1)!=0)
            : i==1
            ? ((g_RG_GUI_NewsImpactMode&2)!=0)
            : i==2
            ? ((g_RG_GUI_NewsImpactMode&4)!=0)
            : g_RG_GUI_NewsImpactMode==7);

         RG_GUI_CreateButton(
            RG_GUI_NewsImpactItemName(i),
            impNames[i],
            sx,
            sy,
            sw,
            RG_GUI_S(26),
            sel ? RG_GUI_RED : RG_GUI_HEADER_BG,
            RG_GUI_TEXT,
            RG_GUI_Z_BUTTON+850
         );
      }

      RG_GUI_CreateButton(
         RG_GUI_NewsDoneName(),
         "DONE",
         x+RG_GUI_S(10),
         ny+2*RG_GUI_S(30),
         pw-RG_GUI_S(20),
         RG_GUI_S(26),
         RG_GUI_HEADER_BG,
         RG_GUI_CYAN,
         RG_GUI_Z_BUTTON+850
      );
   }

   if(g_RG_GUI_NewsSelector==0)
   {
      int infoY=newsTop+RG_GUI_S(116);

      RG_GUI_CreateText(
         RG_GUI_NewsSourceName(),
         "SOURCE: FOREXFACTORY",
         x+RG_GUI_S(12),
         infoY,
         RG_GUI_MUTED,
         RG_GUI_FS(7),
         RG_GUI_Z_TEXT+20
      );

      RG_GUI_CreateText(
         RG_GUI_NewsStatusName(),
         "TIME + CURRENCY + IMPACT | SERVER TIME",
         x+RG_GUI_S(12),
         infoY+RG_GUI_S(14),
         RG_GUI_MUTED,
         RG_GUI_FS(6),
         RG_GUI_Z_TEXT+20
      );

      RG_GUI_CreateText(
         RG_GUI_NEWS_PREFIX+"FUTURE",
         "TODAY NEWS ONLY",
         x+RG_GUI_S(12),
         infoY+RG_GUI_S(28),
         RG_GUI_MUTED,
         RG_GUI_FS(6),
         RG_GUI_Z_TEXT+20
      );
   }

   // Draw the session visualization whenever the Tools surface is rebuilt.
   // This is independent from the panel controls and uses Broker Server Time.
   RG_GUI_DrawMarketSessions();

   ChartRedraw();
}

void RG_GUI_ToggleSpecialTimes()
{
   g_RG_GUI_SpecialTimesOpen=!g_RG_GUI_SpecialTimesOpen;
   RG_CreatePanel();

   // Rebuilds delete chart objects, including cached News labels.
   // Redraw News immediately after the Special Times dropdown changes.
   RG_NewsUiChanged();
}

void RG_GUI_ToggleTools()
{
   g_RG_GUI_ToolsOpen=!g_RG_GUI_ToolsOpen;
   RG_CreatePanel();
}

void RG_GUI_UpdateToolsPanel()
{
   if(!g_RG_GUI_ToolsOpen) return;

   // Keep Market Sessions controls synchronized with runtime state.
   string sn=RG_GUI_SessionControlName("ON_VALUE");
   if(ObjectFind(0,sn)>=0)
   {
      if(g_RG_GUI_SessionsEnabled)
         ObjectSetString(0,sn,OBJPROP_TEXT,"ON");
      else
         ObjectSetString(0,sn,OBJPROP_TEXT,"OFF");
      if(g_RG_GUI_SessionsEnabled)
      {
         ObjectSetInteger(0,sn,OBJPROP_BGCOLOR,RG_GUI_GREEN);
         ObjectSetInteger(0,sn,OBJPROP_COLOR,clrBlack);
      }
      else
      {
         ObjectSetInteger(0,sn,OBJPROP_BGCOLOR,RG_GUI_HEADER_BG);
         ObjectSetInteger(0,sn,OBJPROP_COLOR,RG_GUI_TEXT);
      }
   }

   sn=RG_GUI_SessionControlName("CURRENT_VALUE");
   if(ObjectFind(0,sn)>=0)
   {
      if(g_RG_GUI_SessionsCurrent)
         ObjectSetString(0,sn,OBJPROP_TEXT,"ON");
      else
         ObjectSetString(0,sn,OBJPROP_TEXT,"OFF");
      if(g_RG_GUI_SessionsCurrent)
      {
         ObjectSetInteger(0,sn,OBJPROP_BGCOLOR,RG_GUI_GREEN);
         ObjectSetInteger(0,sn,OBJPROP_COLOR,clrBlack);
      }
      else
      {
         ObjectSetInteger(0,sn,OBJPROP_BGCOLOR,RG_GUI_HEADER_BG);
         ObjectSetInteger(0,sn,OBJPROP_COLOR,RG_GUI_TEXT);
      }
   }

   sn=RG_GUI_SessionControlName("FUTURE_VALUE");
   if(ObjectFind(0,sn)>=0)
      ObjectSetString(0,sn,OBJPROP_TEXT,IntegerToString(g_RG_GUI_SessionsFuture));

   sn=RG_GUI_SessionControlName("LABELS_VALUE");
   if(ObjectFind(0,sn)>=0)
   {
      if(g_RG_GUI_SessionsLabels)
         ObjectSetString(0,sn,OBJPROP_TEXT,"ON");
      else
         ObjectSetString(0,sn,OBJPROP_TEXT,"OFF");
      if(g_RG_GUI_SessionsLabels)
      {
         ObjectSetInteger(0,sn,OBJPROP_BGCOLOR,RG_GUI_GREEN);
         ObjectSetInteger(0,sn,OBJPROP_COLOR,clrBlack);
      }
      else
      {
         ObjectSetInteger(0,sn,OBJPROP_BGCOLOR,RG_GUI_HEADER_BG);
         ObjectSetInteger(0,sn,OBJPROP_COLOR,RG_GUI_TEXT);
      }
   }

   string sec=RG_GUI_ST_SpecialTimesSectionName();
   if(ObjectFind(0,sec)>=0)
   {
      if(g_RG_GUI_SpecialTimesOpen)
         ObjectSetString(0,sec,OBJPROP_TEXT,"SPECIAL TIMES   [ - ]");
      else
         ObjectSetString(0,sec,OBJPROP_TEXT,"SPECIAL TIMES   [ + ]");
   }

   if(g_RG_GUI_SpecialTimesOpen)
   {
      string dwn=RG_GUI_ST_DisplayWindowName();
      string lmn=RG_GUI_ST_LabelModeName();
      if(ObjectFind(0,dwn)>=0)
      {
         bool first=(RG_SpecialTimesGetDisplayWindow()==RG_ST_DISPLAY_FIRST_INDICATOR);
         if(first)
            ObjectSetString(0,dwn,OBJPROP_TEXT,"WINDOW: 1ST INDICATOR");
         else
            ObjectSetString(0,dwn,OBJPROP_TEXT,"WINDOW: MAIN");
      }
      if(ObjectFind(0,lmn)>=0)
      {
         bool timeOnly=(RG_SpecialTimesGetLabelMode()==RG_ST_LABEL_TIME_ONLY);
         if(timeOnly)
            ObjectSetString(0,lmn,OBJPROP_TEXT,"LABEL: TIME ONLY");
         else
            ObjectSetString(0,lmn,OBJPROP_TEXT,"LABEL: TIME + LABEL");
      }
      for(int i=0;i<10;i++)
      {
         string en=RG_GUI_ST_EnableName(i);
         string ln=RG_GUI_ST_LabelName(i);
         string cn=RG_GUI_ST_ColorName(i);
         if(ObjectFind(0,en)>=0)
         {
            bool v=RG_SpecialTimesGetEnabled(i);
            if(v)
               ObjectSetString(0,en,OBJPROP_TEXT,"ON");
            else
               ObjectSetString(0,en,OBJPROP_TEXT,"OFF");
            if(v)
               ObjectSetInteger(0,en,OBJPROP_BGCOLOR,RG_GUI_GREEN);
            else
               ObjectSetInteger(0,en,OBJPROP_BGCOLOR,RG_GUI_HEADER_BG);
            if(v)
               ObjectSetInteger(0,en,OBJPROP_COLOR,clrBlack);
            else
               ObjectSetInteger(0,en,OBJPROP_COLOR,RG_GUI_TEXT);
         }
         if(ObjectFind(0,ln)>=0)
            ObjectSetString(0,ln,OBJPROP_TEXT,"LB"+IntegerToString(i+1));
         if(ObjectFind(0,cn)>=0)
            ObjectSetInteger(0,cn,OBJPROP_BGCOLOR,RG_SpecialTimesGetColor(i));
      }
   }

   if(ObjectFind(0,RG_GUI_NewsEnableName())>=0)
   {
      bool on=g_RG_GUI_NewsEnabled;
      if(on)
         ObjectSetString(0,RG_GUI_NewsEnableName(),OBJPROP_TEXT,"NEWS: ON");
      else
         ObjectSetString(0,RG_GUI_NewsEnableName(),OBJPROP_TEXT,"NEWS: OFF");
      if(on)
         ObjectSetInteger(0,RG_GUI_NewsEnableName(),OBJPROP_BGCOLOR,RG_GUI_GREEN);
      else
         ObjectSetInteger(0,RG_GUI_NewsEnableName(),OBJPROP_BGCOLOR,RG_GUI_HEADER_BG);
      if(on)
         ObjectSetInteger(0,RG_GUI_NewsEnableName(),OBJPROP_COLOR,clrBlack);
      else
         ObjectSetInteger(0,RG_GUI_NewsEnableName(),OBJPROP_COLOR,RG_GUI_TEXT);
   }
   if(ObjectFind(0,RG_GUI_NewsCurrencyName())>=0)
      ObjectSetString(0,RG_GUI_NewsCurrencyName(),OBJPROP_TEXT,RG_GUI_NewsCurrencyText());
   if(ObjectFind(0,RG_GUI_NewsImpactName())>=0)
      ObjectSetString(0,RG_GUI_NewsImpactName(),OBJPROP_TEXT,RG_GUI_NewsImpactText());
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
   // RG_RuntimeMaxOpenPositions() is a trading limit, not a UI row reservation.
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

   if(g_RG_GUI_ToolsOpen)
   {
         int specialH=(g_RG_GUI_SpecialTimesOpen ? RG_GUI_S(360) : RG_GUI_S(48));
      int newsH=RG_GUI_S(176);
      if(!g_RG_GUI_NewsOpen) newsH=RG_GUI_S(42);
      
      else if(g_RG_GUI_NewsSelector==2) newsH=RG_GUI_S(286);
      else if(g_RG_GUI_NewsSelector==3) newsH=RG_GUI_S(226);
      int sessionH=(g_RG_GUI_SessionsOpen ? RG_GUI_S(138) : RG_GUI_S(44));
       int toolsH=sessionH+specialH+newsH+RG_GUI_S(20);
      L.panelH=RG_GUI_HEADER_H+RG_GUI_TAB_H+RG_GUI_S(4)+toolsH+RG_GUI_S(8);
   }

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

   RG_GUI_CreateTabButtons(x,y,w);
   RG_GUI_CreateToolsPanel();

   if(g_RG_GUI_ToolsOpen)
   {
      g_RG_GUI_LastChartWidth=
         (int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
      ChartRedraw();
      return(true);
   }

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
      RG_GUI_S(54),
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
      RG_GUI_AUTO_RF,
      (RG_AutoRiskFreeEnabled() ? "AUTO RF: ON" : "AUTO RF: OFF"),
      L.actionX+
      L.actionW+
      L.actionGap,
      L.utilityY,
      L.actionW,
      RG_GUI_BUTTON_H,
      (RG_AutoRiskFreeEnabled() ? RG_GUI_GREEN : RG_GUI_HEADER_BG),
      (RG_AutoRiskFreeEnabled() ? clrBlack : RG_GUI_TEXT),
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
      L.marketY+RG_GUI_S(43),
      RG_GUI_MUTED,
      RG_GUI_MARKET_TEXT_SIZE,
      RG_GUI_Z_TEXT
   );

   RG_GUI_CreateText(
      RG_GUI_MARKET_MAXLOT,
      "",
      x+RG_GUI_PAD+((w-(2*RG_GUI_PAD))/2),
      L.marketY+RG_GUI_S(43),
      RG_GUI_MUTED,
      RG_GUI_MARKET_TEXT_SIZE,
      RG_GUI_Z_TEXT
   );

   RG_GUI_CreateText(
      RG_GUI_PROFIT,
      "",
      x+RG_GUI_PAD+RG_GUI_S(14),
      L.marketY+RG_GUI_S(78),
      RG_GUI_GREEN,
      RG_GUI_MARKET_TEXT_SIZE,
      RG_GUI_Z_TEXT
   );

   RG_GUI_CreateText(
      RG_GUI_MARKET_SERVER,
      "",
      x+RG_GUI_PAD+((w-(2*RG_GUI_PAD))/2),
      L.marketY+RG_GUI_S(78),
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
      RG_GUI_BALANCE_TEXT,
      "",
      x+(w/4),
      L.footerY+RG_GUI_S(27),
      RG_GUI_MUTED,
      RG_GUI_BALANCE_SIZE,
      RG_GUI_Z_TEXT
   );

   ObjectSetInteger(0,RG_GUI_BALANCE_TEXT,OBJPROP_ANCHOR,ANCHOR_CENTER);

   RG_GUI_CreateText(
      RG_GUI_PL_TEXT,
      "",
      x+((w*3)/4),
      L.footerY+RG_GUI_S(27),
      RG_GUI_MUTED,
      RG_GUI_BALANCE_SIZE,
      RG_GUI_Z_TEXT
   );

   ObjectSetInteger(0,RG_GUI_PL_TEXT,OBJPROP_ANCHOR,ANCHOR_CENTER);

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

   // News objects are intentionally excluded from RG_DeletePanel(), so
   // switching Trade/Tools does not erase chart news.
   if(g_RG_GUI_NewsEnabled && g_RG_NewsDrawDirty)
      RG_NewsDraw();

   ChartRedraw();

   return(true);
}

//====================================================
// Closed-account P/L
//====================================================

double RG_GUI_ClosedPL()
{
   datetime now=TimeCurrent();
   datetime start=0;

   if(RG_RuntimePanelPLPeriod()==RG_PL_TODAY)
      start=StrToTime(TimeToString(now,TIME_DATE));
   else if(RG_RuntimePanelPLPeriod()==RG_PL_WEEK)
   {
      datetime dayStart=StrToTime(TimeToString(now,TIME_DATE));
      int dow=TimeDayOfWeek(dayStart);
      start=dayStart-(((dow+6)%7)*86400);
   }
   else if(RG_RuntimePanelPLPeriod()==RG_PL_MONTH)
   {
      string ds=TimeToString(now,TIME_DATE);
      start=StrToTime(StringSubstr(ds,0,8)+"01");
   }

   double total=0.0;
   for(int i=OrdersHistoryTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         continue;
      if(OrderType()!=OP_BUY && OrderType()!=OP_SELL)
         continue;
      if(RG_RuntimePanelPLPeriod()!=RG_PL_ALL && OrderCloseTime()<start)
         continue;
      total+=OrderProfit()+OrderSwap()+OrderCommission();
   }
   return(total);
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
            RG_RuntimeMaxLot(),
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
         IntegerToString(RG_RuntimeMaxOpenPositions()),
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

   double closedPL=RG_GUI_ClosedPL();
   string periodName=
      (RG_RuntimePanelPLPeriod()==RG_PL_TODAY ? "Today" :
       RG_RuntimePanelPLPeriod()==RG_PL_WEEK ? "Week" :
       RG_RuntimePanelPLPeriod()==RG_PL_MONTH ? "Month" : "All");

   if(ObjectFind(0,RG_GUI_BALANCE_TEXT)>=0)
   {
      RG_GUI_SetText(
         RG_GUI_BALANCE_TEXT,
         "Balance : "+DoubleToString(AccountBalance(),2),
         RG_GUI_MUTED
      );
   }

   if(ObjectFind(0,RG_GUI_PL_TEXT)>=0)
   {
      RG_GUI_SetText(
         RG_GUI_PL_TEXT,
         periodName+" P/L : "+
         (closedPL>=0.0 ? "+$" : "-$")+
         DoubleToString(MathAbs(closedPL),2),
         (closedPL>0.0 ? RG_GUI_GREEN :
          closedPL<0.0 ? RG_GUI_RED : RG_GUI_MUTED)
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
   RG_RuntimeSyncInputDefaults();
   RefreshRates();
   RG_GUI_UpdateToolsPanel();

   if(ObjectFind(0,RG_GUI_AUTO_RF)>=0)
   {
      bool autoRF=RG_AutoRiskFreeEnabled();

      ObjectSetInteger(
         0,
         RG_GUI_AUTO_RF,
         OBJPROP_BGCOLOR,
         (autoRF ? RG_GUI_GREEN : RG_GUI_HEADER_BG)
      );

      ObjectSetInteger(
         0,
         RG_GUI_AUTO_RF,
         OBJPROP_COLOR,
         (autoRF ? clrBlack : RG_GUI_TEXT)
      );

      ObjectSetString(
         0,
         RG_GUI_AUTO_RF,
         OBJPROP_TEXT,
         (autoRF ? "AUTO RF: ON" : "AUTO RF: OFF")
      );
   }

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

   // Tools tab has its own content and panel height. Do not run Trade-tab
   // position/market/footer layout updates while Tools is visible.
   if(g_RG_GUI_ToolsOpen)
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

      // Special Times are chart-anchored to the bottom edge and must
      // never move with the draggable RiskGuard panel.
      if(StringFind(name,"RG_ST_",0)==0)
         continue;

      // News markers are chart-timeline objects, not panel objects.
      // Never move them when the RiskGuard panel is dragged.
      if(StringFind(name,RG_NEWS_OBJ_PREFIX,0)==0)
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