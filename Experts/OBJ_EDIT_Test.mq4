#property strict

int OnInit()
{
   ObjectDelete(0,"TEST_EDIT");

   if(!ObjectCreate(0,"TEST_EDIT",OBJ_EDIT,0,0,0))
   {
      Print("Create Failed : ",GetLastError());
      return(INIT_FAILED);
   }

   ObjectSetInteger(0,"TEST_EDIT",OBJPROP_XDISTANCE,100);
   ObjectSetInteger(0,"TEST_EDIT",OBJPROP_YDISTANCE,100);

   ObjectSetInteger(0,"TEST_EDIT",OBJPROP_XSIZE,180);
   ObjectSetInteger(0,"TEST_EDIT",OBJPROP_YSIZE,22);

   ObjectSetInteger(0,"TEST_EDIT",OBJPROP_BGCOLOR,clrWhite);
   ObjectSetInteger(0,"TEST_EDIT",OBJPROP_COLOR,clrBlack);
   ObjectSetInteger(0,"TEST_EDIT",OBJPROP_BORDER_COLOR,clrBlack);

   ObjectSetString(0,"TEST_EDIT",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"TEST_EDIT",OBJPROP_FONTSIZE,10);

   ObjectSetString(0,"TEST_EDIT",OBJPROP_TEXT,"Hello");

   ObjectSetInteger(0,"TEST_EDIT",OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,"TEST_EDIT",OBJPROP_SELECTED,false);
   ObjectSetInteger(0,"TEST_EDIT",OBJPROP_HIDDEN,false);

   ChartRedraw();

   Print("OBJ_EDIT created");

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   ObjectDelete(0,"TEST_EDIT");
}

void OnTick()
{
}