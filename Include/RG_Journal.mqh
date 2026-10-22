#ifndef __RG_JOURNAL_MQH__
#define __RG_JOURNAL_MQH__

//====================================================
// RiskGuard Journal - J-02 Rev2
// Journal is optional. When ON, a pre-trade Journal
// Checklist opens with each BUY/SELL Preview.
// SET never blocks a trade. The checklist is recorded
// as a snapshot with the resulting order.
//====================================================

#define RG_JOURNAL_FOLDER "RiskGuard\\Journal"
#define RG_JOURNAL_FILE   "RiskGuard\\Journal\\Journal.csv"
#define RG_JOURNAL_GV_PREFIX "RG_JOURNAL_"

#define RG_JOURNAL_MAX_ITEMS 100
#define RG_JOURNAL_SETTINGS_FILE "RiskGuard\\Journal\\JournalSettings.csv"

// Open the generated Excel-compatible report with the Windows default app.
// The EA must have "Allow DLL imports" enabled for this call.
#import "shell32.dll"
int ShellExecuteW(int hwnd,string operation,string file,string parameters,string directory,int showCommand);
#import

// Per-session metadata cache. Report grouping can compare the same tickets many
// times; without this cache each comparison may reopen and rescan Journal.csv.
struct RG_JournalMetaCacheItem
{
   int ticket;
   bool hasMeta;
   string pattern;
   string trigger;
   string tf;
   string conditions;
   string status;
   string lots;
   string rr;
   string flags;
};
#define RG_JOURNAL_META_CACHE_SIZE 8192
RG_JournalMetaCacheItem g_RG_JournalMetaCache[RG_JOURNAL_META_CACHE_SIZE];

void RG_JournalClearMetaCache()
{
   RG_JournalInvalidateHistoryCache();
   for(int i=0;i<RG_JOURNAL_META_CACHE_SIZE;i++)
   {
      g_RG_JournalMetaCache[i].ticket=0;
      g_RG_JournalMetaCache[i].hasMeta=false;
      g_RG_JournalMetaCache[i].pattern="";
      g_RG_JournalMetaCache[i].trigger="";
      g_RG_JournalMetaCache[i].tf="";
      g_RG_JournalMetaCache[i].conditions="";
      g_RG_JournalMetaCache[i].status="";
      g_RG_JournalMetaCache[i].lots="";
      g_RG_JournalMetaCache[i].rr="";
      g_RG_JournalMetaCache[i].flags="";
   }
}

int RG_JournalMetaCacheSlot(int ticket,bool createSlot)
{
   if(ticket<=0) return(-1);
   int slot=ticket%RG_JOURNAL_META_CACHE_SIZE;
   for(int probe=0;probe<RG_JOURNAL_META_CACHE_SIZE;probe++)
   {
      int at=(slot+probe)%RG_JOURNAL_META_CACHE_SIZE;
      if(g_RG_JournalMetaCache[at].ticket==ticket) return(at);
      if(g_RG_JournalMetaCache[at].ticket==0) return(createSlot ? at : -1);
   }
   return(-1);
}


// Cached Account History grouping. The JOURNAL DATA view used to rescan all
// history for every trade and then rescan it again for metadata/state. Build
// logical-trade groups once per history-size snapshot and reuse the group links.
struct RG_JournalHistoryCacheItem
{
   int ticket;
   int groupRoot;
   int nextGroup;
   string symbol;
   int type;
   int magic;
   datetime openTime;
   double openPrice;
   datetime closeTime;
   double lots;
   double net;
   bool hasMetaFile;
   double groupLots;
   double groupNet;
   datetime groupCloseTime;
   int groupFragments;
   int canonicalTicket;
};
RG_JournalHistoryCacheItem g_RG_JournalHistoryCache[];
int g_RG_JournalHistoryHash[65536];
int g_RG_JournalHistoryCacheTotal=-1;
bool g_RG_JournalHistoryCacheBuilding=false;

void RG_JournalInvalidateHistoryCache()
{
   g_RG_JournalHistoryCacheTotal=-1;
}

int RG_JournalHistoryFind(int ticket)
{
   if(ticket<=0) return(-1);
   int slot=ticket%65536;
   for(int probe=0;probe<65536;probe++)
   {
      int at=(slot+probe)%65536;
      int encoded=g_RG_JournalHistoryHash[at];
      if(encoded==0) return(-1);
      int idx=encoded-1;
      if(idx>=0 && idx<ArraySize(g_RG_JournalHistoryCache) && g_RG_JournalHistoryCache[idx].ticket==ticket) return(idx);
   }
   return(-1);
}

void RG_JournalHistoryHashInsert(int ticket,int index)
{
   int slot=ticket%65536;
   for(int probe=0;probe<65536;probe++)
   {
      int at=(slot+probe)%65536;
      if(g_RG_JournalHistoryHash[at]==0)
      { g_RG_JournalHistoryHash[at]=index+1; return; }
   }
}

bool RG_JournalHistoryItemsMatch(int a,int b)
{
   if(a<0 || b<0 || a>=ArraySize(g_RG_JournalHistoryCache) || b>=ArraySize(g_RG_JournalHistoryCache)) return(false);
   if(a==b) return(true);
   if(g_RG_JournalHistoryCache[a].symbol!=g_RG_JournalHistoryCache[b].symbol ||
      g_RG_JournalHistoryCache[a].type!=g_RG_JournalHistoryCache[b].type ||
      g_RG_JournalHistoryCache[a].magic!=g_RG_JournalHistoryCache[b].magic ||
      g_RG_JournalHistoryCache[a].openTime!=g_RG_JournalHistoryCache[b].openTime) return(false);
   double tol=MarketInfo(g_RG_JournalHistoryCache[a].symbol,MODE_POINT)*0.5;
   if(MathAbs(g_RG_JournalHistoryCache[a].openPrice-g_RG_JournalHistoryCache[b].openPrice)>tol) return(false);
   if(g_RG_JournalHistoryCache[a].hasMetaFile && g_RG_JournalHistoryCache[b].hasMetaFile) return(false);
   string pa="",ta="",tfa="",ca="",sa="",la="",ra="",fa="";
   string pb="",tb="",tfb="",cb="",sb="",lb="",rb="",fb="";
   bool ha=RG_JournalReadMeta(g_RG_JournalHistoryCache[a].ticket,pa,ta,tfa,ca,sa,la,ra,fa);
   bool hb=RG_JournalReadMeta(g_RG_JournalHistoryCache[b].ticket,pb,tb,tfb,cb,sb,lb,rb,fb);
   bool selectedA=((pa!="" && pa!="NONE") || (ta!="" && ta!="NONE"));
   bool selectedB=((pb!="" && pb!="NONE") || (tb!="" && tb!="NONE"));
   if(ha && hb && selectedA && selectedB && (pa!=pb || ta!=tb || tfa!=tfb)) return(false);
   return(true);
}

bool RG_JournalEnsureHistoryCache()
{
   int total=OrdersHistoryTotal();
   if(g_RG_JournalHistoryCacheTotal==total && ArraySize(g_RG_JournalHistoryCache)==total) return(true);
   if(g_RG_JournalHistoryCacheBuilding) return(false);
   g_RG_JournalHistoryCacheBuilding=true;
   ArrayInitialize(g_RG_JournalHistoryHash,0);
   ArrayResize(g_RG_JournalHistoryCache,total);
   for(int i=0;i<total;i++)
   {
      g_RG_JournalHistoryCache[i].ticket=0;
      g_RG_JournalHistoryCache[i].groupRoot=i;
      g_RG_JournalHistoryCache[i].nextGroup=-1;
      g_RG_JournalHistoryCache[i].groupLots=0.0;
      g_RG_JournalHistoryCache[i].groupNet=0.0;
      g_RG_JournalHistoryCache[i].groupCloseTime=0;
      g_RG_JournalHistoryCache[i].groupFragments=0;
      g_RG_JournalHistoryCache[i].canonicalTicket=0;
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      g_RG_JournalHistoryCache[i].ticket=OrderTicket();
      g_RG_JournalHistoryCache[i].symbol=OrderSymbol();
      g_RG_JournalHistoryCache[i].type=OrderType();
      g_RG_JournalHistoryCache[i].magic=OrderMagicNumber();
      g_RG_JournalHistoryCache[i].openTime=OrderOpenTime();
      g_RG_JournalHistoryCache[i].openPrice=OrderOpenPrice();
      g_RG_JournalHistoryCache[i].closeTime=OrderCloseTime();
      g_RG_JournalHistoryCache[i].lots=OrderLots();
      g_RG_JournalHistoryCache[i].net=OrderProfit()+OrderSwap()+OrderCommission();
      g_RG_JournalHistoryCache[i].hasMetaFile=FileIsExist(RG_JOURNAL_FOLDER+"\\Meta_"+IntegerToString(OrderTicket())+".csv");
      RG_JournalHistoryHashInsert(OrderTicket(),i);
   }
   // Each root collects only matching fragments. Cheap immutable-field checks
   // reject almost all pairs before metadata is read.
   for(int i=0;i<total;i++)
   {
      if(g_RG_JournalHistoryCache[i].ticket<=0 || g_RG_JournalHistoryCache[i].groupRoot!=i) continue;
      int root=i;
      int tail=i;
      g_RG_JournalHistoryCache[root].groupLots=g_RG_JournalHistoryCache[root].lots;
      g_RG_JournalHistoryCache[root].groupNet=g_RG_JournalHistoryCache[root].net;
      g_RG_JournalHistoryCache[root].groupCloseTime=g_RG_JournalHistoryCache[root].closeTime;
      g_RG_JournalHistoryCache[root].groupFragments=1;
      g_RG_JournalHistoryCache[root].canonicalTicket=g_RG_JournalHistoryCache[root].ticket;
      for(int j=i+1;j<total;j++)
      {
         if(g_RG_JournalHistoryCache[j].ticket<=0 || g_RG_JournalHistoryCache[j].groupRoot!=j) continue;
         if(!RG_JournalHistoryItemsMatch(root,j)) continue;
         g_RG_JournalHistoryCache[j].groupRoot=root;
         g_RG_JournalHistoryCache[tail].nextGroup=j;
         tail=j;
         g_RG_JournalHistoryCache[root].groupLots+=g_RG_JournalHistoryCache[j].lots;
         g_RG_JournalHistoryCache[root].groupNet+=g_RG_JournalHistoryCache[j].net;
         if(g_RG_JournalHistoryCache[j].closeTime>g_RG_JournalHistoryCache[root].groupCloseTime ||
            (g_RG_JournalHistoryCache[j].closeTime==g_RG_JournalHistoryCache[root].groupCloseTime && g_RG_JournalHistoryCache[j].ticket<g_RG_JournalHistoryCache[root].canonicalTicket))
         {
            g_RG_JournalHistoryCache[root].groupCloseTime=g_RG_JournalHistoryCache[j].closeTime;
            g_RG_JournalHistoryCache[root].canonicalTicket=g_RG_JournalHistoryCache[j].ticket;
         }
         g_RG_JournalHistoryCache[root].groupFragments++;
      }
   }
   g_RG_JournalHistoryCacheTotal=total;
   g_RG_JournalHistoryCacheBuilding=false;
   return(true);
}


bool g_RG_JournalReady=false;
int g_RG_JournalLastExportError=0;
bool g_RG_JournalEnabled=true;
// 0 = checklist before SET; 1 = checklist after order execution.
int g_RG_JournalEntryMode=0;
int g_RG_JournalAfterEntryTicket=0;

