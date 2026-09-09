#ifndef __RG_SPECIAL_TIMES_MQH__
#define __RG_SPECIAL_TIMES_MQH__

//====================================================
// RiskGuard MT4 - SPECIAL TIMES RG-067-023
//
// - 10 daily events
// - Broker server time (TimeCurrent)
// - current trading day only
// - hide events more than 30 minutes in the past
// - visible only on M1 / M5 / M15 / H1
// - event marker is aligned to the actual chart time axis
// - bottom timeline is chart-anchored and never moves with GUI panel
//====================================================

enum RG_ST_DisplayWindowMode
{
   RG_ST_DISPLAY_MAIN_CHART=0,
   RG_ST_DISPLAY_FIRST_INDICATOR=1
};

enum RG_ST_LabelDisplayMode
{
   RG_ST_LABEL_TIME_AND_LABEL=0,
   RG_ST_LABEL_TIME_ONLY=1
};

input bool RG_ST_Enable=true;
input RG_ST_DisplayWindowMode RG_ST_DisplayWindow=RG_ST_DISPLAY_MAIN_CHART;
input RG_ST_LabelDisplayMode RG_ST_LabelMode=RG_ST_LABEL_TIME_AND_LABEL;
input int  RG_ST_BarHeight=26;
input int  RG_ST_BarMargin=4;
input int  RG_ST_FontSize=9;
input string RG_ST_Font="Arial";

input string RG_ST_01_Time="03:00"; input string RG_ST_01_Label="NONE"; input color RG_ST_01_Color=clrGold; input bool RG_ST_01_Enable=false;
input string RG_ST_02_Time="08:00"; input string RG_ST_02_Label="NONE"; input color RG_ST_02_Color=clrOrange; input bool RG_ST_02_Enable=false;
input string RG_ST_03_Time="09:00"; input string RG_ST_03_Label="NONE"; input color RG_ST_03_Color=clrAqua; input bool RG_ST_03_Enable=false;
input string RG_ST_04_Time="10:00"; input string RG_ST_04_Label="GOOD FOR X"; input color RG_ST_04_Color=clrLime; input bool RG_ST_04_Enable=false;
input string RG_ST_05_Time="11:30"; input string RG_ST_05_Label="LONDON"; input color RG_ST_05_Color=clrViolet; input bool RG_ST_05_Enable=false;
input string RG_ST_06_Time="13:30"; input string RG_ST_06_Label="NONE"; input color RG_ST_06_Color=clrTomato; input bool RG_ST_06_Enable=false;
input string RG_ST_07_Time="15:00"; input string RG_ST_07_Label="NONE"; input color RG_ST_07_Color=clrDeepSkyBlue; input bool RG_ST_07_Enable=false;
input string RG_ST_08_Time="16:00"; input string RG_ST_08_Label="IMPORTANT"; input color RG_ST_08_Color=clrWhite; input bool RG_ST_08_Enable=false;
input string RG_ST_09_Time="19:00"; input string RG_ST_09_Label="GOOD FOR CONTINUE"; input color RG_ST_09_Color=clrYellow; input bool RG_ST_09_Enable=false;
input string RG_ST_10_Time="23:55"; input string RG_ST_10_Label="MARKET CLOSE"; input color RG_ST_10_Color=clrAqua; input bool RG_ST_10_Enable=false;

#define RG_ST_PREFIX "RG_ST_"
#define RG_ST_BAR RG_ST_PREFIX+"BAR"
#define RG_ST_EVENT_PREFIX RG_ST_PREFIX+"EVENT_"
#define RG_ST_MARK_PREFIX RG_ST_PREFIX+"MARK_"
#define RG_ST_GV_PREFIX "RG_ST_CFG_"
// Must match RG_GUI object names without depending on RG_GUI include order.
#define RG_ST_GUI_TOOLS_PREFIX "RG_TOOLS_ST_"

struct RG_ST_Event { bool enabled; string hhmm; string label; color textColor; int minutes; };
RG_ST_Event g_RG_ST_Events[10];
bool g_RG_ST_Initialized=false;
RG_ST_DisplayWindowMode g_RG_ST_DisplayWindowMode=RG_ST_DISPLAY_MAIN_CHART;
RG_ST_LabelDisplayMode g_RG_ST_LabelDisplayMode=RG_ST_LABEL_TIME_AND_LABEL;
int g_RG_ST_LastWidth=0;
int g_RG_ST_LastHeight=0;
int g_RG_ST_LastMinute=-1;

