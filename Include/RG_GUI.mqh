#ifndef __RG_GUI_MQH__
#define __RG_GUI_MQH__

#include <RG_Settings.mqh>
#include <GUI/RG_Label.mqh>
#include <GUI/RG_Edit.mqh>
#include <Trade/RG_PositionManager.mqh>
#include <Trade/RG_PositionCloser.mqh>
#include <Trade/RG_RiskFree.mqh>

//====================================================
// RiskGuard MT4
// GUI / POSITION ROW ARCHITECTURE
//
// Global BE/RF controls are intentionally removed.
// Each open position receives its own:
//    BE | RF | X
//
// Active position count comes from RG_PositionManager and
// therefore ignores positions already marked RiskFree.
//====================================================

#define RG_GUI_PANEL          RG_PREFIX+"PANEL"
#define RG_GUI_HEADER         RG_PREFIX+"HEADER"
#define RG_GUI_TITLE          RG_PREFIX+"TITLE"
#define RG_GUI_STATUS         RG_PREFIX+"STATUS"
#define RG_GUI_SYMBOL         RG_PREFIX+"SYMBOL"
#define RG_GUI_SPREAD         RG_PREFIX+"SPREAD"
#define RG_GUI_PROFIT         RG_PREFIX+"PROFIT"
#define RG_GUI_LOT_LABEL      RG_PREFIX+"LOT_LABEL"
#define RG_GUI_LOT_INPUT      RG_PREFIX+"LOT_INPUT"
#define RG_GUI_SL_LABEL       RG_PREFIX+"SL_LABEL"
#define RG_GUI_SL_INPUT       RG_PREFIX+"SL_INPUT"
#define RG_GUI_TP_LABEL       RG_PREFIX+"TP_LABEL"
#define RG_GUI_TP_INPUT       RG_PREFIX+"TP_INPUT"
#define RG_GUI_BUY            RG_PREFIX+"BUY"
#define RG_GUI_SELL           RG_PREFIX+"SELL"
#define RG_GUI_CLOSE          RG_PREFIX+"CLOSE_ALL"
#define RG_GUI_TRAILING       RG_PREFIX+"TRAILING"
#define RG_GUI_FOOTER         RG_PREFIX+"FOOTER"
#define RG_GUI_FOOTER_TEXT    RG_PREFIX+"FOOTER_TEXT"
#define RG_GUI_POS_PREFIX     RG_PREFIX+"POS_"
#define RG_GUI_POS_ROW        "ROW_"
#define RG_GUI_POS_TEXT       "TEXT_"
#define RG_GUI_POS_BE         "BE_"
#define RG_GUI_POS_RF         "RF_"
#define RG_GUI_POS_CLOSE      "X_"

#define RG_GUI_BG             C'25,25,25'
#define RG_GUI_HEADER_BG      C'18,18,18'
#define RG_GUI_FOOTER_BG      C'18,18,18'
#define RG_GUI_ROW_BG         C'31,31,31'
#define RG_GUI_ROW_ALT_BG     C'36,36,36'
#define RG_GUI_BORDER         clrDimGray
#define RG_GUI_TEXT           clrWhite
#define RG_GUI_MUTED          clrSilver
#define RG_GUI_GREEN          clrLime
#define RG_GUI_RED            clrTomato
#define RG_GUI_BLUE           clrDodgerBlue
#define RG_GUI_ORANGE         clrOrange
#define RG_GUI_CYAN           clrAqua
#define RG_GUI_YELLOW         clrGold
#define RG_GUI_EDIT_BG        clrBlack
#define RG_GUI_EDIT_TEXT      clrWhite
#define RG_GUI_FONT           "Times New Roman"
#define RG_GUI_TITLE_SIZE     12
#define RG_GUI_TEXT_SIZE      9
#define RG_GUI_STATUS_SIZE    9
#define RG_GUI_BUTTON_SIZE    8
#define RG_GUI_PAD            10
#define RG_GUI_HEADER_H       30
#define RG_GUI_INPUT_W        82
#define RG_GUI_INPUT_H        20
#define RG_GUI_BUTTON_W       92
#define RG_GUI_BUTTON_H       26
#define RG_GUI_ROW_H          38
#define RG_GUI_FOOTER_H       32
#define RG_GUI_Z_PANEL        1000
#define RG_GUI_Z_ROW          1010
#define RG_GUI_Z_TEXT         1020
#define RG_GUI_Z_BUTTON       1030