struct RG_JournalListItem
{
   int id;
   string name;
   bool selected;
};

RG_JournalListItem g_RG_JournalConditions[RG_JOURNAL_MAX_ITEMS];
RG_JournalListItem g_RG_JournalPatterns[RG_JOURNAL_MAX_ITEMS];
RG_JournalListItem g_RG_JournalTriggers[RG_JOURNAL_MAX_ITEMS];
int g_RG_JournalConditionCount=0;
int g_RG_JournalPatternCount=0;
int g_RG_JournalTriggerCount=0;

// Current Preview Journal state.
bool g_RG_JournalPreviewOpen=false;
int g_RG_JournalPreviewDirection=-1;
bool g_RG_JournalPreviewPatterns[RG_JOURNAL_MAX_ITEMS];
bool g_RG_JournalPreviewTriggers[RG_JOURNAL_MAX_ITEMS];
bool g_RG_JournalPreviewTFs[9];
bool g_RG_JournalPreviewConditions[RG_JOURNAL_MAX_ITEMS];
bool g_RG_JournalPreviewRR=false;
bool g_RG_JournalPreviewVolume=false;
bool g_RG_JournalPreviewSL=false;
bool g_RG_JournalPreviewTP=false;

string RG_JournalGV(string suffix)
{
   return(RG_JOURNAL_GV_PREFIX+IntegerToString(AccountNumber())+"_"+suffix);
}

string RG_JournalDate(datetime t){ return(TimeToString(t,TIME_DATE)); }
string RG_JournalTime(datetime t){ return(TimeToString(t,TIME_SECONDS)); }

string RG_JournalDay(datetime t)
{
   int d=TimeDayOfWeek(t);
   string names[7]={"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
   if(d<0 || d>6) return("");
   return(names[d]);
}

string RG_JournalTypeName(int type)
{
   if(type==OP_BUY) return("BUY");
   if(type==OP_SELL) return("SELL");
   return("OTHER");
}

bool RG_JournalIsMarketType(int type){ return(type==OP_BUY || type==OP_SELL); }

datetime RG_JournalBrokerToSystem(datetime brokerTime)
{
   if(brokerTime<=0) return(0);
   return(TimeLocal()-(TimeCurrent()-brokerTime));
}

string RG_JournalSession(datetime brokerTime)
{
   if(brokerTime<=0) return("");
   datetime midnight=StrToTime(TimeToString(brokerTime,TIME_DATE));
   string found="";
   for(int dayShift=-1;dayShift<=1;dayShift++)
   {
      for(int si=0;si<4;si++)
      {
         datetime st=RG_GUI_SessionStartForDate(midnight,si,dayShift);
         datetime en=st+RG_GUI_SessionDurationHours(si)*3600;
         if(brokerTime>=st && brokerTime<en)
         {
            if(StringLen(found)>0) found+=" + ";
            found+=RG_GUI_SessionName(si);
         }
      }
   }
   return(found);
}

string RG_JournalTFName(int tf)
{
   if(tf==PERIOD_M1) return("M1");
   if(tf==PERIOD_M5) return("M5");
   if(tf==PERIOD_M15) return("M15");
   if(tf==PERIOD_M30) return("M30");
   if(tf==PERIOD_H1) return("H1");
   if(tf==PERIOD_H4) return("H4");
   if(tf==PERIOD_D1) return("D1");
   if(tf==PERIOD_W1) return("W1");
   if(tf==PERIOD_MN1) return("MN1");
   return(IntegerToString(tf));
}

double RG_JournalRR(double entry,double sl,double tp)
{
   double risk=MathAbs(entry-sl), reward=MathAbs(tp-entry);
   if(risk<=0.0 || reward<=0.0) return(0.0);
   return(reward/risk);
}

string RG_JournalRRText(double entry,double sl,double tp)
{
   double rr=RG_JournalRR(entry,sl,tp);
   if(rr<=0.0) return("-");
   return("1:"+DoubleToString(rr,2));
}

double RG_JournalRiskMoney(string symbol,double entry,double sl,double lots)
{
   if(symbol=="" || entry<=0.0 || sl<=0.0 || lots<=0.0) return(0.0);
   double tickValue=MarketInfo(symbol,MODE_TICKVALUE);
   double tickSize=MarketInfo(symbol,MODE_TICKSIZE);
   if(tickValue<=0.0 || tickSize<=0.0) return(0.0);
   return(MathAbs(entry-sl)/tickSize*tickValue*lots);
}

//====================================================
// Settings lists
//====================================================
string RG_JournalClean(string s)
{
   StringTrimLeft(s); StringTrimRight(s);
   StringReplace(s,";",",");
   if(StringLen(s)>48) s=StringSubstr(s,0,48);
   return(s);
}

void RG_JournalClearLists()
{
   g_RG_JournalConditionCount=0;
   g_RG_JournalPatternCount=0;
   g_RG_JournalTriggerCount=0;
   for(int i=0;i<RG_JOURNAL_MAX_ITEMS;i++)
   {
      g_RG_JournalConditions[i].id=0; g_RG_JournalConditions[i].name=""; g_RG_JournalConditions[i].selected=false;
      g_RG_JournalPatterns[i].id=0; g_RG_JournalPatterns[i].name=""; g_RG_JournalPatterns[i].selected=false;
      g_RG_JournalTriggers[i].id=0; g_RG_JournalTriggers[i].name=""; g_RG_JournalTriggers[i].selected=false;
      g_RG_JournalPreviewConditions[i]=false;
      g_RG_JournalPreviewPatterns[i]=false;
      g_RG_JournalPreviewTriggers[i]=false;
   }
   for(int tfi=0;tfi<9;tfi++) g_RG_JournalPreviewTFs[tfi]=false;
}

int RG_JournalNextId(RG_JournalListItem &a[],int count)
{
   int mx=0;
   for(int i=0;i<count;i++) if(a[i].id>mx) mx=a[i].id;
   return(mx+1);
}

bool RG_JournalHasPatternName(string n)
{
   for(int i=0;i<g_RG_JournalPatternCount;i++) if(g_RG_JournalPatterns[i].name==n) return(true);
   return(false);
}
bool RG_JournalHasTriggerName(string n)
{
   for(int i=0;i<g_RG_JournalTriggerCount;i++) if(g_RG_JournalTriggers[i].name==n) return(true);
   return(false);
}
bool RG_JournalHasConditionName(string n)
{
   for(int i=0;i<g_RG_JournalConditionCount;i++) if(g_RG_JournalConditions[i].name==n) return(true);
   return(false);
}

void RG_JournalAddDefaults()
{
   // J05: seed every requested default that is missing.
   // Existing user-defined entries are preserved and defaults are never duplicated.
   string p[15]={"ELLIOTT WAVES","SWING BANDS","SWING I.F.S","QM I.F.S","PB","PB&CH-T","I.F.S(H)","TST","BPB","AB=CD","ReAB=CD","HARMONIC","CLASSIC","N.B.T","SURFFING"};
   string t[7]={"RD","X","V.D.T","BREAKOUT","TREND LINE","AB=CD","TOUCH"};
   string c[6]={"T.T.M","MA POSITION","NO ANTI AB=CD","NO ANTI BPB","NO ANTI RD","NO ANTI RALLY"};
   for(int i=0;i<15;i++) if(!RG_JournalHasPatternName(p[i])) RG_JournalAddPatternNoSave(p[i]);
   for(int j=0;j<7;j++) if(!RG_JournalHasTriggerName(t[j])) RG_JournalAddTriggerNoSave(t[j]);

   // Conditions are user-configurable: seed defaults only when no conditions
   // exist yet. Do not silently re-add deleted defaults, because each trader
   // may intentionally keep a different number of conditions (including one).
   if(g_RG_JournalConditionCount==0)
      for(int k=0;k<6;k++) RG_JournalAddConditionNoSave(c[k]);
}

int RG_JournalAddPatternNoSave(string n){ if(g_RG_JournalPatternCount>=RG_JOURNAL_MAX_ITEMS)return(-1); int i=g_RG_JournalPatternCount; g_RG_JournalPatterns[i].id=RG_JournalNextId(g_RG_JournalPatterns,g_RG_JournalPatternCount); g_RG_JournalPatterns[i].name=n; g_RG_JournalPatterns[i].selected=false; g_RG_JournalPatternCount++; return(i); }
int RG_JournalAddTriggerNoSave(string n){ if(g_RG_JournalTriggerCount>=RG_JOURNAL_MAX_ITEMS)return(-1); int i=g_RG_JournalTriggerCount; g_RG_JournalTriggers[i].id=RG_JournalNextId(g_RG_JournalTriggers,g_RG_JournalTriggerCount); g_RG_JournalTriggers[i].name=n; g_RG_JournalTriggers[i].selected=false; g_RG_JournalTriggerCount++; return(i); }
int RG_JournalAddConditionNoSave(string n){ if(g_RG_JournalConditionCount>=RG_JOURNAL_MAX_ITEMS)return(-1); int i=g_RG_JournalConditionCount; g_RG_JournalConditions[i].id=RG_JournalNextId(g_RG_JournalConditions,g_RG_JournalConditionCount); g_RG_JournalConditions[i].name=n; g_RG_JournalConditions[i].selected=false; g_RG_JournalConditionCount++; return(i); }

void RG_JournalSaveSettings()
{
   int h=FileOpen(RG_JOURNAL_SETTINGS_FILE,FILE_CSV|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h==INVALID_HANDLE) return;
   FileWrite(h,"TYPE","ID","NAME");
   for(int i=0;i<g_RG_JournalConditionCount;i++) FileWrite(h,"C",g_RG_JournalConditions[i].id,g_RG_JournalConditions[i].name);
   for(int j=0;j<g_RG_JournalPatternCount;j++) FileWrite(h,"P",g_RG_JournalPatterns[j].id,g_RG_JournalPatterns[j].name);
   for(int k=0;k<g_RG_JournalTriggerCount;k++) FileWrite(h,"T",g_RG_JournalTriggers[k].id,g_RG_JournalTriggers[k].name);
   FileWrite(h,"E",g_RG_JournalEnabled?1:0,"");
   FileWrite(h,"M",g_RG_JournalEntryMode,"");
   FileClose(h);
}

void RG_JournalLoadSettings()
{
   RG_JournalClearLists();
   int h=FileOpen(RG_JOURNAL_SETTINGS_FILE,FILE_CSV|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h!=INVALID_HANDLE)
   {
      if(!FileIsEnding(h)){ FileReadString(h); FileReadString(h); FileReadString(h); }
      while(!FileIsEnding(h))
      {
         string typ=FileReadString(h); if(StringLen(typ)==0) break;
         string sid=FileReadString(h); string name=FileReadString(h);
         int id=(int)StrToInteger(sid);
         if(typ=="C" && g_RG_JournalConditionCount<RG_JOURNAL_MAX_ITEMS){ g_RG_JournalConditions[g_RG_JournalConditionCount].id=id; g_RG_JournalConditions[g_RG_JournalConditionCount].name=RG_JournalClean(name); g_RG_JournalConditionCount++; }
         else if(typ=="P" && g_RG_JournalPatternCount<RG_JOURNAL_MAX_ITEMS){ g_RG_JournalPatterns[g_RG_JournalPatternCount].id=id; g_RG_JournalPatterns[g_RG_JournalPatternCount].name=RG_JournalClean(name); g_RG_JournalPatternCount++; }
         else if(typ=="T" && g_RG_JournalTriggerCount<RG_JOURNAL_MAX_ITEMS){ g_RG_JournalTriggers[g_RG_JournalTriggerCount].id=id; g_RG_JournalTriggers[g_RG_JournalTriggerCount].name=RG_JournalClean(name); g_RG_JournalTriggerCount++; }
         else if(typ=="E") g_RG_JournalEnabled=(id!=0);
         else if(typ=="M") g_RG_JournalEntryMode=(id==1?1:0);
      }
      FileClose(h);
   }
   RG_JournalAddDefaults();
   RG_JournalSaveSettings();
}

bool RG_JournalEnabled(){ return(g_RG_JournalEnabled); }
int RG_JournalEntryMode(){ return(g_RG_JournalEntryMode); }
void RG_JournalSetEntryMode(int mode){ g_RG_JournalEntryMode=(mode==1?1:0); RG_JournalSaveSettings(); }
void RG_JournalToggleEntryMode(){ RG_JournalSetEntryMode(g_RG_JournalEntryMode==0?1:0); }
void RG_JournalToggleEnabled(){ g_RG_JournalEnabled=!g_RG_JournalEnabled; RG_JournalSaveSettings(); }

int RG_JournalAddCondition(string n){ if(g_RG_JournalConditionCount>=RG_JOURNAL_MAX_ITEMS)return(-1); n=RG_JournalClean(n); if(n=="")return(-1); int i=g_RG_JournalConditionCount; g_RG_JournalConditions[i].id=RG_JournalNextId(g_RG_JournalConditions,g_RG_JournalConditionCount); g_RG_JournalConditions[i].name=n; g_RG_JournalConditionCount++; RG_JournalSaveSettings(); return(i); }
int RG_JournalAddPattern(string n){ if(g_RG_JournalPatternCount>=RG_JOURNAL_MAX_ITEMS)return(-1); n=RG_JournalClean(n); if(n=="")return(-1); int i=g_RG_JournalPatternCount; g_RG_JournalPatterns[i].id=RG_JournalNextId(g_RG_JournalPatterns,g_RG_JournalPatternCount); g_RG_JournalPatterns[i].name=n; g_RG_JournalPatternCount++; RG_JournalSaveSettings(); return(i); }
int RG_JournalAddTrigger(string n){ if(g_RG_JournalTriggerCount>=RG_JOURNAL_MAX_ITEMS)return(-1); n=RG_JournalClean(n); if(n=="")return(-1); int i=g_RG_JournalTriggerCount; g_RG_JournalTriggers[i].id=RG_JournalNextId(g_RG_JournalTriggers,g_RG_JournalTriggerCount); g_RG_JournalTriggers[i].name=n; g_RG_JournalTriggerCount++; RG_JournalSaveSettings(); return(i); }

void RG_JournalDeleteItem(RG_JournalListItem &a[],int &count,int index)
{
   if(index<0 || index>=count)return;
   for(int i=index;i<count-1;i++) a[i]=a[i+1];
   count--; RG_JournalSaveSettings();
}
void RG_JournalRenameItem(RG_JournalListItem &a[],int count,int index,string name){ if(index<0||index>=count)return; name=RG_JournalClean(name); if(name=="")return; a[index].name=name; RG_JournalSaveSettings(); }

//====================================================
// Preview checklist state
//====================================================
void RG_JournalChecklistReset()
{
   for(int i=0;i<RG_JOURNAL_MAX_ITEMS;i++)
   {
      g_RG_JournalPreviewConditions[i]=false;
      g_RG_JournalPreviewPatterns[i]=false;
      g_RG_JournalPreviewTriggers[i]=false;
   }
   for(int tfi=0;tfi<9;tfi++) g_RG_JournalPreviewTFs[tfi]=false;
   int order[9]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
   for(int ti=0;ti<9;ti++) if(order[ti]==Period()) g_RG_JournalPreviewTFs[ti]=true;
   g_RG_JournalPreviewRR=false; g_RG_JournalPreviewVolume=false; g_RG_JournalPreviewSL=false; g_RG_JournalPreviewTP=false;
}

void RG_JournalBeginPreview(int direction)
{
   RG_JournalChecklistReset();
   g_RG_JournalPreviewDirection=direction;
   g_RG_JournalPreviewOpen=(g_RG_JournalEnabled && g_RG_JournalEntryMode==0);
}
void RG_JournalBeginAfterEntry(int ticket,int direction)
{
   RG_JournalChecklistReset();
   g_RG_JournalPreviewDirection=direction;
   g_RG_JournalAfterEntryTicket=ticket;
   g_RG_JournalPreviewOpen=(g_RG_JournalEnabled && g_RG_JournalEntryMode==1 && ticket>0);
}
int RG_JournalFinishAfterEntry(bool saveSelection)
{
   int ticket=g_RG_JournalAfterEntryTicket;
   if(ticket>0 && g_RG_JournalEnabled)
   {
      bool selected=OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES);
      if(!selected) selected=OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY);
      if(selected)
      {
         if(!saveSelection) RG_JournalChecklistReset();
         RG_JournalAttachEntryMeta(ticket,OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit(),OrderLots());
      }
   }
   g_RG_JournalAfterEntryTicket=0;
   g_RG_JournalPreviewOpen=false;
   return(ticket);
}
void RG_JournalEndPreview(){ g_RG_JournalPreviewOpen=false; }
bool RG_JournalPreviewIsOpen(){ return(g_RG_JournalPreviewOpen); }