string RG_ST_ModeGV(string field)
{
   return(RG_ST_GV_PREFIX+IntegerToString(AccountNumber())+"_"+IntegerToString((int)ChartID())+"_MODE_"+field);
}

RG_ST_DisplayWindowMode RG_SpecialTimesGetDisplayWindow()
{
   return(g_RG_ST_DisplayWindowMode);
}

RG_ST_LabelDisplayMode RG_SpecialTimesGetLabelMode()
{
   return(g_RG_ST_LabelDisplayMode);
}

void RG_SpecialTimesSetDisplayWindow(RG_ST_DisplayWindowMode mode)
{
   if(mode!=RG_ST_DISPLAY_MAIN_CHART && mode!=RG_ST_DISPLAY_FIRST_INDICATOR)
      mode=RG_ST_DISPLAY_MAIN_CHART;
   if(g_RG_ST_DisplayWindowMode==mode)
   {
      GlobalVariableSet(RG_ST_ModeGV("WINDOW"),(double)mode);
      RG_SpecialTimesUpdate();
      ChartRedraw();
      return;
   }

   g_RG_ST_DisplayWindowMode=mode;
   GlobalVariableSet(RG_ST_ModeGV("WINDOW"),(double)mode);

   // OBJ_VLINE / OBJ_TEXT cannot be moved between subwindows after creation.
   // Delete and recreate them so the selected display window is actually used.
   RG_ST_DeleteObjects();
   RG_SpecialTimesUpdate();
   ChartRedraw();
}

void RG_SpecialTimesSetLabelMode(RG_ST_LabelDisplayMode mode)
{
   if(mode!=RG_ST_LABEL_TIME_AND_LABEL && mode!=RG_ST_LABEL_TIME_ONLY)
      mode=RG_ST_LABEL_TIME_AND_LABEL;
   g_RG_ST_LabelDisplayMode=mode;
   GlobalVariableSet(RG_ST_ModeGV("LABEL"),(double)mode);
   RG_SpecialTimesUpdate();
   ChartRedraw();
}

string RG_ST_GV(int i,string field)
{
   return(RG_ST_GV_PREFIX+IntegerToString(AccountNumber())+"_"+IntegerToString((int)ChartID())+"_"+IntegerToString(i+1)+"_"+field);
}

bool RG_SpecialTimesGetEnabled(int i)
{
   if(i<0 || i>=10) return(false);
   return(g_RG_ST_Events[i].enabled);
}

string RG_SpecialTimesGetTime(int i)
{
   if(i<0 || i>=10) return("");
   return(g_RG_ST_Events[i].hhmm);
}

string RG_SpecialTimesGetLabel(int i)
{
   if(i<0 || i>=10) return("");
   return(g_RG_ST_Events[i].label);
}

color RG_SpecialTimesGetColor(int i)
{
   if(i<0 || i>=10) return(clrGold);
   return(g_RG_ST_Events[i].textColor);
}

string RG_ST_ConfigFile()
{
   return("RiskGuard_ST_"+IntegerToString(AccountNumber())+"_"+IntegerToString((int)ChartID())+".dat");
}