//====================================================
// Position object names
//====================================================
string RG_GUI_PosName(string kind,int ticket)
{
   return(RG_GUI_POS_PREFIX+kind+IntegerToString(ticket));
}

string RG_GUI_PosRow(int ticket){return(RG_GUI_PosName(RG_GUI_POS_ROW,ticket));}
string RG_GUI_PosText(int ticket){return(RG_GUI_PosName(RG_GUI_POS_TEXT,ticket));}
string RG_GUI_PosBE(int ticket){return(RG_GUI_PosName(RG_GUI_POS_BE,ticket));}
string RG_GUI_PosRF(int ticket){return(RG_GUI_PosName(RG_GUI_POS_RF,ticket));}
string RG_GUI_PosClose(int ticket){return(RG_GUI_PosName(RG_GUI_POS_CLOSE,ticket));}

bool RG_GUI_IsPositionObject(string name,string kind)
{
   return(StringFind(name,RG_GUI_POS_PREFIX+kind,0)==0);
}

int RG_GUI_TicketFromPositionObject(string name,string kind)
{
   string prefix=RG_GUI_POS_PREFIX+kind;
   if(StringFind(name,prefix,0)!=0)
      return(-1);
   string s=StringSubstr(name,StringLen(prefix));
   return((int)StringToInteger(s));
}

//====================================================
// Delete
//====================================================
void RG_GUI_DeleteObject(string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);
}

void RG_GUI_DeletePositionObjects()
{
   for(int i=ObjectsTotal()-1;i>=0;i--)
   {
      string name=ObjectName(i);
      if(StringFind(name,RG_GUI_POS_PREFIX,0)==0)
         ObjectDelete(0,name);
   }
}

void RG_DeletePanel()
{
   RG_GUI_DeletePositionObjects();

   string names[18];
   names[0]=RG_GUI_PANEL;
   names[1]=RG_GUI_HEADER;
   names[2]=RG_GUI_TITLE;
   names[3]=RG_GUI_STATUS;
   names[4]=RG_GUI_SYMBOL;
   names[5]=RG_GUI_SPREAD;
   names[6]=RG_GUI_PROFIT;
   names[7]=RG_GUI_LOT_LABEL;
   names[8]=RG_GUI_LOT_INPUT;
   names[9]=RG_GUI_SL_LABEL;
   names[10]=RG_GUI_SL_INPUT;
   names[11]=RG_GUI_TP_LABEL;
   names[12]=RG_GUI_TP_INPUT;
   names[13]=RG_GUI_BUY;
   names[14]=RG_GUI_SELL;
   names[15]=RG_GUI_CLOSE;
   names[16]=RG_GUI_TRAILING;
   names[17]=RG_GUI_FOOTER;

   for(int i=0;i<18;i++)
      RG_GUI_DeleteObject(names[i]);

   RG_GUI_DeleteObject(RG_GUI_FOOTER_TEXT);
   RG_GUI_DeleteObject(RG_PREFIX+"OPEN_POSITIONS");
   ChartRedraw();
}

//====================================================
// Rectangle
//====================================================
bool RG_GUI_CreateRect(string name,int x,int y,int width,int height,color background,color border,int zorder)
{
   RG_GUI_DeleteObject(name);
   if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0)) return(false);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,background);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,border);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,zorder);
   return(true);
}