void RG_JournalToggleCondition(int i){ if(i>=0&&i<g_RG_JournalConditionCount) g_RG_JournalPreviewConditions[i]=!g_RG_JournalPreviewConditions[i]; }
void RG_JournalToggleRR(){g_RG_JournalPreviewRR=!g_RG_JournalPreviewRR;}
void RG_JournalToggleVolume(){g_RG_JournalPreviewVolume=!g_RG_JournalPreviewVolume;}
void RG_JournalToggleSL(){g_RG_JournalPreviewSL=!g_RG_JournalPreviewSL;}
void RG_JournalToggleTP(){g_RG_JournalPreviewTP=!g_RG_JournalPreviewTP;}
void RG_JournalTogglePattern(int i){ if(i>=0&&i<g_RG_JournalPatternCount) g_RG_JournalPreviewPatterns[i]=!g_RG_JournalPreviewPatterns[i]; }
void RG_JournalToggleTrigger(int i){ if(i>=0&&i<g_RG_JournalTriggerCount) g_RG_JournalPreviewTriggers[i]=!g_RG_JournalPreviewTriggers[i]; }
void RG_JournalToggleTF(int index){ if(index<0||index>=9)return; g_RG_JournalPreviewTFs[index]=!g_RG_JournalPreviewTFs[index]; }
string RG_JournalJoinSelected(RG_JournalListItem &a[],int count,bool &sel[])
{
   string s="";
   for(int i=0;i<count;i++) if(sel[i]) { if(s!="")s+=" | "; s+=a[i].name; }
   if(s=="") s="NONE";
   return(s);
}
string RG_JournalSelectedTFs()
{
   int order[9]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
   string s="";
   for(int i=0;i<9;i++) if(g_RG_JournalPreviewTFs[i]) { if(s!="")s+=" | "; s+=RG_JournalTFName(order[i]); }
   if(s=="")s="NONE";
   return(s);
}
string RG_JournalCheckMark()
{
   return(ShortToString(10003));
}
string RG_JournalCrossMark()
{
   return(ShortToString(10007));
}

// Store a plain ASCII token in CSV metadata. Unicode checkmarks can be
// corrupted by MT4 CSV/ANSI conversions, which made every condition appear
// unchecked in Excel. Convert to glyphs only at presentation time.
bool RG_JournalConditionIsComplete(string value)
{
   // MQL4 StringTrimLeft/Right modify the string by reference and return
   // the number of removed characters. Do not assign their return values
   // back to value, or a valid CHECK token becomes "0" and renders CROSS.
   StringTrimLeft(value);
   StringTrimRight(value);
   StringToUpper(value);

   if(value=="CHECK" || value=="Y" || value=="YES" || value=="TRUE" || value=="1")
      return(true);
   if(value==RG_JournalCheckMark()) return(true);
   return(false);
}

string RG_JournalConditionMark(string value)
{
   return(RG_JournalConditionIsComplete(value) ? RG_JournalCheckMark() : RG_JournalCrossMark());
}

string RG_JournalPreviewConditions()
{
   // Durable ASCII value; presentation layers render the actual symbol.
   if(g_RG_JournalConditionCount<=0) return("CROSS");
   for(int i=0;i<g_RG_JournalConditionCount;i++)
      if(!g_RG_JournalPreviewConditions[i]) return("CROSS");
   return("CHECK");
}
string RG_JournalPreviewStatus(){
   bool any=(g_RG_JournalPreviewRR||g_RG_JournalPreviewVolume||g_RG_JournalPreviewSL||g_RG_JournalPreviewTP);
   for(int i=0;i<g_RG_JournalConditionCount;i++) if(g_RG_JournalPreviewConditions[i]) { any=true; break; }
   for(int i=0;i<g_RG_JournalPatternCount;i++) if(g_RG_JournalPreviewPatterns[i]) { any=true; break; }
   for(int i=0;i<g_RG_JournalTriggerCount;i++) if(g_RG_JournalPreviewTriggers[i]) { any=true; break; }
   for(int i=0;i<9;i++) if(g_RG_JournalPreviewTFs[i]) { any=true; break; }
   if(!any) return("NONE");
   return("RECORDED");
}

string RG_JournalPreviewFlags()
{
   return("RR="+(g_RG_JournalPreviewRR?"Y":"N")+",VOL="+(g_RG_JournalPreviewVolume?"Y":"N")+",SL="+(g_RG_JournalPreviewSL?"Y":"N")+",TP="+(g_RG_JournalPreviewTP?"Y":"N"));
}

// Store the user snapshot keyed by ticket. It is consumed when the order is appended to Journal.csv.
void RG_JournalAttachEntryMeta(int ticket,double entry,double sl,double tp,double lots)
{
   if(ticket<=0 || !g_RG_JournalEnabled) return;
   string p=RG_JournalGV("META_"+IntegerToString(ticket)+"_");
   // Strings cannot be stored in MT4 Global Variables. Use terminal GlobalVariables for indices/numerics and a compact file for text.
   int h=FileOpen(RG_JOURNAL_FOLDER+"\\Meta_"+IntegerToString(ticket)+".csv",FILE_CSV|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h==INVALID_HANDLE)return;
   // Entry facts are always stored. The checklist checkboxes must not decide
   // whether actual R/R and Volume are written to the Journal.
   RG_JournalClearMetaCache();
   FileWrite(h,
      RG_JournalJoinSelected(g_RG_JournalPatterns,g_RG_JournalPatternCount,g_RG_JournalPreviewPatterns),
      RG_JournalJoinSelected(g_RG_JournalTriggers,g_RG_JournalTriggerCount,g_RG_JournalPreviewTriggers),
      RG_JournalSelectedTFs(),
      RG_JournalPreviewConditions(),
      RG_JournalPreviewStatus(),
      DoubleToString(lots,2),
      RG_JournalRRText(entry,sl,tp),
      RG_JournalPreviewFlags()
   );
   FileClose(h);
}

