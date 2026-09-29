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

bool g_RG_JournalReady=false;
bool g_RG_JournalEnabled=true;

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

void RG_JournalAddDefaults()
{
   // Lists are intentionally empty by default. Every trader defines
   // their own Conditions / Patterns / Triggers.
}

void RG_JournalSaveSettings()
{
   int h=FileOpen(RG_JOURNAL_SETTINGS_FILE,FILE_CSV|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h==INVALID_HANDLE) return;
   FileWrite(h,"TYPE","ID","NAME");
   for(int i=0;i<g_RG_JournalConditionCount;i++) FileWrite(h,"C",g_RG_JournalConditions[i].id,g_RG_JournalConditions[i].name);
   for(int j=0;j<g_RG_JournalPatternCount;j++) FileWrite(h,"P",g_RG_JournalPatterns[j].id,g_RG_JournalPatterns[j].name);
   for(int k=0;k<g_RG_JournalTriggerCount;k++) FileWrite(h,"T",g_RG_JournalTriggers[k].id,g_RG_JournalTriggers[k].name);
   FileWrite(h,"E",g_RG_JournalEnabled?1:0,"");
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
      }
      FileClose(h);
   }
   RG_JournalAddDefaults();
   RG_JournalSaveSettings();
}

bool RG_JournalEnabled(){ return(g_RG_JournalEnabled); }
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
   g_RG_JournalPreviewOpen=g_RG_JournalEnabled;
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
string RG_JournalPreviewConditions(){ string s=""; for(int i=0;i<g_RG_JournalConditionCount;i++) if(g_RG_JournalPreviewConditions[i]){if(s!="")s+=" | ";s+=g_RG_JournalConditions[i].name;} if(s=="")s="NONE"; return(s); }
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
   FileWrite(h,RG_JournalJoinSelected(g_RG_JournalPatterns,g_RG_JournalPatternCount,g_RG_JournalPreviewPatterns),RG_JournalJoinSelected(g_RG_JournalTriggers,g_RG_JournalTriggerCount,g_RG_JournalPreviewTriggers),RG_JournalSelectedTFs(),RG_JournalPreviewConditions(),RG_JournalPreviewStatus(),(g_RG_JournalPreviewVolume?DoubleToString(lots,2):""),(g_RG_JournalPreviewRR?RG_JournalRRText(entry,sl,tp):""),RG_JournalPreviewFlags());
   FileClose(h);
}

bool RG_JournalReadMeta(int ticket,string &pattern,string &trigger,string &tf,string &conditions,string &status,string &lots,string &rr,string &flags)
{
   pattern="";trigger="";tf="";conditions="";status="";lots="";rr="";flags="";
   int h=FileOpen(RG_JOURNAL_FOLDER+"\\Meta_"+IntegerToString(ticket)+".csv",FILE_CSV|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h==INVALID_HANDLE)return(false);
   pattern=FileReadString(h); trigger=FileReadString(h); tf=FileReadString(h); conditions=FileReadString(h); status=FileReadString(h); lots=FileReadString(h); rr=FileReadString(h); flags=FileReadString(h); FileClose(h); return(true);
}
void RG_JournalDeleteMeta(int ticket){ string f=RG_JOURNAL_FOLDER+"\\Meta_"+IntegerToString(ticket)+".csv"; if(FileIsExist(f))FileDelete(f); }

void RG_JournalWriteHeader()
{
   int h=FileOpen(RG_JOURNAL_FILE,FILE_CSV|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE,';');
   if(h==INVALID_HANDLE)return;
   if(FileSize(h)==0)
      FileWrite(h,"EVENT","TICKET","SYMBOL","TYPE","SYSTEM_DATE","SYSTEM_TIME","BROKER_OPEN","BROKER_CLOSE","ENTRY","CLOSE","SL","TP","VOLUME","RISK_MONEY","RR","SESSION","NEWS","NET","SWAP","COMMISSION","DURATION_SEC","MAGIC","COMMENT","DAY","PATTERN","TRIGGER","REASON_TF","ENTRY_CONDITIONS","CHECKLIST_STATUS","CHECKLIST_RR","CHECKLIST_VOLUME","CHECKLIST_FLAGS");
   FileClose(h);
}

