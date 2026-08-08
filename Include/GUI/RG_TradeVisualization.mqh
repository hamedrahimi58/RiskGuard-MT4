#ifndef __RG_TRADE_VISUALIZATION_MQH__
#define __RG_TRADE_VISUALIZATION_MQH__

#include <RG_Settings.mqh>
#include <Core/RG_Defines.mqh>
#include <Trade/RG_TakeProfit.mqh>


//====================================================
// RiskGuard MT4
// SINGLE TP VISUALIZATION V2
//
// Entry  : White ray
// SL     : Red dashed ray
// TP     : Green dashed movable ray
//
// Cleanup:
// - Remove stale objects
// - Remove old ticket objects
// - Keep only active trades
//====================================================


#define RG_TV_PREFIX "RGTV_"
#define RG_TV_FONT   "Arial"


#define RG_TV_ENTRY       "ENTRY_"
#define RG_TV_SL          "SL_"
#define RG_TV_TP          "FINALTP_"

#define RG_TV_ENTRY_LABEL "ENTRY_LABEL_"
#define RG_TV_SL_LABEL    "SL_LABEL_"
#define RG_TV_TP_LABEL    "FINALTP_LABEL_"



//====================================================
// Object Names
//====================================================

string RG_TV_EntryName(int ticket)
{
   return(
      RG_TV_PREFIX+
      RG_TV_ENTRY+
      IntegerToString(ticket)
   );
}


string RG_TV_SLName(int ticket)
{
   return(
      RG_TV_PREFIX+
      RG_TV_SL+
      IntegerToString(ticket)
   );
}


string RG_TV_TPName(int ticket)
{
   return(
      RG_TV_PREFIX+
      RG_TV_TP+
      IntegerToString(ticket)
   );
}



string RG_TV_EntryLabel(int ticket)
{
   return(
      RG_TV_PREFIX+
      RG_TV_ENTRY_LABEL+
      IntegerToString(ticket)
   );
}


string RG_TV_SLLabel(int ticket)
{
   return(
      RG_TV_PREFIX+
      RG_TV_SL_LABEL+
      IntegerToString(ticket)
   );
}


string RG_TV_TPLabel(int ticket)
{
   return(
      RG_TV_PREFIX+
      RG_TV_TP_LABEL+
      IntegerToString(ticket)
   );
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
// Delete Ticket Objects
//====================================================

void RG_TV_DeleteTicketObjects(int ticket)
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
      RG_TV_EntryLabel(ticket));


   RG_TV_DeleteObject(
      RG_TV_SLLabel(ticket));


   RG_TV_DeleteObject(
      RG_TV_TPLabel(ticket));
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
// Create Line
//====================================================

bool RG_TV_CreateLine(
   string name,
   datetime t1,
   datetime t2,
   double price,
   color clr,
   ENUM_LINE_STYLE style,
   int width,
   bool selectable
)
{

   if(price<=0)
      return(false);


   if(ObjectFind(0,name)<0)
   {

      if(!ObjectCreate(
         0,
         name,
         OBJ_TREND,
         0,
         t1,
         price,
         t2,
         price))
      {
         return(false);
      }

   }
   else
   {

      ObjectMove(
         0,
         name,
         0,
         t1,
         price);


      ObjectMove(
         0,
         name,
         1,
         t2,
         price);
   }



   ObjectSetInteger(
      0,
      name,
      OBJPROP_COLOR,
      clr);



   ObjectSetInteger(
      0,
      name,
      OBJPROP_STYLE,
      style);



   ObjectSetInteger(
      0,
      name,
      OBJPROP_WIDTH,
      width);



   // Extend line to chart edge
   ObjectSetInteger(
      0,
      name,
      OBJPROP_RAY_RIGHT,
      true);



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
      OBJPROP_HIDDEN,
      false);



   return(true);
}



//====================================================
// Create Text
//====================================================