bool RG_JournalReadMetaFromJournal(int ticket,string &pattern,string &trigger,string &tf,string &conditions,string &status,string &lots,string &rr,string &flags)
{
   int h=FileOpen(RG_JOURNAL_FILE,FILE_CSV|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h==INVALID_HANDLE) return(false);
   bool found=false;
   while(!FileIsEnding(h))
   {
      string cols[32];
      cols[0]=FileReadString(h);
      if(cols[0]=="" && FileIsEnding(h)) break;
      for(int c=1;c<32;c++) cols[c]=FileReadString(h);
      if((cols[0]=="OPEN" || cols[0]=="CLOSE") && (int)StrToInteger(cols[1])==ticket)
      {
         // These are the stable metadata columns written by both OPEN and CLOSE rows.
         if(cols[24]!="" && cols[24]!="NONE") pattern=cols[24];
         if(cols[25]!="" && cols[25]!="NONE") trigger=cols[25];
         if(cols[26]!="" && cols[26]!="NONE") tf=cols[26];
         if(cols[27]!="" && cols[27]!="NONE") conditions=cols[27];
         if(cols[28]!="" && cols[28]!="NONE") status=cols[28];
         if(cols[29]!="") rr=cols[29];
         if(cols[30]!="") lots=cols[30];
         if(cols[31]!="") flags=cols[31];
         bool rowHasMeta=(cols[24]!="" && cols[24]!="NONE") ||
                         (cols[25]!="" && cols[25]!="NONE") ||
                         (cols[26]!="" && cols[26]!="NONE") ||
                         (cols[27]!="" && cols[27]!="NONE") ||
                         cols[30]!="";
         if(rowHasMeta) found=true;
         // Prefer a useful OPEN snapshot; otherwise keep scanning CLOSE rows.
         if(cols[0]=="OPEN" && rowHasMeta) { FileClose(h); return(true); }
      }
   }
   FileClose(h);
   return(found);
}

bool RG_JournalReadMeta(int ticket,string &pattern,string &trigger,string &tf,string &conditions,string &status,string &lots,string &rr,string &flags)
{
   pattern="";trigger="";tf="";conditions="";status="";lots="";rr="";flags="";
   if(ticket<=0) return(false);

   int cachedSlot=RG_JournalMetaCacheSlot(ticket,false);
   if(cachedSlot>=0)
   {
      pattern=g_RG_JournalMetaCache[cachedSlot].pattern;
      trigger=g_RG_JournalMetaCache[cachedSlot].trigger;
      tf=g_RG_JournalMetaCache[cachedSlot].tf;
      conditions=g_RG_JournalMetaCache[cachedSlot].conditions;
      status=g_RG_JournalMetaCache[cachedSlot].status;
      lots=g_RG_JournalMetaCache[cachedSlot].lots;
      rr=g_RG_JournalMetaCache[cachedSlot].rr;
      flags=g_RG_JournalMetaCache[cachedSlot].flags;
      return(g_RG_JournalMetaCache[cachedSlot].hasMeta);
   }

   int h=FileOpen(RG_JOURNAL_FOLDER+"\\Meta_"+IntegerToString(ticket)+".csv",FILE_CSV|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h!=INVALID_HANDLE)
   {
      pattern=FileReadString(h); trigger=FileReadString(h); tf=FileReadString(h); conditions=FileReadString(h); status=FileReadString(h); lots=FileReadString(h); rr=FileReadString(h); flags=FileReadString(h); FileClose(h);
   }
   // Recover metadata from Journal.csv only when the per-ticket snapshot is
   // absent/incomplete. The result is cached so nested report loops never rescan
   // the full CSV for the same ticket repeatedly.
   if(pattern=="" || pattern=="NONE" || trigger=="" || trigger=="NONE" || conditions=="" || conditions=="NONE" || lots=="")
      RG_JournalReadMetaFromJournal(ticket,pattern,trigger,tf,conditions,status,lots,rr,flags);

   bool has=(pattern!="" || trigger!="" || tf!="" || conditions!="" || lots!="" || rr!="" || flags!="");
   int cacheSlot=RG_JournalMetaCacheSlot(ticket,true);
   if(cacheSlot>=0)
   {
      g_RG_JournalMetaCache[cacheSlot].ticket=ticket;
      g_RG_JournalMetaCache[cacheSlot].hasMeta=has;
      g_RG_JournalMetaCache[cacheSlot].pattern=pattern;
      g_RG_JournalMetaCache[cacheSlot].trigger=trigger;
      g_RG_JournalMetaCache[cacheSlot].tf=tf;
      g_RG_JournalMetaCache[cacheSlot].conditions=conditions;
      g_RG_JournalMetaCache[cacheSlot].status=status;
      g_RG_JournalMetaCache[cacheSlot].lots=lots;
      g_RG_JournalMetaCache[cacheSlot].rr=rr;
      g_RG_JournalMetaCache[cacheSlot].flags=flags;
   }
   return(has);
}

void RG_JournalDeleteMeta(int ticket){ string f=RG_JOURNAL_FOLDER+"\\Meta_"+IntegerToString(ticket)+".csv"; if(FileIsExist(f))FileDelete(f); RG_JournalClearMetaCache(); }

string RG_JournalStateFile(int ticket)
{
   return(RG_JOURNAL_FOLDER+"\\State_"+IntegerToString(ticket)+".csv");
}

void RG_JournalStateDefaults(string &originalLots,string &lastLots,string &originalSL,string &lastSL,string &partialText,string &slMoveText)
{
   originalLots=""; lastLots=""; originalSL=""; lastSL=""; partialText=""; slMoveText="";
}

bool RG_JournalReadState(int ticket,string &originalLots,string &lastLots,string &originalSL,string &lastSL,string &partialText,string &slMoveText)
{
   RG_JournalStateDefaults(originalLots,lastLots,originalSL,lastSL,partialText,slMoveText);
   int h=FileOpen(RG_JournalStateFile(ticket),FILE_CSV|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h==INVALID_HANDLE) return(false);
   originalLots=FileReadString(h);
   lastLots=FileReadString(h);
   originalSL=FileReadString(h);
   lastSL=FileReadString(h);
   partialText=FileReadString(h);
   slMoveText=FileReadString(h);
   FileClose(h);
   return(true);
}

void RG_JournalWriteState(int ticket,string originalLots,string lastLots,string originalSL,string lastSL,string partialText,string slMoveText)
{
   if(ticket<=0) return;
   int h=FileOpen(RG_JournalStateFile(ticket),FILE_CSV|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h==INVALID_HANDLE) return;
   FileWrite(h,originalLots,lastLots,originalSL,lastSL,partialText,slMoveText);
   FileClose(h);
}

void RG_JournalTrackOpenState(int ticket)
{
   if(ticket<=0 || !OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES) || !RG_JournalIsMarketType(OrderType())) return;

   string originalLots,lastLots,originalSL,lastSL,partialText,slMoveText;
   bool exists=RG_JournalReadState(ticket,originalLots,lastLots,originalSL,lastSL,partialText,slMoveText);
   int digits=(int)MarketInfo(OrderSymbol(),MODE_DIGITS);
   double lots=OrderLots();
   double sl=OrderStopLoss();

   if(!exists || originalLots=="")
   {
      originalLots=DoubleToString(lots,2);
      lastLots=DoubleToString(lots,2);
      originalSL=DoubleToString(sl,digits);
      lastSL=DoubleToString(sl,digits);
      RG_JournalWriteState(ticket,originalLots,lastLots,originalSL,lastSL,partialText,slMoveText);
      return;
   }

   double prevLots=StrToDouble(lastLots);
   double prevSL=StrToDouble(lastSL);
   double lotStep=MarketInfo(OrderSymbol(),MODE_LOTSTEP);
   if(lotStep<=0.0) lotStep=0.01;
   bool changed=false;

   if(lots < prevLots-0.5*lotStep)
   {
      double closed=prevLots-lots;
      string item=DoubleToString(closed,2)+" lots";
      if(partialText!="") partialText+=" | ";
      partialText+=item;
      changed=true;
   }

   double point=MarketInfo(OrderSymbol(),MODE_POINT);
   if(sl>0.0 && prevSL>0.0 && point>0.0 && MathAbs(sl-prevSL)>point*0.5)
   {
      string item=DoubleToString(prevSL,digits)+" -> "+DoubleToString(sl,digits);
      if(slMoveText!="") slMoveText+=" | ";
      slMoveText+=item;
      changed=true;
   }
   else if(sl>0.0 && prevSL<=0.0)
   {
      string item="0 -> "+DoubleToString(sl,digits);
      if(slMoveText!="") slMoveText+=" | ";
      slMoveText+=item;
      changed=true;
   }

   string newLots=DoubleToString(lots,2);
   string newSL=DoubleToString(sl,digits);
   if(newLots!=lastLots || newSL!=lastSL) changed=true;
   lastLots=newLots;
   lastSL=newSL;
   // Avoid rewriting the state file every timer cycle when nothing changed.
   if(changed) RG_JournalWriteState(ticket,originalLots,lastLots,originalSL,lastSL,partialText,slMoveText);
}

string RG_JournalDescriptionFile(int ticket)
{
   return(RG_JOURNAL_FOLDER+"\\Description_"+IntegerToString(ticket)+".txt");
}

