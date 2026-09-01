#ifndef __RG_TRAILING_SETUP_MQH__
#define __RG_TRAILING_SETUP_MQH__

#include <Trade/RG_Trailing.mqh>

#define RG_TS_PREFIX       "RG_TS_"
#define RG_TS_BG           RG_TS_PREFIX+"BG"
#define RG_TS_TITLE        RG_TS_PREFIX+"TITLE"
#define RG_TS_METHOD       RG_TS_PREFIX+"METHOD"
#define RG_TS_START_L     RG_TS_PREFIX+"START_L"
#define RG_TS_START_M      RG_TS_PREFIX+"START_M"
#define RG_TS_START_V      RG_TS_PREFIX+"START_V"
#define RG_TS_START_P      RG_TS_PREFIX+"START_P"
#define RG_TS_START_PLUS   RG_TS_PREFIX+"START_PLUS"
#define RG_TS_DIST_L       RG_TS_PREFIX+"DIST_L"
#define RG_TS_DIST_M       RG_TS_PREFIX+"DIST_M"
#define RG_TS_DIST_V       RG_TS_PREFIX+"DIST_V"
#define RG_TS_DIST_P       RG_TS_PREFIX+"DIST_P"
#define RG_TS_DIST_PLUS    RG_TS_PREFIX+"DIST_PLUS"
#define RG_TS_TF           RG_TS_PREFIX+"TF"
#define RG_TS_TF_L         RG_TS_PREFIX+"TF_L"
#define RG_TS_MAP_M        RG_TS_PREFIX+"MAP_M"
#define RG_TS_MAP_V        RG_TS_PREFIX+"MAP_V"
#define RG_TS_MAP_P        RG_TS_PREFIX+"MAP_P"
#define RG_TS_MA_METHOD    RG_TS_PREFIX+"MA_METHOD"
#define RG_TS_BUFFER       RG_TS_PREFIX+"BUFFER"
#define RG_TS_OK           RG_TS_PREFIX+"OK"
#define RG_TS_CANCEL       RG_TS_PREFIX+"CANCEL"
#define RG_TS_FONT         "Times New Roman"

int g_RG_TS_Ticket=0;
ENUM_RG_TRAILING_METHOD g_RG_TS_Method=RG_TRAILING_DISTANCE;
double g_RG_TS_Start=RG_TR_DEFAULT_START_PIPS;
double g_RG_TS_Distance=RG_TR_DEFAULT_DISTANCE_PIPS;
int g_RG_TS_TF=0;
int g_RG_TS_MAPeriod=RG_TR_DEFAULT_MA_PERIOD;
int g_RG_TS_MAMethod=RG_TR_DEFAULT_MA_METHOD;
bool g_RG_TS_Open=false;

void RG_TS_Delete(string name)
{
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
}

void RG_TrailingSetupClose()
{
   string names[18];
   names[0]=RG_TS_BG; names[1]=RG_TS_TITLE; names[2]=RG_TS_METHOD;
   names[3]=RG_TS_START_L; names[4]=RG_TS_START_M; names[5]=RG_TS_START_V; names[6]=RG_TS_START_P;
   names[7]=RG_TS_DIST_L; names[8]=RG_TS_DIST_M; names[9]=RG_TS_DIST_V; names[10]=RG_TS_DIST_P;
   names[11]=RG_TS_TF; names[12]=RG_TS_TF_L; names[13]=RG_TS_MAP_M;
   names[14]=RG_TS_MAP_V; names[15]=RG_TS_MAP_P; names[16]=RG_TS_MA_METHOD;
   names[17]=RG_TS_BUFFER;
   for(int i=0;i<18;i++) RG_TS_Delete(names[i]);
   RG_TS_Delete(RG_TS_OK); RG_TS_Delete(RG_TS_CANCEL);
   RG_TS_Delete(RG_TS_START_PLUS);
   RG_TS_Delete(RG_TS_DIST_PLUS);
   RG_TS_Delete(RG_TS_METHOD+"_L");
   RG_TS_Delete(RG_TS_MAP_V+"_L");
   RG_TS_Delete(RG_TS_MA_METHOD+"_L");
   g_RG_TS_Open=false;
   g_RG_TS_Ticket=0;
}

bool RG_TS_Button(string name,string text,int x,int y,int w,int h,color bg,color fg)
{
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
   if(!ObjectCreate(0,name,OBJ_BUTTON,0,0,0)) return(false);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,RG_TS_FONT);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,name,OBJPROP_COLOR,fg);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrDimGray);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,65000);
   return(true);
}