//====================================================
// Button
//====================================================
bool RG_GUI_CreateButton(string name,string text,int x,int y,int width,int height,color background,color textColor,int zorder)
{
   RG_GUI_DeleteObject(name);
   if(!ObjectCreate(0,name,OBJ_BUTTON,0,0,0)) return(false);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,RG_GUI_FONT);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,RG_GUI_BUTTON_SIZE);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,background);
   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,RG_GUI_BORDER);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,zorder);
   return(true);
}

//====================================================
// Label
//====================================================
bool RG_GUI_CreateText(string name,string text,int x,int y,color textColor,int fontSize,int zorder)
{
   RG_GUI_DeleteObject(name);
   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0)) return(false);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,RG_GUI_FONT);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,zorder);
   return(true);
}

void RG_GUI_SetText(string name,string text,color textColor)
{
   if(ObjectFind(0,name)<0) return;
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
}

void RG_StatusReady()
{
   RG_GUI_SetText(RG_GUI_STATUS,"●  Status : READY",RG_GUI_GREEN);
}

//====================================================
// Position filter
//====================================================
bool RG_GUI_IsManagedOrder()
{
   return(OrderSymbol()==Symbol() &&
          OrderMagicNumber()==MagicNumber &&
          (OrderType()==OP_BUY || OrderType()==OP_SELL));
}

int RG_GUI_ActivePositionCount()
{
   return(RG_CountOpenPositions());
}

//====================================================
// Position row
//====================================================
void RG_GUI_DrawPositionRow(int ticket,int rowIndex,int x,int y,int width)
{
   if(!OrderSelect(ticket,SELECT_BY_TICKET)) return;
   if(!RG_GUI_IsManagedOrder()) return;

   color rowColor=(rowIndex%2==0 ? RG_GUI_ROW_BG : RG_GUI_ROW_ALT_BG);
   string row=RG_GUI_PosRow(ticket);
   RG_GUI_CreateRect(row,x,y,width,RG_GUI_ROW_H,rowColor,RG_GUI_BORDER,RG_GUI_Z_ROW);

   string side=(OrderType()==OP_BUY ? "BUY" : "SELL");
   double p=OrderProfit()+OrderSwap()+OrderCommission();
   color pColor=(p>=0 ? RG_GUI_GREEN : RG_GUI_RED);
   string rf=(RG_IsRiskFreeDone(ticket) ? " RF" : "");

   string text=side+" #"+IntegerToString(ticket)+
               "  "+DoubleToString(OrderLots(),2)+
               "  "+(p>=0?"+":"-")+"$"+DoubleToString(MathAbs(p),2)+rf;

   RG_GUI_CreateText(RG_GUI_PosText(ticket),text,x+6,y+7,RG_GUI_TEXT,8,RG_GUI_Z_TEXT);

   int bx=x+width-132;
   RG_GUI_CreateButton(RG_GUI_PosBE(ticket),"BE",bx,y+5,38,28,RG_GUI_BLUE,clrWhite,RG_GUI_Z_BUTTON);
   RG_GUI_CreateButton(RG_GUI_PosRF(ticket),"RF",bx+42,y+5,38,28,RG_GUI_CYAN,clrBlack,RG_GUI_Z_BUTTON);
   RG_GUI_CreateButton(RG_GUI_PosClose(ticket),"X",bx+84,y+5,38,28,RG_GUI_ORANGE,clrBlack,RG_GUI_Z_BUTTON);
}

void RG_GUI_UpdatePositionRows(int x,int y,int width,int maxRows)
{
   RG_GUI_DeletePositionObjects();

   int row=0;
   for(int i=OrdersTotal()-1;i>=0 && row<maxRows;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(!RG_GUI_IsManagedOrder()) continue;

      RG_GUI_DrawPositionRow(OrderTicket(),row,x,y+(row*RG_GUI_ROW_H),width);
      row++;
   }
}