string RG_JournalGetDescription(int ticket)
{
   string f=RG_JournalDescriptionFile(ticket);
   if(!FileIsExist(f)) return("");

   // Description files are stored as UTF-8 with a BOM. Binary reading avoids
   // ANSI conversion and preserves Persian text and embedded line breaks.
   int h=FileOpen(f,FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(h==INVALID_HANDLE) return("");
   int size=(int)FileSize(h);
   if(size<=0)
   {
      FileClose(h);
      return("");
   }

   uchar bytes[];
   ArrayResize(bytes,size);
   int count=(int)FileReadArray(h,bytes,0,size);
   FileClose(h);
   if(count<=0) return("");

   // New UTF-8 format.
   if(count>=3 && bytes[0]==0xEF && bytes[1]==0xBB && bytes[2]==0xBF)
      return(CharArrayToString(bytes,3,count-3,CP_UTF8));

   // Backward compatibility: older Description files were written using the
   // terminal's ANSI code page.
   return(CharArrayToString(bytes,0,count,CP_ACP));
}

void RG_JournalSetDescription(int ticket,string description)
{
   if(ticket<=0) return;
   string f=RG_JournalDescriptionFile(ticket);
   int h=FileOpen(f,FILE_BIN|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(h==INVALID_HANDLE) return;

   // UTF-8 BOM allows reliable encoding detection while remaining Excel/tool
   // friendly. Write the text bytes without StringToCharArray's trailing NUL.
   uchar bom[3];
   bom[0]=0xEF;
   bom[1]=0xBB;
   bom[2]=0xBF;
   FileWriteArray(h,bom,0,3);

   uchar bytes[];
   int chars=StringToCharArray(description,bytes,0,WHOLE_ARRAY,CP_UTF8);
   if(chars>1)
      FileWriteArray(h,bytes,0,chars-1);

   FileClose(h);
}

void RG_JournalDeleteDescription(int ticket)
{
   string f=RG_JournalDescriptionFile(ticket);
   if(FileIsExist(f)) FileDelete(f);
}

void RG_JournalWriteHeader()
{
   int h=FileOpen(RG_JOURNAL_FILE,FILE_CSV|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h==INVALID_HANDLE)return;
   if(FileSize(h)==0)
      FileWrite(h,"EVENT","TICKET","SYMBOL","TYPE","SYSTEM_DATE","SYSTEM_TIME","BROKER_OPEN","BROKER_CLOSE","ENTRY","CLOSE","SL","TP","VOLUME","RISK_MONEY","RR","SESSION","NEWS","NET","SWAP","COMMISSION","DURATION_SEC","MAGIC","COMMENT","DAY","PATTERN","TRIGGER","REASON_TF","ENTRY_CONDITIONS","CHECKLIST_STATUS","CHECKLIST_RR","CHECKLIST_VOLUME","CHECKLIST_FLAGS");
   FileClose(h);
}

void RG_JournalWarmKnownFlags()
{
   int h=FileOpen(RG_JOURNAL_FILE,FILE_CSV|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h==INVALID_HANDLE) return;
   while(!FileIsEnding(h))
   {
      string ev=FileReadString(h);
      if(StringLen(ev)==0 && FileIsEnding(h)) break;
      string ts=FileReadString(h);
      int ticket=(int)StrToInteger(ts);
      if(ticket>0)
      {
         if(ev=="OPEN") GlobalVariableSet(RG_JournalGV("OPEN_"+IntegerToString(ticket)),1.0);
         else if(ev=="CLOSE") GlobalVariableSet(RG_JournalGV("CLOSE_"+IntegerToString(ticket)),1.0);
      }
      for(int k=0;k<30;k++) FileReadString(h);
   }
   FileClose(h);
}

bool RG_JournalKnownFlag(string kind,int ticket)
{
   if(ticket<=0) return(false);
   string key=RG_JournalGV(kind+"_"+IntegerToString(ticket));
   if(GlobalVariableCheck(key) && GlobalVariableGet(key)>0.5) return(true);
   return(false);
}

bool RG_JournalHasOpenRecord(int ticket)
{
   int h=FileOpen(RG_JOURNAL_FILE,FILE_CSV|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h==INVALID_HANDLE) return(false);
   while(!FileIsEnding(h))
   {
      string ev=FileReadString(h);
      if(StringLen(ev)==0 && FileIsEnding(h)) break;
      string ts=FileReadString(h);
      if(ev=="OPEN" && (int)StrToInteger(ts)==ticket)
      {
         FileClose(h);
         return(true);
      }
      for(int k=0;k<30;k++) FileReadString(h);
   }
   FileClose(h);
   return(false);
}

void RG_JournalAppendOpen(int ticket)
{
   if(ticket<=0||!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)||!RG_JournalIsMarketType(OrderType()))return;
   string key=RG_JournalGV("OPEN_"+IntegerToString(ticket));
   if(RG_JournalKnownFlag("OPEN",ticket))
   {
      RG_JournalTrackOpenState(ticket);
      return;
   }
   if(RG_JournalHasOpenRecord(ticket))
   {
      GlobalVariableSet(key,1.0);
      RG_JournalTrackOpenState(ticket);
      return;
   }
   RG_JournalTrackOpenState(ticket);
   datetime brokerOpen=OrderOpenTime(), systemOpen=RG_JournalBrokerToSystem(brokerOpen);
   string pattern,trigger,tf,conditions,status,metaLots,metaRR,metaFlags; RG_JournalReadMeta(ticket,pattern,trigger,tf,conditions,status,metaLots,metaRR,metaFlags);
   int h=FileOpen(RG_JOURNAL_FILE,FILE_CSV|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE,';'); if(h==INVALID_HANDLE)return;
   FileSeek(h,0,SEEK_END);
   int digits=(int)MarketInfo(OrderSymbol(),MODE_DIGITS);
   FileWrite(h,"OPEN",ticket,OrderSymbol(),RG_JournalTypeName(OrderType()),RG_JournalDate(systemOpen),RG_JournalTime(systemOpen),TimeToString(brokerOpen,TIME_DATE|TIME_SECONDS),"",DoubleToString(OrderOpenPrice(),digits),"",DoubleToString(OrderStopLoss(),digits),DoubleToString(OrderTakeProfit(),digits),DoubleToString(OrderLots(),2),DoubleToString(RG_JournalRiskMoney(OrderSymbol(),OrderOpenPrice(),OrderStopLoss(),OrderLots()),2),DoubleToString(RG_JournalRR(OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit()),2),RG_JournalSession(brokerOpen),"","","","",0,OrderMagicNumber(),OrderComment(),RG_JournalDay(systemOpen),pattern,trigger,tf,conditions,status,metaRR,metaLots,metaFlags);
   FileClose(h); RG_JournalClearMetaCache(); GlobalVariableSet(key,1.0);
}

void RG_JournalAppendClose(int ticket)
{
   if(ticket<=0||!OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY)||!RG_JournalIsMarketType(OrderType()))return;
   string key=RG_JournalGV("CLOSE_"+IntegerToString(ticket));
   // Fast path: after initialization the Journal record is mirrored by a
   // per-ticket flag, so normal timer scans do not repeatedly rescan Journal.csv.
   if(RG_JournalKnownFlag("CLOSE",ticket)) return;
   if(RG_JournalHasCloseRecord(ticket))
   {
      GlobalVariableSet(key,1.0);
      return;
   }
   datetime brokerClose=OrderCloseTime(), systemClose=RG_JournalBrokerToSystem(brokerClose);
   string pattern,trigger,tf,conditions,status,metaLots,metaRR,metaFlags;
   bool hasMeta=RG_JournalReadMeta(ticket,pattern,trigger,tf,conditions,status,metaLots,metaRR,metaFlags);
   if(!hasMeta)
   {
      pattern="NONE"; trigger="NONE"; tf="NONE"; conditions="NONE"; status="NONE"; metaLots=""; metaRR="";
   }
   string stOriginalLots,stLastLots,stOriginalSL,stLastSL,stPartial,stSLMoves;
   RG_JournalReadState(ticket,stOriginalLots,stLastLots,stOriginalSL,stLastSL,stPartial,stSLMoves);
   int h=FileOpen(RG_JOURNAL_FILE,FILE_CSV|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE,';'); if(h==INVALID_HANDLE)return;
   FileSeek(h,0,SEEK_END);
   int digits=(int)MarketInfo(OrderSymbol(),MODE_DIGITS);
   double net=OrderProfit()+OrderSwap()+OrderCommission();
   long duration=(long)(OrderCloseTime()-OrderOpenTime());
   string volume=(metaLots!="" ? metaLots : DoubleToString(OrderLots(),2));
   string rr=(metaRR!="" ? metaRR : RG_JournalRRText(OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit()));
   // Partial exits and SL moves are retained in the per-ticket state file.
   FileWrite(h,"CLOSE",ticket,OrderSymbol(),RG_JournalTypeName(OrderType()),RG_JournalDate(systemClose),RG_JournalTime(systemClose),TimeToString(OrderOpenTime(),TIME_DATE|TIME_SECONDS),TimeToString(OrderCloseTime(),TIME_DATE|TIME_SECONDS),DoubleToString(OrderOpenPrice(),digits),DoubleToString(OrderClosePrice(),digits),DoubleToString(OrderStopLoss(),digits),DoubleToString(OrderTakeProfit(),digits),volume,DoubleToString(RG_JournalRiskMoney(OrderSymbol(),OrderOpenPrice(),OrderStopLoss(),OrderLots()),2),rr,RG_JournalSession(OrderOpenTime()),"",DoubleToString(net,2),DoubleToString(OrderSwap(),2),DoubleToString(OrderCommission(),2),duration,OrderMagicNumber(),OrderComment(),RG_JournalDay(RG_JournalBrokerToSystem(OrderOpenTime())),pattern,trigger,tf,conditions,status,rr,volume,metaFlags);
   FileClose(h);
   RG_JournalClearMetaCache();
   GlobalVariableSet(key,1.0);
}

bool RG_JournalHasCloseRecord(int ticket)
{
   int h=FileOpen(RG_JOURNAL_FILE,FILE_CSV|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h==INVALID_HANDLE) return(false);
   while(!FileIsEnding(h))
   {
      string ev=FileReadString(h); if(StringLen(ev)==0 && FileIsEnding(h)) break;
      string ts=FileReadString(h);
      if(ev=="CLOSE" && (int)StrToInteger(ts)==ticket){ FileClose(h); return(true); }
      for(int k=0;k<30;k++) FileReadString(h);
   }
   FileClose(h); return(false);
}

int g_RG_JournalLastHistoryTotal=-1;
int g_RG_JournalLastOpenTotal=-1;

void RG_JournalScanOpenOrders()
{
   if(!g_RG_JournalReady || !g_RG_JournalEnabled) return;
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(!RG_JournalIsMarketType(OrderType())) continue;
      RG_JournalAppendOpen(OrderTicket());
   }
   g_RG_JournalLastOpenTotal=OrdersTotal();
}

void RG_JournalScanHistory()
{
   if(!g_RG_JournalReady || !g_RG_JournalEnabled) return;
   int total=OrdersHistoryTotal();
   for(int j=total-1;j>=0;j--)
   {
      if(!OrderSelect(j,SELECT_BY_POS,MODE_HISTORY)) continue;
      if(!RG_JournalIsMarketType(OrderType())) continue;
      RG_JournalAppendClose(OrderTicket());
   }
   g_RG_JournalLastHistoryTotal=total;
}

void RG_JournalScan()
{
   if(!g_RG_JournalReady || !g_RG_JournalEnabled) return;
   // One full synchronization is performed at initialization or when the
   // terminal's visible History list changes. Normal ticks never call this.
   RG_JournalScanOpenOrders();
   RG_JournalScanHistory();
}

void RG_JournalInit()
{
   FolderCreate("RiskGuard");
   FolderCreate(RG_JOURNAL_FOLDER);
   RG_JournalLoadSettings();
   RG_JournalWriteHeader();
   g_RG_JournalReady=true;
   // Build the per-ticket fast flags once from Journal.csv. This removes the
   // O(history x journal-file-scan) startup pattern of J05.
   RG_JournalWarmKnownFlags();
   RG_JournalScan();
   RG_JournalRefreshAccountStats(true);
}

void RG_JournalUpdate()
{
   if(!g_RG_JournalReady || !g_RG_JournalEnabled) return;

   // Open trades are checked once per timer tick so SL moves and partial
   // closes are captured, but no Account History scan is performed unless
   // the terminal reports that its history size changed.
   RG_JournalScanOpenOrders();

   int historyTotal=OrdersHistoryTotal();
   if(historyTotal!=g_RG_JournalLastHistoryTotal)
      RG_JournalScanHistory();

   // Account History is the source of truth for Journal statistics.
   // Recalculate only when the visible history size changes.
   RG_JournalRefreshAccountStats(false);
}


// Logical-trade aggregation for MT4 brokers that represent partial closes
// as multiple history tickets. Fragments are grouped by immutable entry facts.
bool RG_JournalSameLogicalTradeSelected(int ticketA,int ticketB)
{
   if(ticketA<=0 || ticketB<=0) return(false);
   if(ticketA==ticketB) return(true);
   if(RG_JournalEnsureHistoryCache())
   {
      int a=RG_JournalHistoryFind(ticketA), b=RG_JournalHistoryFind(ticketB);
      if(a>=0 && b>=0) return(g_RG_JournalHistoryCache[a].groupRoot==g_RG_JournalHistoryCache[b].groupRoot);
   }
   return(false);
}

bool RG_JournalIsFirstTradeFragment(int historyIndex)
{
   if(!OrderSelect(historyIndex,SELECT_BY_POS,MODE_HISTORY)) return(false);
   int ticket=OrderTicket();
   if(!RG_JournalEnsureHistoryCache()) return(false);
   int idx=RG_JournalHistoryFind(ticket);
   if(idx<0) return(false);
   int root=g_RG_JournalHistoryCache[idx].groupRoot;
   return(g_RG_JournalHistoryCache[root].canonicalTicket==ticket);
}

