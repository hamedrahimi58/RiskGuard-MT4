#ifndef __RG_TRADE_VISUALIZATION_MQH__
#define __RG_TRADE_VISUALIZATION_MQH__

#include <RG_Settings.mqh>
#include <Core/RG_Defines.mqh>
#include <Trade/RG_TakeProfit.mqh>

//====================================================
// RiskGuard Trade Visualization
// RG-029
//
// ENTRY
// SL
// Single TP
//
// TP:
// - Full chart line
// - Draggable
// - Manual price stored in RG_TakeProfit
//
// No Multi TP
// No TP zones
//====================================================

#define RG_TV_PREFIX "RGTV_"
#define RG_TV_FONT   "Times New Roman"
#define RG_TV_FONT_SIZE 8


//====================================================
// Object Names
//====================================================

string RG_TV_EntryName(int ticket)
{
   return(
      RG_TV_PREFIX
      +"ENTRY_"
      +IntegerToString(ticket));
}

string RG_TV_SLName(int ticket)
{
   return(
      RG_TV_PREFIX
      +"SL_"
      +IntegerToString(ticket));
}

string RG_TV_TPName(int ticket)
{
   return(
      RG_TV_PREFIX
      +"TP_"
      +IntegerToString(ticket));
}

string RG_TV_LabelName(
   int ticket,
   string suffix)
{
   return(
      RG_TV_PREFIX
      +suffix
      +"_"
      +IntegerToString(ticket));
}


//====================================================
// Delete Object
//====================================================

void RG_TV_DeleteObject(string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);
}


//====================================================
// Current Time
//====================================================

datetime RG_TV_CurrentTime()
{
   datetime t=TimeCurrent();

   if(t<=0)
      t=TimeLocal();

   return(t);
}


//====================================================
// TP Price
//====================================================

double RG_TV_GetTPPrice(int ticket)
{
   return(
      RG_GetTPPrice(ticket));
}


//====================================================
// Create Trade Line
//====================================================

bool RG_TV_CreateLine(
   string name,
   datetime time1,
   datetime time2,
   double price,
   color lineColor,
   ENUM_LINE_STYLE lineStyle,
   int width,
   bool selectable)
{
   if(price<=0)
      return(false);

   if(time1<=0)
      time1=RG_TV_CurrentTime()-60;

   if(time2<=time1)
      time2=time1+60;

   if(ObjectFind(0,name)<0)
   {
      if(!ObjectCreate(
         0,
         name,
         OBJ_TREND,
         0,
         time1,
         price,
         time2,
         price))
      {
         Print(
            "RG TV line create failed: ",
            name,
            " Error=",
            GetLastError());

         return(false);
      }
   }

   ObjectMove(
      0,
      name,
      0,
      time1,
      price);

   ObjectMove(
      0,
      name,
      1,
      time2,
      price);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_COLOR,
      lineColor);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_STYLE,
      lineStyle);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_WIDTH,
      width);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_RAY_RIGHT,
      false);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_RAY_LEFT,
      false);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_BACK,
      false);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_SELECTABLE,
      selectable);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_SELECTED,
      false);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_HIDDEN,
      true);

   return(true);
}


//====================================================
// Create Right Label
//====================================================

bool RG_TV_CreateRightLabel(
   string name,
   string text,
   double price,
   color textColor)
{
   if(price<=0)
      return(false);

   int x=0;
   int y=0;

   datetime probeTime=
      RG_TV_CurrentTime();

   if(!ChartTimePriceToXY(
      0,
      0,
      probeTime,
      price,
      x,
      y))
   {
      y=0;
   }

   if(y<0)
      y=0;

   int chartHeight=
      (int)ChartGetInteger(
         0,
         CHART_HEIGHT_IN_PIXELS,
         0);

   if(chartHeight>0 &&
      y>chartHeight-12)
   {
      y=chartHeight-12;
   }

   if(ObjectFind(0,name)<0)
   {
      if(!ObjectCreate(
         0,
         name,
         OBJ_LABEL,
         0,
         0,
         0))
      {
         Print(
            "RG TV label create failed: ",
            name,
            " Error=",
            GetLastError());

         return(false);
      }
   }

   ObjectSetString(
      0,
      name,
      OBJPROP_TEXT,
      text);

   ObjectSetString(
      0,
      name,
      OBJPROP_FONT,
      RG_TV_FONT);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_FONTSIZE,
      RG_TV_FONT_SIZE);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_COLOR,
      textColor);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_CORNER,
      CORNER_RIGHT_UPPER);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_ANCHOR,
      ANCHOR_RIGHT);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_XDISTANCE,
      3);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_YDISTANCE,
      y);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_SELECTABLE,
      false);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_SELECTED,
      false);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_HIDDEN,
      true);

   ObjectSetInteger(
      0,
      name,
      OBJPROP_BACK,
      false);

   return(true);
}


//====================================================
// Money P/L
//====================================================