//====================================================
// Create Panel
//====================================================
bool RG_CreatePanel()
{
   RG_DeletePanel();

   int x=PanelX;
   int y=PanelY;
   int w=PanelWidth;

   int rows=MaxOpenPositions;
   if(rows<1) rows=1;
   if(rows>8) rows=8;

   int minimumHeight=390+(rows*RG_GUI_ROW_H);
   int h=PanelHeight;
   if(h<minimumHeight) h=minimumHeight;

   if(!RG_GUI_CreateRect(RG_GUI_PANEL,x,y,w,h,RG_GUI_BG,RG_GUI_BORDER,RG_GUI_Z_PANEL)) return(false);
   if(!RG_GUI_CreateRect(RG_GUI_HEADER,x,y,w,RG_GUI_HEADER_H,RG_GUI_HEADER_BG,RG_GUI_BORDER,RG_GUI_Z_PANEL+1)) return(false);

   if(!RG_GUI_CreateText(RG_GUI_TITLE,"RiskGuard MT4",x+RG_GUI_PAD,y+7,RG_GUI_TEXT,RG_GUI_TITLE_SIZE,RG_GUI_Z_TEXT)) return(false);
   if(!RG_GUI_CreateText(RG_GUI_STATUS,"●  Status : READY",x+RG_GUI_PAD,y+38,RG_GUI_GREEN,RG_GUI_STATUS_SIZE,RG_GUI_Z_TEXT)) return(false);
   if(!RG_GUI_CreateText(RG_GUI_SYMBOL,"Symbol : "+Symbol(),x+RG_GUI_PAD,y+60,RG_GUI_TEXT,RG_GUI_TEXT_SIZE,RG_GUI_Z_TEXT)) return(false);
   if(!RG_GUI_CreateText(RG_GUI_SPREAD,"Spread : 0",x+RG_GUI_PAD,y+80,RG_GUI_TEXT,RG_GUI_TEXT_SIZE,RG_GUI_Z_TEXT)) return(false);
   if(!RG_GUI_CreateText(RG_GUI_PROFIT,"Profit : $0.00",x+RG_GUI_PAD,y+100,RG_GUI_GREEN,RG_GUI_TEXT_SIZE,RG_GUI_Z_TEXT)) return(false);

   if(!RG_GUI_CreateText(RG_GUI_LOT_LABEL,"Lot",x+RG_GUI_PAD,y+130,RG_GUI_TEXT,RG_GUI_TEXT_SIZE,RG_GUI_Z_TEXT)) return(false);
   if(!RG_CreateEdit(RG_GUI_LOT_INPUT,DoubleToString(FixedLot,2),x+75,y+126,RG_GUI_INPUT_W,RG_GUI_INPUT_H,RG_GUI_EDIT_BG,RG_GUI_EDIT_TEXT)) return(false);

   if(!RG_GUI_CreateText(RG_GUI_SL_LABEL,"SL",x+RG_GUI_PAD,y+162,RG_GUI_TEXT,RG_GUI_TEXT_SIZE,RG_GUI_Z_TEXT)) return(false);
   if(!RG_CreateEdit(RG_GUI_SL_INPUT,IntegerToString(StopLoss),x+75,y+158,RG_GUI_INPUT_W,RG_GUI_INPUT_H,RG_GUI_EDIT_BG,RG_GUI_EDIT_TEXT)) return(false);

   if(!RG_GUI_CreateText(RG_GUI_TP_LABEL,"TP",x+RG_GUI_PAD,y+194,RG_GUI_TEXT,RG_GUI_TEXT_SIZE,RG_GUI_Z_TEXT)) return(false);
   if(!RG_CreateEdit(RG_GUI_TP_INPUT,IntegerToString(TakeProfit),x+75,y+190,RG_GUI_INPUT_W,RG_GUI_INPUT_H,RG_GUI_EDIT_BG,RG_GUI_EDIT_TEXT)) return(false);

   if(!RG_GUI_CreateButton(RG_GUI_BUY,"▲ BUY",x+175,y+124,RG_GUI_BUTTON_W,RG_GUI_BUTTON_H,RG_GUI_GREEN,clrBlack,RG_GUI_Z_BUTTON)) return(false);
   if(!RG_GUI_CreateButton(RG_GUI_SELL,"▼ SELL",x+175,y+158,RG_GUI_BUTTON_W,RG_GUI_BUTTON_H,RG_GUI_RED,clrWhite,RG_GUI_Z_BUTTON)) return(false);
   if(!RG_GUI_CreateButton(RG_GUI_CLOSE,"✕ CLOSE ALL",x+175,y+192,RG_GUI_BUTTON_W,RG_GUI_BUTTON_H,RG_GUI_ORANGE,clrBlack,RG_GUI_Z_BUTTON)) return(false);
   if(!RG_GUI_CreateButton(RG_GUI_TRAILING,"TR TRAILING",x+175,y+226,RG_GUI_BUTTON_W,RG_GUI_BUTTON_H,RG_GUI_YELLOW,clrBlack,RG_GUI_Z_BUTTON)) return(false);

   int sectionY=y+264;
   if(!RG_GUI_CreateText(RG_PREFIX+"OPEN_POSITIONS","OPEN POSITIONS",x+RG_GUI_PAD,sectionY,RG_GUI_MUTED,8,RG_GUI_Z_TEXT)) return(false);

   int footerY=y+h-RG_GUI_FOOTER_H;
   if(!RG_GUI_CreateRect(RG_GUI_FOOTER,x,footerY,w,RG_GUI_FOOTER_H,RG_GUI_FOOTER_BG,RG_GUI_BORDER,RG_GUI_Z_PANEL+2)) return(false);
   if(!RG_GUI_CreateText(RG_GUI_FOOTER_TEXT,"",x+RG_GUI_PAD,footerY+8,RG_GUI_MUTED,8,RG_GUI_Z_TEXT)) return(false);

   RG_UpdateGUI();
   ChartRedraw();
   return(true);
}