bool RG_JournalAggregateTrade(int ticket,double &closedLots,double &net,datetime &lastClose,int &fragments)
{
   closedLots=0.0; net=0.0; lastClose=0; fragments=0;
   if(!RG_JournalEnsureHistoryCache()) return(false);
   int idx=RG_JournalHistoryFind(ticket);
   if(idx<0) return(false);
   int root=g_RG_JournalHistoryCache[idx].groupRoot;
   closedLots=g_RG_JournalHistoryCache[root].groupLots;
   net=g_RG_JournalHistoryCache[root].groupNet;
   lastClose=g_RG_JournalHistoryCache[root].groupCloseTime;
   fragments=g_RG_JournalHistoryCache[root].groupFragments;
   return(fragments>0);
}

// Resolve metadata across every history fragment of one logical trade.
// MT4 brokers may assign a different ticket to a partial-close fragment,
// while the Pattern/Trigger and original volume remain attached to the entry ticket.
bool RG_JournalReadLogicalTradeMeta(int ticket,string &pattern,string &trigger,string &tf,string &conditions,string &status,string &lots,string &rr,string &flags)
{
   pattern=""; trigger=""; tf=""; conditions=""; status=""; lots=""; rr=""; flags="";
   if(ticket<=0 || !RG_JournalEnsureHistoryCache()) return(false);
   int idx=RG_JournalHistoryFind(ticket);
   if(idx<0) return(false);
   int root=g_RG_JournalHistoryCache[idx].groupRoot;
   bool found=false; double bestLots=0.0;
   bool completeConditionsFound=false;
   string completeConditions="";
   int candidate=root;
   while(candidate>=0)
   {
      string cp="",ct="",cf="",cc="",cs="",cl="",cr="",cflags="";
      bool has=RG_JournalReadMeta(g_RG_JournalHistoryCache[candidate].ticket,cp,ct,cf,cc,cs,cl,cr,cflags);
      if(has)
      {
         double candidateLots=StrToDouble(cl);
         bool hasSelections=((cp!="" && cp!="NONE") || (ct!="" && ct!="NONE"));
         bool currentSelections=((pattern!="" && pattern!="NONE") || (trigger!="" && trigger!="NONE"));
         // Keep a complete checklist result if a partial-close fragment carries
         // an older/incomplete snapshot. CROSS must not overwrite CHECK.
         if(RG_JournalConditionIsComplete(cc))
         { completeConditionsFound=true; completeConditions=cc; }
         if(!found || (hasSelections && !currentSelections) || (candidateLots>bestLots && hasSelections))
         { pattern=cp; trigger=ct; tf=cf; conditions=cc; status=cs; lots=cl; rr=cr; flags=cflags; bestLots=candidateLots; }
         else
         {
            if((pattern=="" || pattern=="NONE") && cp!="" && cp!="NONE") pattern=cp;
            if((trigger=="" || trigger=="NONE") && ct!="" && ct!="NONE") trigger=ct;
            if((tf=="" || tf=="NONE") && cf!="" && cf!="NONE") tf=cf;
            if((conditions=="" || conditions=="NONE") && cc!="" && cc!="NONE") conditions=cc;
            if(lots=="" && cl!="") lots=cl;
            if(rr=="" && cr!="") rr=cr;
            if(flags=="" && cflags!="") flags=cflags;
         }
         found=true;
      }
      candidate=g_RG_JournalHistoryCache[candidate].nextGroup;
   }
   if(completeConditionsFound) conditions=completeConditions;
   return(found);
}

// Read state from all fragments belonging to the same logical trade.
// Partial-close fragments may have their own tickets/state files; the export
// must show SL-move and partial-exit flags accumulated anywhere in the group.
bool RG_JournalReadLogicalTradeState(int ticket,string &originalLots,string &lastLots,string &originalSL,string &lastSL,string &partialText,string &slMoveText)
{
   RG_JournalStateDefaults(originalLots,lastLots,originalSL,lastSL,partialText,slMoveText);
   if(ticket<=0 || !RG_JournalEnsureHistoryCache()) return(false);
   int idx=RG_JournalHistoryFind(ticket);
   if(idx<0) return(false);
   int root=g_RG_JournalHistoryCache[idx].groupRoot;
   bool found=false;
   int candidate=root;
   while(candidate>=0)
   {
      string o,l,os,ls,pt,sm;
      if(RG_JournalReadState(g_RG_JournalHistoryCache[candidate].ticket,o,l,os,ls,pt,sm))
      {
         if(!found || (originalLots=="" && o!=""))
         { originalLots=o; lastLots=l; originalSL=os; lastSL=ls; found=true; }
         if(pt!="") { if(partialText!="") partialText+=" | "; partialText+=pt; }
         if(sm!="") { if(slMoveText!="") slMoveText+=" | "; slMoveText+=sm; }
      }
      candidate=g_RG_JournalHistoryCache[candidate].nextGroup;
   }
   return(found || partialText!="" || slMoveText!="");
}

//====================================================
// JOURNAL CORE DATA VIEW
//====================================================
struct RG_JournalRecord
{
   int ticket;
   string date;
   string time;
   string symbol;
   string type;
   string tf;
   string pattern;
   string trigger;
   string conditions;
   string session;
   string rr;
   double lots;
   double net;
   string partialExit;
   string slMove;
   string description;
};

int RG_JournalLoadClosedRecords(RG_JournalRecord &rows[],datetime fromDate,datetime toDate)
{
   ArrayResize(rows,0);
   int total=OrdersHistoryTotal();
   for(int i=total-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      int typ=OrderType();
      if(!RG_JournalIsMarketType(typ) || !RG_JournalIsFirstTradeFragment(i)) continue;
      int ticket=OrderTicket();
      double aggregateLots=0.0,aggregateNet=0.0;
      datetime ct=0; int aggregateFragments=0;
      if(!RG_JournalAggregateTrade(ticket,aggregateLots,aggregateNet,ct,aggregateFragments)) continue;
      if(!OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY)) continue;
      if(ct<=0 || ct<fromDate || ct>=toDate+86400) continue;

      string pattern="",trigger="",tf="",conditions="",status="",metaLots="",metaRR="",flags="";
      RG_JournalReadLogicalTradeMeta(ticket,pattern,trigger,tf,conditions,status,metaLots,metaRR,flags);
      int n=ArraySize(rows); ArrayResize(rows,n+1);
      rows[n].ticket=ticket;
      rows[n].date=TimeToString(ct,TIME_DATE);
      rows[n].time=TimeToString(ct,TIME_SECONDS);
      rows[n].symbol=OrderSymbol();
      rows[n].type=RG_JournalTypeName(typ);
      rows[n].tf=(tf!="" ? tf : "NONE");
      rows[n].pattern=(pattern!="" ? pattern : "NONE");
      rows[n].trigger=(trigger!="" ? trigger : "NONE");
      rows[n].conditions=RG_JournalConditionMark(conditions);
      rows[n].session=RG_JournalSession(OrderOpenTime());
      rows[n].rr=(metaRR!="" ? metaRR : RG_JournalRRText(OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit()));
      rows[n].lots=(metaLots!="" ? StrToDouble(metaLots) : aggregateLots);
      rows[n].net=aggregateNet;
      string so,sl0,sol,sl1,sp,ss;
      RG_JournalReadLogicalTradeState(ticket,so,sl0,sol,sl1,sp,ss);
      double lotStep=MarketInfo(OrderSymbol(),MODE_LOTSTEP);
      if(lotStep<=0.0) lotStep=0.01;
      rows[n].partialExit=((sp!="" || aggregateFragments>1) ? RG_JournalCheckMark() : "");
      rows[n].slMove=(ss!="" ? RG_JournalCheckMark() : "");
      rows[n].description=RG_JournalGetDescription(ticket);
   }
   return(ArraySize(rows));
}

//====================================================
// ACCOUNT HISTORY STATISTICS / STANDARD KELLY
//
// Account History is the source of truth for closed-trade statistics.
// P is returned as a fraction in [0,1].
// A is Average Win / Average Loss.
// f is the standard Kelly fraction:
//     f = (((A + 1) * P) - 1) / A
//====================================================
int g_RG_JournalCachedHistoryTotal=-1;
int g_RG_JournalCachedTrades=0;
int g_RG_JournalCachedWins=0;
int g_RG_JournalCachedLosses=0;
double g_RG_JournalCachedNet=0.0;
double g_RG_JournalCachedGrossWin=0.0;
double g_RG_JournalCachedGrossLoss=0.0;
double g_RG_JournalCachedP=0.0;
double g_RG_JournalCachedA=0.0;
double g_RG_JournalCachedF=0.0;

// Cached history snapshot used by the optimized account-statistics pass.
// All terminal order selections and metadata-file reads happen once per history
// record; grouping then compares in-memory values instead of repeatedly calling
// OrderSelect and opening metadata files inside nested history scans.
struct RG_JournalStatsItem
{
   int ticket;
   int type;
   string symbol;
   int magic;
   datetime openTime;
   double openPrice;
   datetime closeTime;
   double lots;
   double net;
   bool metaFile;
   bool hasMeta;
   string pattern;
   string trigger;
   string tf;
};