double RG_TV_MoneyAtPrice(
   int ticket,
   double targetPrice,
   double lots)
{
   if(ticket<=0 ||
      targetPrice<=0 ||
      lots<=0)
      return(0);

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return(0);

   double tickSize=
      MarketInfo(
         OrderSymbol(),
         MODE_TICKSIZE);

   double tickValue=
      MarketInfo(
         OrderSymbol(),
         MODE_TICKVALUE);

   if(tickSize<=0 ||
      tickValue<=0)
      return(0);

   double difference=0;

   if(OrderType()==OP_BUY)
   {
      difference=
         targetPrice
         -OrderOpenPrice();
   }
   else
   if(OrderType()==OP_SELL)
   {
      difference=
         OrderOpenPrice()
         -targetPrice;
   }

   return(
      (difference/tickSize)
      *tickValue
      *lots);
}


//====================================================
// Money Text
//====================================================

string RG_TV_MoneyText(double value)
{
   if(value>=0)
   {
      return(
         "+$"
         +DoubleToString(
            value,
            2));
   }

   return(
      "-$"
      +DoubleToString(
         MathAbs(value),
         2));
}


//====================================================
// Entry
//====================================================

void RG_TV_DrawEntry(
   int ticket,
   datetime time1,
   datetime time2)
{
   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return;

   double price=
      OrderOpenPrice();

   if(price<=0)
      return;

   string lineName=
      RG_TV_EntryName(ticket);

   string labelName=
      RG_TV_LabelName(
         ticket,
         "ENTRY_LABEL");

   RG_TV_CreateLine(
      lineName,
      time1,
      time2,
      price,
      clrWhite,
      STYLE_SOLID,
      1,
      false);

   string direction="BUY";

   if(OrderType()==OP_SELL)
      direction="SELL";

   string text=
      direction
      +" ENTRY "
      +DoubleToString(
         price,
         Digits)
      +"  Vol "
      +DoubleToString(
         OrderLots(),
         2);

   RG_TV_CreateRightLabel(
      labelName,
      text,
      price,
      clrWhite);
}


//====================================================
// Stop Loss
//====================================================

void RG_TV_DrawSL(
   int ticket,
   datetime time1,
   datetime time2)
{
   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return;

   double price=
      OrderStopLoss();

   string lineName=
      RG_TV_SLName(ticket);

   string labelName=
      RG_TV_LabelName(
         ticket,
         "SL_LABEL");

   if(price<=0)
   {
      RG_TV_DeleteObject(lineName);
      RG_TV_DeleteObject(labelName);
      return;
   }

   RG_TV_CreateLine(
      lineName,
      time1,
      time2,
      price,
      clrRed,
      STYLE_DASH,
      1,
      false);

   double money=
      RG_TV_MoneyAtPrice(
         ticket,
         price,
         OrderLots());

   string text=
      "SL "
      +DoubleToString(
         price,
         Digits)
      +" "
      +RG_TV_MoneyText(money);

   RG_TV_CreateRightLabel(
      labelName,
      text,
      price,
      clrRed);
}


//====================================================
// Single TP
//====================================================

void RG_TV_DrawTP(
   int ticket,
   datetime time1,
   datetime time2)
{
   string lineName=
      RG_TV_TPName(ticket);

   string labelName=
      RG_TV_LabelName(
         ticket,
         "TP_LABEL");

   if(!UseTakeProfit ||
      !RG_IsTakeProfitEnabled())
   {
      RG_TV_DeleteObject(lineName);
      RG_TV_DeleteObject(labelName);
      return;
   }

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
   {
      RG_TV_DeleteObject(lineName);
      RG_TV_DeleteObject(labelName);
      return;
   }

   double price=
      RG_TV_GetTPPrice(ticket);

   if(price<=0)
   {
      RG_TV_DeleteObject(lineName);
      RG_TV_DeleteObject(labelName);
      return;
   }

   //--------------------------------------------------
   // FINAL TP is draggable
   //--------------------------------------------------

   RG_TV_CreateLine(
      lineName,
      time1,
      time2,
      price,
      clrLime,
      STYLE_DASH,
      2,
      true);

   double money=
      RG_TV_MoneyAtPrice(
         ticket,
         price,
         OrderLots());

   string text=
      "TP "
      +DoubleToString(
         price,
         Digits)
      +" "
      +RG_TV_MoneyText(money)
      +" Vol "
      +DoubleToString(
         OrderLots(),
         2);

   RG_TV_CreateRightLabel(
      labelName,
      text,
      price,
      clrLime);
}


//====================================================
// Position
//====================================================

void RG_TV_DrawPosition(int ticket)
{
   if(ticket<=0)
      return;

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return;

   if(OrderSymbol()!=Symbol())
      return;

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return;

   datetime time1=
      OrderOpenTime();

   datetime time2=
      RG_TV_CurrentTime();

   if(time1<=0)
      time1=time2-60;

   if(time2<=time1)
      time2=time1+60;

   RG_TV_DrawEntry(
      ticket,
      time1,
      time2);

   RG_TV_DrawSL(
      ticket,
      time1,
      time2);

   RG_TV_DrawTP(
      ticket,
      time1,
      time2);
}


