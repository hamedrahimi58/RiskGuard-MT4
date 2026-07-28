#property strict

//====================================================
// Init
//====================================================
int OnInit()
{
   //--------------------------------------------------
   // Panel
   //--------------------------------------------------
   ObjectCreate(0,"PANEL",OBJ_RECTANGLE_LABEL,0,0,0);

   ObjectSetInteger(0,"PANEL",OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,"PANEL",OBJPROP_XDISTANCE,20);
   ObjectSetInteger(0,"PANEL",OBJPROP_YDISTANCE,20);

   ObjectSetInteger(0,"PANEL",OBJPROP_XSIZE,260);
   ObjectSetInteger(0,"PANEL",OBJPROP_YSIZE,120);

   ObjectSetInteger(0,"PANEL",OBJPROP_BGCOLOR,clrBlack);
   ObjectSetInteger(0,"PANEL",OBJPROP_BORDER_COLOR,clrGray);

   //--------------------------------------------------
   // Edit
   //--------------------------------------------------
   ObjectCreate(0,"LOT",OBJ_EDIT,0,0,0);

   ObjectSetInteger(0,"LOT",OBJPROP_CORNER,CORNER_LEFT_UPPER);

   ObjectSetInteger(0,"LOT",OBJPROP_XDISTANCE,40);
   ObjectSetInteger(0,"LOT",OBJPROP_YDISTANCE,50);

   ObjectSetInteger(0,"LOT",OBJPROP_XSIZE,120);
   ObjectSetInteger(0,"LOT",OBJPROP_YSIZE,22);

   ObjectSetInteger(0,"LOT",OBJPROP_BGCOLOR,clrWhite);
   ObjectSetInteger(0,"LOT",OBJPROP_COLOR,clrBlack);

   ObjectSetString(0,"LOT",OBJPROP_TEXT,"0.10");

   //--------------------------------------------------
   // Button
   //--------------------------------------------------
   ObjectCreate(0,"BTN",OBJ_BUTTON,0,0,0);

   ObjectSetInteger(0,"BTN",OBJPROP_CORNER,CORNER_LEFT_UPPER);

   ObjectSetInteger(0,"BTN",OBJPROP_XDISTANCE,180);
   ObjectSetInteger(0,"BTN",OBJPROP_YDISTANCE,48);

   ObjectSetInteger(0,"BTN",OBJPROP_XSIZE,70);
   ObjectSetInteger(0,"BTN",OBJPROP_YSIZE,25);

   ObjectSetString(0,"BTN",OBJPROP_TEXT,"READ");

   ChartRedraw();

   return(INIT_SUCCEEDED);
}

//====================================================
// Deinit
//====================================================
void OnDeinit(const int reason)
{
   ObjectDelete(0,"BTN");
   ObjectDelete(0,"LOT");
   ObjectDelete(0,"PANEL");
}

//====================================================
// Tick
//====================================================
void OnTick()
{
}

//====================================================
// Events
//====================================================
void OnChartEvent(
   const int id,
   const long &lparam,
   const double &dparam,
   const string &sparam)
{
   if(id==CHARTEVENT_OBJECT_CLICK &&
      sparam=="BTN")
   {
      Print("LOT = ",ObjectGetString(0,"LOT",OBJPROP_TEXT));
   }

   if(id==CHARTEVENT_OBJECT_ENDEDIT)
   {
      Print("EDIT : ",sparam);
      Print("VALUE : ",ObjectGetString(0,sparam,OBJPROP_TEXT));
   }
}