bool RG_TS_Label(string name,string text,int x,int y,int w,int h,int size,color fg)
{
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0)) return(false);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,RG_TS_FONT);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetInteger(0,name,OBJPROP_COLOR,fg);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,65001);
   return(true);
}

string RG_TS_MethodText()
{
   return(RG_TrailingMethodName(g_RG_TS_Method));
}

void RG_TS_ClearDynamic()
{
   // Remove all method-specific controls before rebuilding the current view.
   // This prevents stale MA controls/descriptions from remaining when the
   // method changes (especially Fractal after Moving Average).
   RG_TS_Delete(RG_TS_START_L);
   RG_TS_Delete(RG_TS_START_M);
   RG_TS_Delete(RG_TS_START_V);
   RG_TS_Delete(RG_TS_START_P);
   RG_TS_Delete(RG_TS_START_PLUS);
   RG_TS_Delete(RG_TS_DIST_L);
   RG_TS_Delete(RG_TS_DIST_M);
   RG_TS_Delete(RG_TS_DIST_V);
   RG_TS_Delete(RG_TS_DIST_P);
   RG_TS_Delete(RG_TS_DIST_PLUS);
   RG_TS_Delete(RG_TS_TF);
   RG_TS_Delete(RG_TS_TF_L);
   RG_TS_Delete(RG_TS_MAP_M);
   RG_TS_Delete(RG_TS_MAP_V);
   RG_TS_Delete(RG_TS_MAP_V+"_L");
   RG_TS_Delete(RG_TS_MAP_P);
   RG_TS_Delete(RG_TS_MA_METHOD);
   RG_TS_Delete(RG_TS_MA_METHOD+"_L");
   RG_TS_Delete(RG_TS_BUFFER);
   RG_TS_Delete(RG_TS_METHOD+"_L");
}

int RG_TS_HeightForMethod()
{
   if(g_RG_TS_Method==RG_TRAILING_DISTANCE) return(380);
   if(g_RG_TS_Method==RG_TRAILING_CANDLE)   return(420);
   if(g_RG_TS_Method==RG_TRAILING_MOVING)   return(500);
   if(g_RG_TS_Method==RG_TRAILING_FRACTAL)  return(450);
   return(380);
}