void RG_JournalRefreshAccountStats(bool force=false)
{
   if(!g_RG_JournalReady && !force) return;

   int total=OrdersHistoryTotal();
   if(!force && total==g_RG_JournalCachedHistoryTotal)
      return;

   RG_JournalStatsItem items[];
   ArrayResize(items,total);
   int used=0;
   for(int i=total-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      int typ=OrderType();
      if(!RG_JournalIsMarketType(typ)) continue;

      int ticket=OrderTicket();
      items[used].ticket=ticket;
      items[used].type=typ;
      items[used].symbol=OrderSymbol();
      items[used].magic=OrderMagicNumber();
      items[used].openTime=OrderOpenTime();
      items[used].openPrice=OrderOpenPrice();
      items[used].closeTime=OrderCloseTime();
      items[used].lots=OrderLots();
      items[used].net=OrderProfit()+OrderSwap()+OrderCommission();
      string metaPath=RG_JOURNAL_FOLDER+"\\Meta_"+IntegerToString(ticket)+".csv";
      items[used].metaFile=FileIsExist(metaPath);
      items[used].pattern=""; items[used].trigger=""; items[used].tf="";
      string conditions="",status="",lots="",rr="",flags="";
      items[used].hasMeta=RG_JournalReadMeta(ticket,items[used].pattern,items[used].trigger,
                                             items[used].tf,conditions,status,lots,rr,flags);
      used++;
   }
   ArrayResize(items,used);

   int trades=0,wins=0,losses=0;
   double net=0.0,grossWin=0.0,grossLoss=0.0;
   double pointCache[];
   string symbolCache[];
   int symbolCount=0;

   // Match the established logical-trade rules in memory. Metadata-file checks,
   // metadata reads, and order selection are deliberately outside these loops.
   for(int a=0;a<used;a++)
   {
      bool isFirst=true;
      double point=0.0;
      int symbolSlot=-1;
      for(int sc=0;sc<symbolCount;sc++)
         if(symbolCache[sc]==items[a].symbol) { symbolSlot=sc; break; }
      if(symbolSlot<0)
      {
         symbolSlot=symbolCount++;
         ArrayResize(symbolCache,symbolCount);
         ArrayResize(pointCache,symbolCount);
         symbolCache[symbolSlot]=items[a].symbol;
         pointCache[symbolSlot]=MarketInfo(items[a].symbol,MODE_POINT)*0.5;
      }
      point=pointCache[symbolSlot];

      bool selectedA=((items[a].pattern!="" && items[a].pattern!="NONE") ||
                      (items[a].trigger!="" && items[a].trigger!="NONE"));
      for(int b=0;b<used;b++)
      {
         if(a==b) continue;
         if(items[a].metaFile && items[b].metaFile) continue;
         if(items[b].symbol!=items[a].symbol || items[b].type!=items[a].type ||
            items[b].magic!=items[a].magic || items[b].openTime!=items[a].openTime ||
            MathAbs(items[b].openPrice-items[a].openPrice)>point) continue;

         bool selectedB=((items[b].pattern!="" && items[b].pattern!="NONE") ||
                         (items[b].trigger!="" && items[b].trigger!="NONE"));
         if(items[a].hasMeta && items[b].hasMeta && selectedA && selectedB &&
            (items[a].pattern!=items[b].pattern || items[a].trigger!=items[b].trigger ||
             items[a].tf!=items[b].tf)) continue;

         if(items[b].closeTime<items[a].closeTime ||
            (items[b].closeTime==items[a].closeTime && items[b].ticket<items[a].ticket))
         { isFirst=false; break; }
      }
      if(!isFirst) continue;

      double tradePL=0.0;
      int groupedCount=0;
      for(int c=0;c<used;c++)
      {
         if(c!=a && items[a].metaFile && items[c].metaFile) continue;
         if(items[c].symbol!=items[a].symbol || items[c].type!=items[a].type ||
            items[c].magic!=items[a].magic || items[c].openTime!=items[a].openTime ||
            MathAbs(items[c].openPrice-items[a].openPrice)>point) continue;
         bool selectedC=((items[c].pattern!="" && items[c].pattern!="NONE") ||
                         (items[c].trigger!="" && items[c].trigger!="NONE"));
         if(items[a].hasMeta && items[c].hasMeta && selectedA && selectedC &&
            (items[a].pattern!=items[c].pattern || items[a].trigger!=items[c].trigger ||
             items[a].tf!=items[c].tf)) continue;
         tradePL+=items[c].net;
         groupedCount++;
      }
      if(groupedCount<=0) continue;
      trades++;
      net+=tradePL;
      if(tradePL>0.0) { wins++; grossWin+=tradePL; }
      else if(tradePL<0.0) { losses++; grossLoss+=MathAbs(tradePL); }
   }

   double P=(trades>0 ? (double)wins/(double)trades : 0.0);
   double avgWin=(wins>0 ? grossWin/(double)wins : 0.0);
   double avgLoss=(losses>0 ? grossLoss/(double)losses : 0.0);
   double A=(avgLoss>0.0 ? avgWin/avgLoss : 0.0);
   double f=(A>0.0 ? ((((A+1.0)*P)-1.0)/A) : 0.0);
   if(f<0.0) f=0.0;

   g_RG_JournalCachedHistoryTotal=total;
   g_RG_JournalCachedTrades=trades;
   g_RG_JournalCachedWins=wins;
   g_RG_JournalCachedLosses=losses;
   g_RG_JournalCachedNet=net;
   g_RG_JournalCachedGrossWin=grossWin;
   g_RG_JournalCachedGrossLoss=grossLoss;
   g_RG_JournalCachedP=P;
   g_RG_JournalCachedA=A;
   g_RG_JournalCachedF=f;
}


void RG_JournalGetAccountStats(int &trades,int &wins,int &losses,double &net,double &P,double &A,double &f)
{
   RG_JournalRefreshAccountStats(false);
   trades=g_RG_JournalCachedTrades;
   wins=g_RG_JournalCachedWins;
   losses=g_RG_JournalCachedLosses;
   net=g_RG_JournalCachedNet;
   P=g_RG_JournalCachedP;
   A=g_RG_JournalCachedA;
   f=g_RG_JournalCachedF;
}

datetime RG_JournalGetEarliestHistoryDate()
{
   datetime earliest=0;
   int total=OrdersHistoryTotal();

   for(int i=total-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      if(!RG_JournalIsMarketType(OrderType())) continue;

      datetime ct=OrderCloseTime();
      if(ct<=0) continue;

      if(earliest==0 || ct<earliest)
         earliest=ct;
   }

   return(earliest);
}

void RG_JournalCalculatePAF(datetime fromDate,datetime toDate,double &P,double &A,double &f,int &trades,int &wins)
{
   // Standard Kelly over the requested Account History period.
   // P = Profit Trades / Total Trades (fraction 0..1).
   // A = Average Profit Trade / Average Loss Trade.
   // f = (((A+1) * P) - 1) / A.
   trades=0; wins=0; P=0.0; A=0.0; f=0.0;

   int losses=0;
   double grossWin=0.0,grossLoss=0.0;

   int total=OrdersHistoryTotal();
   for(int i=total-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;

      int typ=OrderType();
      if(!RG_JournalIsMarketType(typ) || !RG_JournalIsFirstTradeFragment(i)) continue;
      double groupedLots=0.0,tradePL=0.0; datetime ct=0; int groupedCount=0;
      if(!RG_JournalAggregateTrade(OrderTicket(),groupedLots,tradePL,ct,groupedCount)) continue;
      if(ct<=0 || ct<fromDate || ct>=toDate+86400) continue;

      trades++;

      if(tradePL>0.0)
      {
         wins++;
         grossWin+=tradePL;
      }
      else if(tradePL<0.0)
      {
         losses++;
         grossLoss+=MathAbs(tradePL);
      }
   }

   if(trades>0)
      P=(double)wins/(double)trades;

   double avgWin=(wins>0 ? grossWin/(double)wins : 0.0);
   double avgLoss=(losses>0 ? grossLoss/(double)losses : 0.0);

   if(avgLoss>0.0)
      A=avgWin/avgLoss;

   if(A>0.0)
      f=((((A+1.0)*P)-1.0)/A);
   if(f<0.0) f=0.0;
}



//====================================================
// JOURNAL REPORTING
// Closed trades only are used for analytical P/A calculations.
// P = 100 * winning closed trades / total closed trades.
// A = gross profit / absolute gross loss.
//====================================================
string RG_JournalReportDate(datetime t){ return(TimeToString(t,TIME_DATE)); }

struct RG_JournalReportMeta
{
   int ticket;
   string symbol;
   string type;
   string pattern;
   string trigger;
   string tf;
   string conditions;
   string session;
   string date;
   string time;
   double lots;
   double entry;
   double sl;
   double tp;
};

int RG_JournalReadOpenMeta(RG_JournalReportMeta &a[])
{
   ArrayResize(a,0);
   int h=FileOpen(RG_JOURNAL_FILE,FILE_CSV|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_ANSI,';');
   if(h==INVALID_HANDLE) return(0);
   while(!FileIsEnding(h))
   {
      string ev=FileReadString(h); if(StringLen(ev)==0 && FileIsEnding(h)) break;
      string ticketS=FileReadString(h); string symbol=FileReadString(h); string type=FileReadString(h);
      string sd=FileReadString(h); string st=FileReadString(h);
      string bo=FileReadString(h); string bc=FileReadString(h);
      string entry=FileReadString(h); string exitp=FileReadString(h);
      string sl=FileReadString(h); string tp=FileReadString(h);
      string lots=FileReadString(h); string risk=FileReadString(h); string rr=FileReadString(h);
      string session=FileReadString(h); string news=FileReadString(h);
      string profit=FileReadString(h); string swap=FileReadString(h); string comm=FileReadString(h);
      string dur=FileReadString(h); string magic=FileReadString(h); string comment=FileReadString(h);
      string day=FileReadString(h); string pattern=FileReadString(h); string trigger=FileReadString(h);
      string reasonTF=FileReadString(h); string conditions=FileReadString(h); string status=FileReadString(h);
      string checklistRR=FileReadString(h); string checklistVol=FileReadString(h); string flags=FileReadString(h);
      if(ev!="OPEN") continue;
      int n=ArraySize(a); ArrayResize(a,n+1);
      a[n].ticket=(int)StrToInteger(ticketS); a[n].symbol=symbol; a[n].type=type;
      a[n].pattern=pattern; a[n].trigger=trigger; a[n].tf=reasonTF; a[n].conditions=conditions;
      a[n].session=session; a[n].date=sd; a[n].time=st; a[n].lots=StrToDouble(lots);
      a[n].entry=StrToDouble(entry); a[n].sl=StrToDouble(sl); a[n].tp=StrToDouble(tp);
   }
   FileClose(h); return(ArraySize(a));
}

int RG_JournalFindReportMeta(RG_JournalReportMeta &a[],int ticket)
{
   for(int i=0;i<ArraySize(a);i++) if(a[i].ticket==ticket) return(i);
   return(-1);
}

bool RG_JournalDateInRange(string dateText,datetime fromDate,datetime toDate)
{
   datetime d=StrToTime(dateText);
   if(d<=0) return(false);
   return(d>=fromDate && d<toDate+86400);
}

bool RG_JournalCalculateReport(datetime fromDate,datetime toDate,int &trades,int &wins,int &losses,double &grossProfit,double &grossLoss,double &net,double &p,double &a)
{
   // Report statistics are derived from MT4 Account History, not Journal.csv.
   // Journal.csv may be incomplete when a trade was not recorded by the EA.
   trades=0; wins=0; losses=0; grossProfit=0.0; grossLoss=0.0; net=0.0; p=0.0; a=0.0;

   int total=OrdersHistoryTotal();
   for(int i=total-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      if(!RG_JournalIsMarketType(OrderType()) || !RG_JournalIsFirstTradeFragment(i)) continue;
      double groupedLots=0.0,pl=0.0; datetime closeTime=0; int groupedCount=0;
      if(!RG_JournalAggregateTrade(OrderTicket(),groupedLots,pl,closeTime,groupedCount)) continue;
      if(closeTime<=0 || closeTime<fromDate || closeTime>=toDate+86400) continue;
      trades++;
      net+=pl;
      if(pl>0.0)
      {
         wins++;
         grossProfit+=pl;
      }
      else if(pl<0.0)
      {
         losses++;
         grossLoss+=MathAbs(pl);
      }
   }

   if(trades>0) p=100.0*(double)wins/(double)trades;
   double avgWin=(wins>0 ? grossProfit/(double)wins : 0.0);
   double avgLoss=(losses>0 ? grossLoss/(double)losses : 0.0);
   if(avgLoss>0.0) a=avgWin/avgLoss;
   return(true);
}

string RG_JournalReportStamp(datetime fromDate,datetime toDate)
{
   return(TimeToString(fromDate,TIME_DATE)+" -> "+TimeToString(toDate,TIME_DATE));
}

string RG_JournalHtmlEscape(string value)
{
   string s=value;
   StringReplace(s,"&","&amp;");
   StringReplace(s,"<","&lt;");
   StringReplace(s,">","&gt;");
   StringReplace(s,"\"","&quot;");
   StringReplace(s,"\r\n","<br>");
   StringReplace(s,"\n","<br>");
   StringReplace(s,"\r","<br>");
   return(s);
}

void RG_JournalHtmlCell(int handle,string value)
{
   FileWriteString(handle,"<td>"+RG_JournalHtmlEscape(value)+"</td>\r\n");
}