//====================================================
// Is Ticket Open
//====================================================

bool RG_TV_IsTicketOpen(int ticket)
{
   if(ticket<=0)
      return(false);

   for(int i=OrdersTotal()-1;
       i>=0;
       i--)
   {
      if(!OrderSelect(
         i,
         SELECT_BY_POS,
         MODE_TRADES))
         continue;

      if(OrderTicket()!=ticket)
         continue;

      if(OrderSymbol()!=Symbol())
         continue;

      if(OrderType()!=OP_BUY &&
         OrderType()!=OP_SELL)
         return(false);

      return(true);
   }

   return(false);
}


//====================================================
// Ticket From Object Name
//====================================================

int RG_TV_GetTicketFromName(string name)
{
   int position=-1;
   int length=StringLen(name);

   for(int i=0;
       i<length;
       i++)
   {
      if(StringGetChar(
         name,
         i)=='_')
      {
         position=i;
      }
   }

   if(position<0)
      return(-1);

   string text=
      StringSubstr(
         name,
         position+1);

   if(StringLen(text)<=0)
      return(-1);

   return(
      StrToInteger(text));
}


//====================================================
// Remove Stale Objects
//====================================================

void RG_TV_RemoveStaleObjects()
{
   for(int i=ObjectsTotal()-1;
       i>=0;
       i--)
   {
      string name=
         ObjectName(i);

      if(StringFind(
         name,
         RG_TV_PREFIX,
         0)!=0)
      {
         continue;
      }

      int ticket=
         RG_TV_GetTicketFromName(name);

      if(ticket<=0)
         continue;

      if(!RG_TV_IsTicketOpen(ticket))
      {
         ObjectDelete(
            0,
            name);
      }
   }
}


//====================================================
// Handle TP Drag
//====================================================

void RG_TV_HandleObjectDrag(
   string objectName)
{
   if(StringFind(
      objectName,
      RG_TV_PREFIX+"TP_",
      0)!=0)
   {
      return;
   }

   int ticket=
      RG_TV_GetTicketFromName(
         objectName);

   if(ticket<=0)
      return;

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return;

   if(OrderSymbol()!=Symbol())
      return;

   if(OrderType()!=OP_BUY &&
      OrderType()!=OP_SELL)
      return;

   double newPrice=
      ObjectGetDouble(
         0,
         objectName,
         OBJPROP_PRICE1);

   if(newPrice<=0)
      return;

   newPrice=
      NormalizeDouble(
         newPrice,
         Digits);

   //--------------------------------------------------
   // IMPORTANT:
   // RG_SetManualTPPrice now accepts:
   // ticket + price
   //--------------------------------------------------

   if(!RG_SetManualTPPrice(
      ticket,
      newPrice))
   {
      Print(
         "RG TP Drag Save Failed. Ticket : ",
         ticket);

      return;
   }

   Print(
      "RG TP Drag Saved. Ticket : ",
      ticket,
      " Price : ",
      DoubleToString(
         newPrice,
         Digits));

   ChartRedraw();
}


//====================================================
// Process Visualization
//====================================================

void RG_ProcessTradeVisualization()
{
   RG_TV_RemoveStaleObjects();

   for(int i=OrdersTotal()-1;
       i>=0;
       i--)
   {
      if(!OrderSelect(
         i,
         SELECT_BY_POS,
         MODE_TRADES))
      {
         continue;
      }

      if(OrderSymbol()!=Symbol())
         continue;

      if(OrderType()!=OP_BUY &&
         OrderType()!=OP_SELL)
      {
         continue;
      }

      RG_TV_DrawPosition(
         OrderTicket());
   }

   RG_TV_RemoveStaleObjects();

   ChartRedraw();
}


//====================================================
// Delete One Position
//====================================================

void RG_TV_DeletePosition(int ticket)
{
   if(ticket<=0)
      return;

   RG_TV_DeleteObject(
      RG_TV_EntryName(ticket));

   RG_TV_DeleteObject(
      RG_TV_SLName(ticket));

   RG_TV_DeleteObject(
      RG_TV_TPName(ticket));

   RG_TV_DeleteObject(
      RG_TV_LabelName(
         ticket,
         "TP_LABEL"));

   RG_TV_DeleteObject(
      RG_TV_LabelName(
         ticket,
         "ENTRY_LABEL"));

   RG_TV_DeleteObject(
      RG_TV_LabelName(
         ticket,
         "SL_LABEL"));
}


//====================================================
// Delete ALL Visualization
//====================================================

void RG_DeleteTradeVisualization()
{
   for(int i=ObjectsTotal()-1;
       i>=0;
       i--)
   {
      string name=
         ObjectName(i);

      if(StringFind(
         name,
         RG_TV_PREFIX,
         0)==0)
      {
         ObjectDelete(
            0,
            name);
      }
   }

   ChartRedraw();
}

#endif