void RG_TS_Refresh()
{
   int x=(int)ObjectGetInteger(0,RG_TS_BG,OBJPROP_XDISTANCE);
   int y=(int)ObjectGetInteger(0,RG_TS_BG,OBJPROP_YDISTANCE);
   int w=800;
   int h=RG_TS_HeightForMethod();

   // Keep the requested fixed width/height for the selected method.
   ObjectSetInteger(0,RG_TS_BG,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,RG_TS_BG,OBJPROP_YSIZE,h);

   RG_TS_ClearDynamic();

   // Fixed, generous columns.  Labels never share the area occupied by the
   // numeric controls, so long text cannot enter the window border.
   int lx=x+24;
   int labelW=235;
   int controlX=x+270;
   int controlW=300;
   int valueX=x+380;
   int valueW=70;
   int unitX=x+455;
   int unitW=70;
   int minusX=x+270;
   int plusX=x+w-64;

   string title="TRAILING SETUP | #"+IntegerToString(g_RG_TS_Ticket);
   RG_TS_Label(RG_TS_TITLE,title,lx,y+14,w-48,30,12,clrWhite);

   RG_TS_Label(RG_TS_METHOD+"_L","Trailing method",lx,y+58,labelW,26,10,clrSilver);
   RG_TS_Button(RG_TS_METHOD,RG_TS_MethodText(),controlX,y+53,controlW,34,clrBlack,clrWhite);

   // Common start-after-RF row.
   RG_TS_Label(RG_TS_START_L,"Start after RF (pips)",lx,y+112,labelW,26,10,clrSilver);
   RG_TS_Button(RG_TS_START_M,"-",minusX,y+107,36,34,clrBlack,clrWhite);
   RG_TS_Label(RG_TS_START_V,DoubleToString(g_RG_TS_Start,0),valueX,y+112,valueW,26,10,clrWhite);
   RG_TS_Label(RG_TS_START_P,"pips",unitX,y+112,unitW,26,9,clrSilver);
   RG_TS_Button(RG_TS_START_PLUS,"+",plusX,y+107,36,34,clrBlack,clrWhite);

   if(g_RG_TS_Method==RG_TRAILING_DISTANCE)
   {
      RG_TS_Label(RG_TS_DIST_L,"Trailing distance (pips)",lx,y+166,labelW,26,10,clrSilver);
      RG_TS_Button(RG_TS_DIST_M,"-",minusX,y+161,36,34,clrBlack,clrWhite);
      RG_TS_Label(RG_TS_DIST_V,DoubleToString(g_RG_TS_Distance,0),valueX,y+166,valueW,26,10,clrWhite);
      RG_TS_Label(RG_TS_DIST_P,"pips",unitX,y+166,unitW,26,9,clrSilver);
      RG_TS_Button(RG_TS_DIST_PLUS,"+",plusX,y+161,36,34,clrBlack,clrWhite);
      RG_TS_Label(RG_TS_BUFFER,"SL follows live price at the selected distance",lx,y+220,w-48,26,9,clrSilver);
   }
   else
   {
      RG_TS_Label(RG_TS_TF_L,"Reference timeframe",lx,y+166,labelW,26,10,clrSilver);
      RG_TS_Button(RG_TS_TF,RG_TrailingTimeframeName(g_RG_TS_TF),controlX,y+161,controlW,34,clrBlack,clrWhite);

      if(g_RG_TS_Method==RG_TRAILING_CANDLE)
      {
         RG_TS_Label(RG_TS_BUFFER,"Reference: candle before the last closed candle",lx,y+220,w-48,26,9,clrSilver);
         RG_TS_Label(RG_TS_TF_L,"BUY: Low - 1 pip | SELL: High + 1 pip",lx,y+252,w-48,26,9,clrSilver);
      }
      else if(g_RG_TS_Method==RG_TRAILING_MOVING)
      {
         RG_TS_Label(RG_TS_MAP_V+"_L","MA period",lx,y+220,labelW,26,10,clrSilver);
         RG_TS_Button(RG_TS_MAP_M,"-",minusX,y+215,36,34,clrBlack,clrWhite);
         RG_TS_Label(RG_TS_MAP_V,IntegerToString(g_RG_TS_MAPeriod),valueX,y+220,valueW,26,10,clrWhite);
         RG_TS_Button(RG_TS_MAP_P,"+",plusX,y+215,36,34,clrBlack,clrWhite);

         RG_TS_Label(RG_TS_MA_METHOD+"_L","MA type",lx,y+274,labelW,26,10,clrSilver);
         RG_TS_Button(RG_TS_MA_METHOD,RG_TrailingMAMethodName(g_RG_TS_MAMethod),controlX,y+269,controlW,34,clrBlack,clrWhite);

         RG_TS_Label(RG_TS_BUFFER,"BUY: Close below MA -> SL at Low - 1 pip",lx,y+328,w-48,26,9,clrSilver);
         RG_TS_Label(RG_TS_TF_L,"SELL: Close above MA -> SL at High + 1 pip",lx,y+360,w-48,26,9,clrSilver);
      }
      else if(g_RG_TS_Method==RG_TRAILING_FRACTAL)
      {
         // Fractal has no MA period/type controls.
         RG_TS_Label(RG_TS_BUFFER,"Wait for a confirmed fractal",lx,y+220,w-48,26,9,clrSilver);
         RG_TS_Label(RG_TS_TF_L,"BUY: below confirmed Low | SELL: above confirmed High",lx,y+252,w-48,26,9,clrSilver);
      }
   }

   RG_TS_Button(RG_TS_CANCEL,"CANCEL",x+24,y+h-54,270,36,clrTomato,clrBlack);
   RG_TS_Button(RG_TS_OK,"APPLY & ARM",x+w-294,y+h-54,270,36,clrLime,clrBlack);
   ChartRedraw();
}