bool RG_TV_CreateText(
   string name,
   string text,
   color clr
)
{

   if(ObjectFind(0,name)<0)
   {

      if(!ObjectCreate(
         0,
         name,
         OBJ_TEXT,
         0,
         0,
         0))
      {
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
      9);



   ObjectSetInteger(
      0,
      name,
      OBJPROP_COLOR,
      clr);



   ObjectSetInteger(
      0,
      name,
      OBJPROP_ANCHOR,
      ANCHOR_LEFT);



   ObjectSetInteger(
      0,
      name,
      OBJPROP_SELECTABLE,
      false);



   return(true);
}



//====================================================
// Move Label
//====================================================

void RG_TV_MoveText(
   string name,
   datetime t,
   double price
)
{

   if(ObjectFind(0,name)<0)
      return;


   ObjectMove(
      0,
      name,
      0,
      t,
      price);
}
//====================================================
// Money Calculation
//====================================================

double RG_TV_MoneyAtPrice(
   int ticket,
   double target,
   double lots
)
{

   if(ticket<=0 || target<=0 || lots<=0)
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



   if(tickSize<=0 || tickValue<=0)
      return(0);



   double diff=0;



   if(OrderType()==OP_BUY)
      diff=target-OrderOpenPrice();



   if(OrderType()==OP_SELL)
      diff=OrderOpenPrice()-target;



   return(
      (diff/tickSize)*
      tickValue*
      lots
   );
}



//====================================================
// Draw Entry
//====================================================

void RG_TV_DrawEntry(
   int ticket,
   datetime t1,
   datetime t2
)
{

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return;



   double price=
      OrderOpenPrice();



   RG_TV_CreateLine(
      RG_TV_EntryName(ticket),
      t1,
      t2,
      price,
      clrWhite,
      STYLE_SOLID,
      2,
      false);



   string side="BUY";


   if(OrderType()==OP_SELL)
      side="SELL";



   string txt=
      side+
      " ENTRY "+
      DoubleToString(price,Digits);



   RG_TV_CreateText(
      RG_TV_EntryLabel(ticket),
      txt,
      clrWhite);



   RG_TV_MoveText(
      RG_TV_EntryLabel(ticket),
      t2,
      price);
}



//====================================================
// Draw SL
//====================================================

void RG_TV_DrawSL(
   int ticket,
   datetime t1,
   datetime t2
)
{

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return;



   double price=
      OrderStopLoss();



   if(price<=0)
   {

      RG_TV_DeleteObject(
         RG_TV_SLName(ticket));

      RG_TV_DeleteObject(
         RG_TV_SLLabel(ticket));

      return;
   }



   RG_TV_CreateLine(
      RG_TV_SLName(ticket),
      t1,
      t2,
      price,
      clrRed,
      STYLE_DASH,
      2,
      false);



   string txt=
      "SL "+
      DoubleToString(price,Digits);



   RG_TV_CreateText(
      RG_TV_SLLabel(ticket),
      txt,
      clrRed);



   RG_TV_MoveText(
      RG_TV_SLLabel(ticket),
      t2,
      price);
}



//====================================================
// Draw Final TP
//====================================================

void RG_TV_DrawFinalTP(
   int ticket,
   datetime t1,
   datetime t2
)
{

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return;



   double tp=
      RG_GetTPLevelPrice(ticket);



   if(tp<=0)
   {

      RG_TV_DeleteObject(
         RG_TV_TPName(ticket));

      RG_TV_DeleteObject(
         RG_TV_TPLabel(ticket));

      return;
   }



   RG_TV_CreateLine(
      RG_TV_TPName(ticket),
      t1,
      t2,
      tp,
      clrLime,
      STYLE_DASH,
      2,
      true);



   string txt=
      "FINAL TP "+
      DoubleToString(tp,Digits);



   RG_TV_CreateText(
      RG_TV_TPLabel(ticket),
      txt,
      clrLime);



   RG_TV_MoveText(
      RG_TV_TPLabel(ticket),
      t2,
      tp);
}



//====================================================
// Draw Position
//====================================================

void RG_TV_DrawPosition(
   int ticket
)
{

   if(!OrderSelect(
      ticket,
      SELECT_BY_TICKET))
      return;



   if(OrderSymbol()!=Symbol())
      return;



   if(OrderMagicNumber()!=MagicNumber)
      return;



   datetime t1=
      OrderOpenTime();



   datetime t2=
      RG_TV_CurrentTime();



   RG_TV_DrawEntry(
      ticket,
      t1,
      t2);



   RG_TV_DrawSL(
      ticket,
      t1,
      t2);



   RG_TV_DrawFinalTP(
      ticket,
      t1,
      t2);
}



//====================================================
// Remove Old Objects
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
         continue;



      bool found=false;



      for(int j=OrdersTotal()-1;
          j>=0;
          j--)
      {

         if(!OrderSelect(
            j,
            SELECT_BY_POS,
            MODE_TRADES))
            continue;



         if(OrderSymbol()!=Symbol())
            continue;



         if(OrderMagicNumber()!=MagicNumber)
            continue;



         string tk=
            IntegerToString(
               OrderTicket());



         if(StringFind(
            name,
            tk,
            0)>=0)
         {
            found=true;
            break;
         }
      }



      if(!found)
      {
         ObjectDelete(
            0,
            name);
      }
   }
}



//====================================================
// Process Visualization
//====================================================

void RG_ProcessTradeVisualization()
{

   for(int i=OrdersTotal()-1;
       i>=0;
       i--)
   {

      if(!OrderSelect(
         i,
         SELECT_BY_POS,
         MODE_TRADES))
         continue;



      if(OrderSymbol()!=Symbol())
         continue;



      if(OrderMagicNumber()!=MagicNumber)
         continue;



      if(OrderType()!=OP_BUY &&
         OrderType()!=OP_SELL)
         continue;



      RG_TV_DrawPosition(
         OrderTicket());
   }



   RG_TV_RemoveStaleObjects();


   ChartRedraw();
}



//====================================================
// Delete All
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



//====================================================
// Handle TP Drag
//====================================================

bool RG_TV_HandleTPDrag(
   string objectName
)
{

   if(StringFind(
      objectName,
      RG_TV_TP,
      0)<0)
      return(false);



   int ticket=
      (int)StringToInteger(
         StringSubstr(
            objectName,
            StringLen(
               RG_TV_PREFIX+
               RG_TV_TP)));



   if(ticket<=0)
      return(false);



   double price=
      ObjectGetDouble(
         0,
         objectName,
         OBJPROP_PRICE1);



   if(price<=0)
      return(false);



   return(
      RG_SetManualTPPrice(
         ticket,
         price)
   );
}



#endif