bool RG_JournalExportRaw(datetime fromDate,datetime toDate,string &outFile)
{
   g_RG_JournalLastExportError=0; outFile="";
   string folder="RiskGuard\\DOCS";
   FolderCreate("RiskGuard"); FolderCreate(folder);
   string target=folder+"\\RiskGuard_Journal.xls";
   int out=FileOpen(target,FILE_TXT|FILE_WRITE|FILE_UNICODE|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(out==INVALID_HANDLE){ g_RG_JournalLastExportError=GetLastError(); return(false); }
   outFile=target;

   // FIX13: real Excel-compatible HTML worksheet, RTL, borders, and account-history rows.
   FileWriteString(out,"<html xmlns:x=\"urn:schemas-microsoft-com:office:excel\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-16\"><meta name=\"ProgId\" content=\"Excel.Sheet\">");
   FileWriteString(out,"<style>html,body{direction:rtl;}table{border-collapse:collapse;width:100%;direction:rtl;}th,td{border:1px solid #777;padding:5px;vertical-align:middle;text-align:center;white-space:pre-wrap;mso-number-format:'\\@';}th{font-weight:bold;background:#D9EAF7;} .summary td{font-weight:bold;background:#F2F2F2;}</style></head><body dir=\"rtl\">");
   FileWriteString(out,"<xml><x:WorksheetOptions><x:DisplayRightToLeft/></x:WorksheetOptions></xml>");

   int total=0,wins=0,losses=0; double sumWin=0.0,sumLoss=0.0;
   for(int i=OrdersHistoryTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      int typ=OrderType(); if(!RG_JournalIsMarketType(typ) || !RG_JournalIsFirstTradeFragment(i)) continue;
      double groupedLots=0.0,net=0.0; datetime ct=0; int groupedCount=0;
      if(!RG_JournalAggregateTrade(OrderTicket(),groupedLots,net,ct,groupedCount)) continue;
      if(ct<=0 || ct<fromDate || ct>=toDate+86400) continue;
      total++;
      if(net>0.0){wins++;sumWin+=net;}
      else if(net<0.0){losses++;sumLoss+=MathAbs(net);}
   }
   double P=(total>0 ? (double)wins/(double)total : 0.0);
   double avgWin=(wins>0 ? sumWin/(double)wins : 0.0);
   double avgLoss=(losses>0 ? sumLoss/(double)losses : 0.0);
   double A=(avgLoss>0.0 ? avgWin/avgLoss : 0.0);
   double f=(A>0.0 ? ((((A+1.0)*P)-1.0)/A) : 0.0);
   if(f<0.0) f=0.0;

   FileWriteString(out,"<table class=\"summary\"><tr><th>Parameter</th><th>Value</th><th>Formula</th></tr>");
   FileWriteString(out,"<tr><td>A</td><td>"+DoubleToString(A,4)+"</td><td colspan=\"3\">Average Win / Average Loss</td></tr>");
   FileWriteString(out,"<tr><td>P</td><td>"+DoubleToString(P*100.0,2)+"%</td><td colspan=\"3\">Winning Trades / Total Trades</td></tr>");
   FileWriteString(out,"<tr><td>f</td><td>"+DoubleToString(f*100.0,2)+"%</td><td colspan=\"3\">(((A+1) &times; P) &minus; 1) / A</td></tr></table><br>");

   string headers[17]={"Trade #","Date","Symbol","Time","Trade Type","Trade Timeframe","Pattern","Conditions","Trigger","Risk/Reward","Volume","Partial Exit","Take Profit","Stop Loss","Stop Loss Move","Result","Description"};
   FileWriteString(out,"<table><tr>");
   for(int hi=0;hi<17;hi++) FileWriteString(out,"<th>"+RG_JournalHtmlEscape(headers[hi])+"</th>");
   FileWriteString(out,"</tr>");

   for(int i=OrdersHistoryTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      int typ=OrderType(); if(!RG_JournalIsMarketType(typ) || !RG_JournalIsFirstTradeFragment(i)) continue;
      int ticket=OrderTicket();
      double aggregateLots=0.0,aggregateNet=0.0; datetime ct=0; int aggregateFragments=0;
      if(!RG_JournalAggregateTrade(ticket,aggregateLots,aggregateNet,ct,aggregateFragments)) continue;
      if(!OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY)) continue;
      if(ct<=0 || ct<fromDate || ct>=toDate+86400) continue;
      // Snapshot the selected logical trade before metadata/state helpers run;
      // those helpers scan history and change MT4's globally selected order.
      string tradeSymbol=OrderSymbol();
      int tradeType=OrderType();
      datetime tradeOpenTime=OrderOpenTime();
      double tradeOpenPrice=OrderOpenPrice();
      double tradeSL=OrderStopLoss();
      double tradeTP=OrderTakeProfit();
      int tradeDigits=(int)MarketInfo(tradeSymbol,MODE_DIGITS);

      string pattern="",trigger="",tf="",conditions="",status="",metaLots="",metaRR="",flags="";
      RG_JournalReadLogicalTradeMeta(ticket,pattern,trigger,tf,conditions,status,metaLots,metaRR,flags);
      string volume=(metaLots!="" ? metaLots : DoubleToString(aggregateLots,2));
      string rr=(metaRR!="" ? metaRR : RG_JournalRRText(tradeOpenPrice,tradeSL,tradeTP));
      string date=TimeToString(ct,TIME_DATE);
      string tm=TimeToString(ct,TIME_SECONDS);
      string result=DoubleToString(aggregateNet,2);
      string row[17];
      row[0]=IntegerToString(ticket); row[1]=date; row[2]=tradeSymbol; row[3]=tm; row[4]=RG_JournalTypeName(tradeType);
      row[5]=(tf!="" ? tf : "NONE"); row[6]=(pattern!="" ? pattern : "NONE"); row[7]=RG_JournalConditionMark(conditions); row[8]=(trigger!="" ? trigger : "NONE"); row[9]=rr; row[10]=volume; row[11]="";
      row[12]=DoubleToString(tradeTP,tradeDigits); row[13]=DoubleToString(tradeSL,tradeDigits);
      string stateOriginalLots,stateLastLots,stateOriginalSL,stateLastSL,statePartial,stateSLMoves;
      RG_JournalReadLogicalTradeState(ticket,stateOriginalLots,stateLastLots,stateOriginalSL,stateLastSL,statePartial,stateSLMoves);
      double entryLotsForPartial=(metaLots!="" ? StrToDouble(metaLots) : OrderLots());
      double lotStepForPartial=MarketInfo(OrderSymbol(),MODE_LOTSTEP);
      if(lotStepForPartial<=0.0) lotStepForPartial=0.01;
      bool partialDetected=(statePartial!="" || aggregateFragments>1 || entryLotsForPartial>aggregateLots+0.5*lotStepForPartial);
      row[11]=(partialDetected ? RG_JournalCheckMark() : "");
      row[14]=(stateSLMoves!="" ? RG_JournalCheckMark() : "");
      row[15]=result; row[16]=RG_JournalGetDescription(ticket);
      FileWriteString(out,"<tr>");
      for(int ci=0;ci<17;ci++)
      {
         if(ci==7)
            FileWriteString(out,"<td>"+(RG_JournalConditionIsComplete(conditions) ? "&#10003;" : "&#10007;")+"</td>");
         else if(ci==14 && row[ci]==RG_JournalCheckMark())
            FileWriteString(out,"<td>&#10003;</td>");
         else if(ci==11 && row[ci]==RG_JournalCheckMark())
            FileWriteString(out,"<td>&#10003;</td>");
         else FileWriteString(out,"<td>"+RG_JournalHtmlEscape(row[ci])+"</td>");
      }
      FileWriteString(out,"</tr>");
   }
   FileWriteString(out,"</table></body></html>"); FileFlush(out); FileClose(out);
   int verify=FileOpen(target,FILE_TXT|FILE_READ|FILE_UNICODE|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(verify==INVALID_HANDLE){g_RG_JournalLastExportError=GetLastError();return(false);} string first=FileReadString(verify); FileClose(verify);
   if(StringLen(first)==0){g_RG_JournalLastExportError=5002;return(false);}

   // Open the generated .xls (HTML worksheet) in the user's default spreadsheet app.
   // MT4 stores this report under its MQL4\Files directory.
   string fullPath=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files\\"+target;
   int openResult=ShellExecuteW(0,"open",fullPath,"","",1);
   if(openResult<=32) g_RG_JournalLastExportError=openResult;
   return(true);
}

bool RG_JournalExportAnalysis(datetime fromDate,datetime toDate,string &outFile)
{
   string stamp=TimeToString(TimeLocal(),TIME_DATE|TIME_MINUTES|TIME_SECONDS); StringReplace(stamp,".",""); StringReplace(stamp,":",""); StringReplace(stamp," ","_");
   outFile=RG_JOURNAL_FOLDER+"\\Journal_Analysis_"+stamp+".csv";
   int out=FileOpen(outFile,FILE_CSV|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE,';'); if(out==INVALID_HANDLE)return(false);
   int trades,wins,losses; double gp,gl,net,p,a; RG_JournalCalculateReport(fromDate,toDate,trades,wins,losses,gp,gl,net,p,a);
   FileWrite(out,"RISKGUARD JOURNAL ANALYTICAL REPORT"); FileWrite(out,"PERIOD",RG_JournalReportStamp(fromDate,toDate));
   FileWrite(out,"TOTAL TRADES",trades); FileWrite(out,"WINNING",wins); FileWrite(out,"LOSING",losses); FileWrite(out,"P (%)",DoubleToString(p,2)); FileWrite(out,"A",DoubleToString(a,2)); FileWrite(out,"GROSS PROFIT",DoubleToString(gp,2)); FileWrite(out,"GROSS LOSS",DoubleToString(gl,2)); FileWrite(out,"NET",DoubleToString(net,2));
   FileWrite(out,""); FileWrite(out,"TICKET","SYMBOL","TYPE","CLOSE DATE","P/L","PATTERN","TRIGGER","TIMEFRAME","CONDITIONS","SESSION","VOLUME","R/R");
   RG_JournalReportMeta meta[]; RG_JournalReadOpenMeta(meta);
   int h=FileOpen(RG_JOURNAL_FILE,FILE_CSV|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h!=INVALID_HANDLE)
   {
      while(!FileIsEnding(h))
      {
         string ev=FileReadString(h); if(StringLen(ev)==0 && FileIsEnding(h)) break;
         string ticketS=FileReadString(h); string symbol=FileReadString(h); string type=FileReadString(h); string sd=FileReadString(h); string st=FileReadString(h);
         string bo=FileReadString(h); string bc=FileReadString(h); string entry=FileReadString(h); string exitp=FileReadString(h); string sl=FileReadString(h); string tp=FileReadString(h); string lots=FileReadString(h); string risk=FileReadString(h); string rr=FileReadString(h); string session=FileReadString(h); string news=FileReadString(h); string profit=FileReadString(h); string swap=FileReadString(h); string comm=FileReadString(h); string dur=FileReadString(h); string magic=FileReadString(h); string comment=FileReadString(h); string day=FileReadString(h); string pattern=FileReadString(h); string trigger=FileReadString(h); string reasonTF=FileReadString(h); string conditions=FileReadString(h); string status=FileReadString(h); string checklistRR=FileReadString(h); string checklistVol=FileReadString(h); string flags=FileReadString(h);
         if(ev!="CLOSE" || !RG_JournalDateInRange(sd,fromDate,toDate)) continue;
         int ticket=(int)StrToInteger(ticketS), mi=RG_JournalFindReportMeta(meta,ticket); string pat=(mi>=0?meta[mi].pattern:""); string tr=(mi>=0?meta[mi].trigger:""); string tf=(mi>=0?meta[mi].tf:""); string cond=(mi>=0?meta[mi].conditions:""); string vol=(mi>=0?DoubleToString(meta[mi].lots,2):lots);
         FileWrite(out,ticket,symbol,type,sd,profit,pat,tr,tf,cond,session,vol,checklistRR);
      }
      FileClose(h);
   }
   FileClose(out); return(true);
}

#endif