//====================================================
// Footer
//====================================================
void RG_UpdateFooter()
{
   if(ObjectFind(0,RG_GUI_FOOTER_TEXT)<0) return;

   // Display the RiskGuard input MaxLot, not the broker's MODE_MAXLOT.
   double configuredMaxLot=MaxLot;
   if(configuredMaxLot<=0) configuredMaxLot=0;

   int active=RG_GUI_ActivePositionCount();

   string text="Max Lot  "+DoubleToString(configuredMaxLot,2)+
                "   |   Active  "+IntegerToString(active)+"/"+IntegerToString(MaxOpenPositions)+
                "   |   Server  "+TimeToString(TimeCurrent(),TIME_SECONDS);

   RG_GUI_SetText(RG_GUI_FOOTER_TEXT,text,RG_GUI_MUTED);
}

//====================================================
// Market data / rows
//====================================================
void RG_UpdateGUI()
{
   if(ObjectFind(0,RG_GUI_SYMBOL)>=0) RG_GUI_SetText(RG_GUI_SYMBOL,"Symbol : "+Symbol(),RG_GUI_TEXT);

   if(ObjectFind(0,RG_GUI_SPREAD)>=0)
   {
      double spread=(Ask-Bid)/Point;
      RG_GUI_SetText(RG_GUI_SPREAD,"Spread : "+DoubleToString(spread,1),RG_GUI_TEXT);
   }

   double profit=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(!RG_GUI_IsManagedOrder()) continue;
      profit+=OrderProfit()+OrderSwap()+OrderCommission();
   }

   string profitText="Profit : "+(profit>=0?"+$":"-$")+DoubleToString(MathAbs(profit),2);
   RG_GUI_SetText(RG_GUI_PROFIT,profitText,profit>=0?RG_GUI_GREEN:RG_GUI_RED);

   int rows=MaxOpenPositions;
   if(rows<1) rows=1;
   if(rows>8) rows=8;
   RG_GUI_UpdatePositionRows(PanelX+RG_GUI_PAD,PanelY+284,PanelWidth-(2*RG_GUI_PAD),rows);
   RG_UpdateFooter();
   ChartRedraw();
}

void RG_RefreshGUI(){RG_UpdateGUI();ChartRedraw();}

#endif