void RG_JournalAppendOpen(int ticket)
{
   if(ticket<=0||!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)||!RG_JournalIsMarketType(OrderType()))return;
   string key=RG_JournalGV("OPEN_"+IntegerToString(ticket)); if(GlobalVariableCheck(key))return;
   datetime brokerOpen=OrderOpenTime(), systemOpen=RG_JournalBrokerToSystem(brokerOpen);
   string pattern,trigger,tf,conditions,status,metaLots,metaRR,metaFlags; RG_JournalReadMeta(ticket,pattern,trigger,tf,conditions,status,metaLots,metaRR,metaFlags);
   int h=FileOpen(RG_JOURNAL_FILE,FILE_CSV|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE,';'); if(h==INVALID_HANDLE)return;
   FileSeek(h,0,SEEK_END);
   int digits=(int)MarketInfo(OrderSymbol(),MODE_DIGITS);
   FileWrite(h,"OPEN",ticket,OrderSymbol(),RG_JournalTypeName(OrderType()),RG_JournalDate(systemOpen),RG_JournalTime(systemOpen),TimeToString(brokerOpen,TIME_DATE|TIME_SECONDS),"",DoubleToString(OrderOpenPrice(),digits),"",DoubleToString(OrderStopLoss(),digits),DoubleToString(OrderTakeProfit(),digits),DoubleToString(OrderLots(),2),DoubleToString(RG_JournalRiskMoney(OrderSymbol(),OrderOpenPrice(),OrderStopLoss(),OrderLots()),2),DoubleToString(RG_JournalRR(OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit()),2),RG_JournalSession(brokerOpen),"","","","",0,OrderMagicNumber(),OrderComment(),RG_JournalDay(systemOpen),pattern,trigger,tf,conditions,status,metaRR,metaLots,metaFlags);
   FileClose(h); GlobalVariableSet(key,1.0); RG_JournalDeleteMeta(ticket);
}

void RG_JournalAppendClose(int ticket)
{
   if(ticket<=0||!OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY)||!RG_JournalIsMarketType(OrderType()))return;
   string key=RG_JournalGV("CLOSE_"+IntegerToString(ticket)); if(GlobalVariableCheck(key))return;
   datetime brokerClose=OrderCloseTime(), systemClose=RG_JournalBrokerToSystem(brokerClose);
   int h=FileOpen(RG_JOURNAL_FILE,FILE_CSV|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE,';'); if(h==INVALID_HANDLE)return;
   FileSeek(h,0,SEEK_END); int digits=(int)MarketInfo(OrderSymbol(),MODE_DIGITS); double net=OrderProfit()+OrderSwap()+OrderCommission(); long duration=(long)(OrderCloseTime()-OrderOpenTime());
   FileWrite(h,"CLOSE",ticket,OrderSymbol(),RG_JournalTypeName(OrderType()),RG_JournalDate(systemClose),RG_JournalTime(systemClose),TimeToString(OrderOpenTime(),TIME_DATE|TIME_SECONDS),TimeToString(OrderCloseTime(),TIME_DATE|TIME_SECONDS),DoubleToString(OrderOpenPrice(),digits),DoubleToString(OrderClosePrice(),digits),DoubleToString(OrderStopLoss(),digits),DoubleToString(OrderTakeProfit(),digits),DoubleToString(OrderLots(),2),DoubleToString(RG_JournalRiskMoney(OrderSymbol(),OrderOpenPrice(),OrderStopLoss(),OrderLots()),2),DoubleToString(RG_JournalRR(OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit()),2),RG_JournalSession(OrderOpenTime()),"",DoubleToString(net,2),DoubleToString(OrderSwap(),2),DoubleToString(OrderCommission(),2),duration,OrderMagicNumber(),OrderComment(),RG_JournalDay(RG_JournalBrokerToSystem(OrderOpenTime())),"","","","","","","");
   FileClose(h); GlobalVariableSet(key,1.0);
}

void RG_JournalScan()
{
   if(!g_RG_JournalReady||!g_RG_JournalEnabled)return;
   for(int i=OrdersTotal()-1;i>=0;i--){ if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue; if(!RG_JournalIsMarketType(OrderType()))continue; RG_JournalAppendOpen(OrderTicket()); }
   for(int j=OrdersHistoryTotal()-1;j>=0;j--){ if(!OrderSelect(j,SELECT_BY_POS,MODE_HISTORY))continue; if(!RG_JournalIsMarketType(OrderType()))continue; if(GlobalVariableCheck(RG_JournalGV("OPEN_"+IntegerToString(OrderTicket())))&&!GlobalVariableCheck(RG_JournalGV("CLOSE_"+IntegerToString(OrderTicket()))))RG_JournalAppendClose(OrderTicket()); }
}

void RG_JournalInit()
{
   FolderCreate("RiskGuard"); FolderCreate(RG_JOURNAL_FOLDER); RG_JournalLoadSettings(); RG_JournalWriteHeader(); g_RG_JournalReady=true; RG_JournalScan();
}
void RG_JournalUpdate(){ if(!g_RG_JournalReady)return; if(g_RG_JournalEnabled)RG_JournalScan(); }

#endif