bool RG_TrailingSetupOpen(int ticket)
{
   if(ticket<=0) return(false);

   RG_TrailingSetupClose();
   g_RG_TS_Ticket=ticket;
   RG_TrailingGetConfig(ticket,g_RG_TS_Method,g_RG_TS_Start,g_RG_TS_Distance,g_RG_TS_TF,g_RG_TS_MAPeriod,g_RG_TS_MAMethod);
   g_RG_TS_Open=true;

   // Position the modal setup window away from the main panel.
   // Prefer the right side, then left, then below/above as space permits.
   int w=800;
   int h=RG_TS_HeightForMethod();
   int gap=18;
   int chartW=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   int chartH=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);

   int panelW=RG_GUI_GetPanelWidth();
   int panelX=RG_GUI_GetPanelX(panelW);
   int panelY=RG_GUI_GetPanelY();

   int x=panelX+panelW+gap;
   int y=panelY;

   if(chartW>0 && x+w>chartW-5)
      x=panelX-w-gap;

   if(chartW>0 && x<5)
   {
      // If neither side of the panel has room, center the modal window.
      x=(chartW-w)/2;
      if(x<5) x=5;
   }

   if(chartH>0 && y+h>chartH-5)
      y=chartH-h-5;
   if(y<5) y=5;

   if(!ObjectCreate(0,RG_TS_BG,OBJ_RECTANGLE_LABEL,0,0,0)) return(false);
   ObjectSetInteger(0,RG_TS_BG,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,RG_TS_BG,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,RG_TS_BG,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,RG_TS_BG,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,RG_TS_BG,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,RG_TS_BG,OBJPROP_BGCOLOR,C'28,28,28');
   ObjectSetInteger(0,RG_TS_BG,OBJPROP_BORDER_COLOR,clrDimGray);
   ObjectSetInteger(0,RG_TS_BG,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,RG_TS_BG,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,RG_TS_BG,OBJPROP_ZORDER,64999);

   RG_TS_Refresh();
   return(true);
}

void RG_TS_NextMethod()
{
   int m=(int)g_RG_TS_Method+1;
   if(m>3) m=0;
   g_RG_TS_Method=(ENUM_RG_TRAILING_METHOD)m;
}

void RG_TS_NextTF()
{
   int tfs[8]={0,PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1};
   int idx=0;
   for(int i=0;i<8;i++) if(tfs[i]==g_RG_TS_TF) idx=i;
   idx=(idx+1)%8;
   g_RG_TS_TF=tfs[idx];
}

void RG_TS_NextMAMethod()
{
   int methods[4]={MODE_SMA,MODE_EMA,MODE_SMMA,MODE_LWMA};
   int idx=0;
   for(int i=0;i<4;i++) if(methods[i]==g_RG_TS_MAMethod) idx=i;
   idx=(idx+1)%4;
   g_RG_TS_MAMethod=methods[idx];
}

bool RG_TrailingSetupHandleClick(string name)
{
   if(!g_RG_TS_Open) return(false);

   if(name==RG_TS_METHOD)
   {
      RG_TS_NextMethod(); RG_TS_Refresh(); return(true);
   }
   if(name==RG_TS_START_M)
   {
      g_RG_TS_Start=MathMax(0.0,g_RG_TS_Start-10.0); RG_TS_Refresh(); return(true);
   }
   if(name==RG_TS_START_PLUS)
   {
      g_RG_TS_Start+=10.0; RG_TS_Refresh(); return(true);
   }
   if(name==RG_TS_DIST_M)
   {
      g_RG_TS_Distance=MathMax(1.0,g_RG_TS_Distance-10.0); RG_TS_Refresh(); return(true);
   }
   if(name==RG_TS_DIST_PLUS)
   {
      g_RG_TS_Distance+=10.0; RG_TS_Refresh(); return(true);
   }
   if(name==RG_TS_TF)
   {
      RG_TS_NextTF(); RG_TS_Refresh(); return(true);
   }
   if(name==RG_TS_MAP_M)
   {
      g_RG_TS_MAPeriod=MathMax(2,g_RG_TS_MAPeriod-1); RG_TS_Refresh(); return(true);
   }
   if(name==RG_TS_MAP_P)
   {
      g_RG_TS_MAPeriod++; RG_TS_Refresh(); return(true);
   }
   if(name==RG_TS_MA_METHOD)
   {
      RG_TS_NextMAMethod(); RG_TS_Refresh(); return(true);
   }
   if(name==RG_TS_CANCEL)
   {
      RG_TrailingSetupClose(); return(true);
   }
   if(name==RG_TS_OK)
   {
      RG_TrailingSetConfig(g_RG_TS_Ticket,g_RG_TS_Method,g_RG_TS_Start,g_RG_TS_Distance,g_RG_TS_TF,g_RG_TS_MAPeriod,g_RG_TS_MAMethod);
      RG_SetTrailingEnabled(g_RG_TS_Ticket,true);
      RG_TrailingSetupClose();
      return(true);
   }
   return(false);
}

#endif