void RG_ST_SaveFile()
{
   int h=FileOpen(RG_ST_ConfigFile(),FILE_COMMON|FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(h==INVALID_HANDLE) return;
   for(int i=0;i<10;i++)
      FileWrite(h,i,(g_RG_ST_Events[i].enabled?1:0),g_RG_ST_Events[i].minutes,(int)g_RG_ST_Events[i].textColor,g_RG_ST_Events[i].label);
   FileClose(h);
}

//====================================================
// STANDARD MT4 OBJ_EDIT
// Time/Label fields are native MT4 edit controls created by RG_GUI.
// No external Windows window, polling loop, or asynchronous keyboard
// handling is used here.
//====================================================

bool RG_ST_IsTimeObject(string name,int &idx)
{
   string prefix=RG_ST_GUI_TOOLS_PREFIX+"TIME_";
   if(StringFind(name,prefix,0)!=0) return(false);
   int n=StrToInteger(StringSubstr(name,StringLen(prefix)));
   if(n<1 || n>10) return(false);
   idx=n-1;
   return(true);
}

bool RG_ST_IsLabelObject(string name,int &idx)
{
   string prefix=RG_ST_GUI_TOOLS_PREFIX+"LABEL_";
   if(StringFind(name,prefix,0)!=0) return(false);
   int n=StrToInteger(StringSubstr(name,StringLen(prefix)));
   if(n<1 || n>10) return(false);
   idx=n-1;
   return(true);
}

bool RG_SpecialTimesBeginEdit(string objectName)
{
   // Kept for compatibility with existing EA code.
   // Standard MT4 OBJ_EDIT receives focus automatically on click.
   return(false);
}

bool RG_SpecialTimesHandleKeyDown(int key)
{
   // No custom keyboard polling. MT4 OBJ_EDIT handles keyboard input.
   return(false);
}

void RG_SpecialTimesCancelEdit()
{
   // No external editor to destroy. Kept as a compatibility no-op.
}

bool RG_ST_ParseTime(string value,int &minutes)
{
   minutes=-1;
   if(StringLen(value)!=5 || StringSubstr(value,2,1)!=":") return(false);
   int hh=(int)StringToInteger(StringSubstr(value,0,2));
   int mm=(int)StringToInteger(StringSubstr(value,3,2));
   if(hh<0||hh>23||mm<0||mm>59) return(false);
   minutes=hh*60+mm;
   return(true);
}

string RG_ST_TimeText(int minutes)
{
   if(minutes<0)return("--:--");
   int hh=minutes/60, mm=minutes%60;
   return((hh<10?"0":"")+IntegerToString(hh)+":"+(mm<10?"0":"")+IntegerToString(mm));
}

void RG_SpecialTimesSetEvent(int i,bool enabled,string hhmm,string label,color cc)
{
   if(i<0||i>=10)return;
   int mins=-1;
   if(!RG_ST_ParseTime(hhmm,mins)) enabled=false;
   if(StringLen(label)==0) label="SPECIAL "+IntegerToString(i+1);
   g_RG_ST_Events[i].enabled=enabled;
   g_RG_ST_Events[i].hhmm=RG_ST_TimeText(mins);
   g_RG_ST_Events[i].label=label;
   g_RG_ST_Events[i].textColor=cc;
   g_RG_ST_Events[i].minutes=mins;
   GlobalVariableSet(RG_ST_GV(i,"E"),enabled?1.0:0.0);
   GlobalVariableSet(RG_ST_GV(i,"M"),(double)mins);
   GlobalVariableSet(RG_ST_GV(i,"C"),(double)cc);
   GlobalVariableSet(RG_ST_GV(i,"L"),(double)0.0);
   RG_ST_SaveFile();
}

bool RG_SpecialTimesToggleEvent(int i)
{
   if(i<0||i>=10)return(false);
   g_RG_ST_Events[i].enabled=!g_RG_ST_Events[i].enabled;
   GlobalVariableSet(RG_ST_GV(i,"E"),g_RG_ST_Events[i].enabled?1.0:0.0);
   RG_ST_SaveFile();
   return(g_RG_ST_Events[i].enabled);
}

void RG_ST_LoadEvents()
{
   g_RG_ST_DisplayWindowMode=RG_ST_DisplayWindow;
   g_RG_ST_LabelDisplayMode=RG_ST_LabelMode;

   string wgv=RG_ST_ModeGV("WINDOW");
   string lgv=RG_ST_ModeGV("LABEL");
   if(GlobalVariableCheck(wgv))
   {
      int v=(int)GlobalVariableGet(wgv);
      if(v==RG_ST_DISPLAY_MAIN_CHART || v==RG_ST_DISPLAY_FIRST_INDICATOR)
         g_RG_ST_DisplayWindowMode=(RG_ST_DisplayWindowMode)v;
   }
   if(GlobalVariableCheck(lgv))
   {
      int v2=(int)GlobalVariableGet(lgv);
      if(v2==RG_ST_LABEL_TIME_AND_LABEL || v2==RG_ST_LABEL_TIME_ONLY)
         g_RG_ST_LabelDisplayMode=(RG_ST_LabelDisplayMode)v2;
   }

   string tt[10]; string ll[10]; color cc[10]; bool ee[10];
   tt[0]=RG_ST_01_Time; ll[0]=RG_ST_01_Label; cc[0]=RG_ST_01_Color; ee[0]=RG_ST_01_Enable;
   tt[1]=RG_ST_02_Time; ll[1]=RG_ST_02_Label; cc[1]=RG_ST_02_Color; ee[1]=RG_ST_02_Enable;
   tt[2]=RG_ST_03_Time; ll[2]=RG_ST_03_Label; cc[2]=RG_ST_03_Color; ee[2]=RG_ST_03_Enable;
   tt[3]=RG_ST_04_Time; ll[3]=RG_ST_04_Label; cc[3]=RG_ST_04_Color; ee[3]=RG_ST_04_Enable;
   tt[4]=RG_ST_05_Time; ll[4]=RG_ST_05_Label; cc[4]=RG_ST_05_Color; ee[4]=RG_ST_05_Enable;
   tt[5]=RG_ST_06_Time; ll[5]=RG_ST_06_Label; cc[5]=RG_ST_06_Color; ee[5]=RG_ST_06_Enable;
   tt[6]=RG_ST_07_Time; ll[6]=RG_ST_07_Label; cc[6]=RG_ST_07_Color; ee[6]=RG_ST_07_Enable;
   tt[7]=RG_ST_08_Time; ll[7]=RG_ST_08_Label; cc[7]=RG_ST_08_Color; ee[7]=RG_ST_08_Enable;
   tt[8]=RG_ST_09_Time; ll[8]=RG_ST_09_Label; cc[8]=RG_ST_09_Color; ee[8]=RG_ST_09_Enable;
   tt[9]=RG_ST_10_Time; ll[9]=RG_ST_10_Label; cc[9]=RG_ST_10_Color; ee[9]=RG_ST_10_Enable;

   for(int i=0;i<10;i++)
   {
      int mins=-1;
      RG_ST_ParseTime(tt[i],mins);
      g_RG_ST_Events[i].enabled=ee[i];
      g_RG_ST_Events[i].hhmm=RG_ST_TimeText(mins);
      g_RG_ST_Events[i].label=ll[i];
      g_RG_ST_Events[i].textColor=cc[i];
      g_RG_ST_Events[i].minutes=mins;

      string k=RG_ST_GV(i,"E"); if(GlobalVariableCheck(k)) g_RG_ST_Events[i].enabled=(GlobalVariableGet(k)>0.5);
      k=RG_ST_GV(i,"C"); if(GlobalVariableCheck(k)) g_RG_ST_Events[i].textColor=(color)((int)GlobalVariableGet(k));
   }
}

bool RG_ST_TimeframeAllowed()
{
   int tf=Period();
   return(tf==PERIOD_M1 || tf==PERIOD_M5 || tf==PERIOD_M15 || tf==PERIOD_H1);
}

void RG_ST_DeleteObjects()
{
   if(ObjectFind(0,RG_ST_BAR)>=0) ObjectDelete(0,RG_ST_BAR);
   for(int i=0;i<10;i++)
   {
      string a=RG_ST_EVENT_PREFIX+IntegerToString(i+1);
      string b=RG_ST_MARK_PREFIX+IntegerToString(i+1);
      if(ObjectFind(0,a)>=0)ObjectDelete(0,a);
      if(ObjectFind(0,b)>=0)ObjectDelete(0,b);
   }
}

bool RG_ST_CreateBar()
{
   // RG-067-014: bottom bar removed. Special Times are drawn directly
   // on the chart as native vertical time lines.
   return(true);
}

bool RG_ST_EventDateTime(int minutes,datetime &dt)
{
   if(minutes<0 || minutes>1439)return(false);
   datetime now=TimeCurrent();
   int secIntoDay=TimeHour(now)*3600+TimeMinute(now)*60+TimeSeconds(now);
   datetime todayStart=now-secIntoDay;
   dt=todayStart+(minutes*60);
   return(dt>0);
}

bool RG_ST_GetXForTime(datetime eventTime,int &x)
{
   int width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   if(width<=0)return(false);
   double price=Bid;
   if(price<=0) price=MarketInfo(Symbol(),MODE_BID);
   int yy=0,xx=0;
   if(!ChartTimePriceToXY(0,0,eventTime,price,xx,yy)) return(false);
   x=xx;
   return(x>=0 && x<=width);
}

int RG_ST_LabelWidth(string text)
{
   int n=StringLen(text);
   int w=44+(n*5);
   if(w<78) w=78;
   if(w>150) w=150;
   return(w);
}

void RG_ST_DeleteEventObject(int i)
{
   string a=RG_ST_EVENT_PREFIX+IntegerToString(i+1);
   string b=RG_ST_MARK_PREFIX+IntegerToString(i+1);
   if(ObjectFind(0,a)>=0) ObjectDelete(0,a);
   if(ObjectFind(0,b)>=0) ObjectDelete(0,b);
}

void RG_ST_DrawEvents()
{
   if(!RG_ST_TimeframeAllowed()) { RG_ST_DeleteObjects(); return; }

   datetime now=TimeCurrent();
   int secIntoDay=TimeHour(now)*3600+TimeMinute(now)*60+TimeSeconds(now);
   datetime todayStart=now-secIntoDay;
   datetime todayEnd=todayStart+86400;

   for(int i=0;i<10;i++)
   {
      if(!g_RG_ST_Events[i].enabled)
      { RG_ST_DeleteEventObject(i); continue; }

      datetime dt=0;
      if(!RG_ST_EventDateTime(g_RG_ST_Events[i].minutes,dt) ||
         dt<todayStart || dt>=todayEnd || dt<(now-1800))
      { RG_ST_DeleteEventObject(i); continue; }

      // Native vertical line: event position is tied to the actual chart time.
      // Display can be placed either on the main chart or the first indicator subwindow.
      int targetWindow=(g_RG_ST_DisplayWindowMode==RG_ST_DISPLAY_FIRST_INDICATOR ? 1 : 0);
      string mark=RG_ST_MARK_PREFIX+IntegerToString(i+1);
      if(ObjectFind(0,mark)<0)
         ObjectCreate(0,mark,OBJ_VLINE,targetWindow,dt,0);
      else
      {
         ObjectSetInteger(0,mark,OBJPROP_TIME1,dt);
      }

      ObjectSetInteger(0,mark,OBJPROP_COLOR,g_RG_ST_Events[i].textColor);
      ObjectSetInteger(0,mark,OBJPROP_STYLE,STYLE_DOT);
      ObjectSetInteger(0,mark,OBJPROP_WIDTH,1);
      ObjectSetInteger(0,mark,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,mark,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,mark,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,mark,OBJPROP_BACK,true);
      ObjectSetInteger(0,mark,OBJPROP_ZORDER,100);

      // Vertical label is drawn in the same target window, near the bottom edge.
      // Label mode can show either Time + Label or Time Only.
      string name=RG_ST_EVENT_PREFIX+IntegerToString(i+1);
      double topPrice=WindowPriceMax(targetWindow);
      double bottomPrice=WindowPriceMin(targetWindow);
      if(topPrice<=bottomPrice)
      { RG_ST_DeleteEventObject(i); continue; }

      // Stagger labels upward slightly from the bottom edge to reduce overlap.
      int level=i%4;
      double range=topPrice-bottomPrice;
      double labelPrice=bottomPrice+(range*(0.04+(level*0.045)));
      string display=(g_RG_ST_LabelDisplayMode==RG_ST_LABEL_TIME_ONLY ?
                      RG_ST_TimeText(g_RG_ST_Events[i].minutes) :
                      g_RG_ST_Events[i].label+" "+RG_ST_TimeText(g_RG_ST_Events[i].minutes));

      if(ObjectFind(0,name)<0)
         ObjectCreate(0,name,OBJ_TEXT,targetWindow,dt,labelPrice);
      else
      {
         ObjectSetInteger(0,name,OBJPROP_TIME1,dt);
         ObjectSetDouble(0,name,OBJPROP_PRICE1,labelPrice);
      }

      ObjectSetString(0,name,OBJPROP_TEXT,display);
      ObjectSetString(0,name,OBJPROP_FONT,RG_ST_Font);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,RG_ST_FontSize<7?7:RG_ST_FontSize);
      ObjectSetInteger(0,name,OBJPROP_COLOR,g_RG_ST_Events[i].textColor);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
      ObjectSetDouble(0,name,OBJPROP_ANGLE,90.0);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,120);
   }
}
void RG_SpecialTimesInit()
{
   RG_ST_LoadEvents();
   g_RG_ST_Initialized=true;
   if(!RG_ST_Enable || !RG_ST_TimeframeAllowed()){RG_ST_DeleteObjects();return;}
   RG_ST_DrawEvents();
   g_RG_ST_LastWidth=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   g_RG_ST_LastHeight=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   g_RG_ST_LastMinute=TimeMinute(TimeCurrent());
   ChartRedraw();
}

void RG_SpecialTimesUpdate()
{
   if(!g_RG_ST_Initialized){RG_SpecialTimesInit();return;}
   if(!RG_ST_Enable || !RG_ST_TimeframeAllowed()){RG_ST_DeleteObjects();return;}
   int w=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   int h=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   int m=TimeMinute(TimeCurrent());
   if(w!=g_RG_ST_LastWidth||h!=g_RG_ST_LastHeight||m!=g_RG_ST_LastMinute)
   {
      g_RG_ST_LastWidth=w;g_RG_ST_LastHeight=h;g_RG_ST_LastMinute=m;
      RG_ST_DeleteObjects();RG_ST_DrawEvents();ChartRedraw();return;
   }
   RG_ST_DrawEvents();
}

void RG_SpecialTimesDelete(){RG_ST_DeleteObjects();g_RG_ST_Initialized=false;ChartRedraw();}

#endif
