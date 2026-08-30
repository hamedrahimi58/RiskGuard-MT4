//+------------------------------------------------------------------+
//| RG_LicensePro.mqh                                                |
//| RiskGuard professional license UI                                |
//| Native Windows input window - isolated from MT4 chart objects    |
//+------------------------------------------------------------------+
#property strict

#include <WinUser32.mqh>

//====================================================
// PRIVATE BUILD SETTINGS
// Fill these three values for a licensed customer build.
//====================================================
#define RG_LICENSE_ACCOUNT 0
#define RG_LICENSE_SERVER  ""
#define RG_LICENSE_KEY     ""

#define RG_LIC_W 430
#define RG_LIC_H 235
#define RG_LIC_EDIT_W 380
#define RG_LIC_EDIT_H 28

#define RG_LIC_STYLE_WS_OVERLAPPED   0x00000000
#define RG_LIC_STYLE_WS_CAPTION      0x00C00000
#define RG_LIC_STYLE_WS_SYSMENU      0x00080000
#define RG_LIC_STYLE_WS_VISIBLE      0x10000000
#define RG_LIC_STYLE_WS_CHILD        0x40000000
#define RG_LIC_STYLE_WS_BORDER       0x00800000
#define RG_LIC_STYLE_ES_AUTOHSCROLL  0x00000080
#define RG_LIC_EX_TOPMOST            0x00000008
#define RG_LIC_SW_SHOW               5
#define RG_LIC_SW_HIDE               0
#define RG_LIC_GW_CHILD              5
#define RG_LIC_GW_HWNDNEXT           2
#define RG_LIC_VK_RETURN             13
#define RG_LIC_VK_ESCAPE             27

#import "user32.dll"
   int CreateWindowExW(int dwExStyle,string lpClassName,string lpWindowName,int dwStyle,int X,int Y,int nWidth,int nHeight,int hWndParent,int hMenu,int hInstance,int lpParam);
   short GetAsyncKeyState(int vKey);
   int SetWindowTextW(int hWnd,string lpString);
   int GetWindowTextW(int hWnd,string lpString,int nMaxCount);
   int SetFocus(int hWnd);
   int ShowWindow(int hWnd,int nCmdShow);
   int DestroyWindow(int hWnd);
   int IsWindow(int hWnd);
   int EnableWindow(int hWnd,int bEnable);
#import

int  g_RG_LicWnd=0;
int  g_RG_LicEdit=0;
int  g_RG_LicStatus=0;
bool g_RG_LicActive=false;
bool g_RG_LicEnterLatch=false;
bool g_RG_LicEscLatch=false;
string g_RG_LicBuffer="";

string RG_LicenseTrim(string s)
{
   StringTrimLeft(s);
   StringTrimRight(s);
   return(s);
}

bool RG_LicenseAuthorized()
{
   if(RG_LICENSE_ACCOUNT<=0 || StringLen(RG_LICENSE_SERVER)==0)
      return(false);

   if(AccountNumber()!=RG_LICENSE_ACCOUNT)
      return(false);

   if(AccountServer()!=RG_LICENSE_SERVER)
      return(false);

   if(StringLen(RG_LICENSE_KEY)>0 && g_RG_LicBuffer!=RG_LICENSE_KEY)
      return(false);

   return(true);
}

void RG_LicenseSetStatus(string text)
{
   if(g_RG_LicStatus>0 && IsWindow(g_RG_LicStatus))
      SetWindowTextW(g_RG_LicStatus,text);
}

void RG_LicenseCloseWindow()
{
   if(g_RG_LicWnd>0 && IsWindow(g_RG_LicWnd))
      DestroyWindow(g_RG_LicWnd);

   g_RG_LicWnd=0;
   g_RG_LicEdit=0;
   g_RG_LicStatus=0;
   g_RG_LicEnterLatch=false;
   g_RG_LicEscLatch=false;
}

void RG_LicenseOpenWindow()
{
   if(g_RG_LicWnd>0 && IsWindow(g_RG_LicWnd))
   {
      ShowWindow(g_RG_LicWnd,RG_LIC_SW_SHOW);
      if(g_RG_LicEdit>0) SetFocus(g_RG_LicEdit);
      return;
   }

   int parent=WindowHandle(Symbol(),Period());
   int style=RG_LIC_STYLE_WS_OVERLAPPED|
             RG_LIC_STYLE_WS_CAPTION|
             RG_LIC_STYLE_WS_SYSMENU|
             RG_LIC_STYLE_WS_VISIBLE;

   g_RG_LicWnd=CreateWindowExW(
      RG_LIC_EX_TOPMOST,
      "STATIC",
      "RiskGuard License",
      style,
      0,0,RG_LIC_W,RG_LIC_H,
      parent,0,0,0
   );

   if(g_RG_LicWnd<=0)
      return;

   // Header
   CreateWindowExW(0,"STATIC","RISKGUARD LICENSE",
      RG_LIC_STYLE_WS_VISIBLE|RG_LIC_STYLE_WS_CHILD,
      20,18,380,28,g_RG_LicWnd,0,0,0);

   string accountText="Account: "+IntegerToString(AccountNumber());
   string serverText="Server: "+AccountServer();

   CreateWindowExW(0,"STATIC",accountText,
      RG_LIC_STYLE_WS_VISIBLE|RG_LIC_STYLE_WS_CHILD,
      20,52,380,22,g_RG_LicWnd,0,0,0);

   CreateWindowExW(0,"STATIC",serverText,
      RG_LIC_STYLE_WS_VISIBLE|RG_LIC_STYLE_WS_CHILD,
      20,75,380,22,g_RG_LicWnd,0,0,0);

   CreateWindowExW(0,"STATIC","License Key",
      RG_LIC_STYLE_WS_VISIBLE|RG_LIC_STYLE_WS_CHILD,
      20,105,380,20,g_RG_LicWnd,0,0,0);

   g_RG_LicEdit=CreateWindowExW(
      0,"EDIT","",
      RG_LIC_STYLE_WS_VISIBLE|RG_LIC_STYLE_WS_CHILD|
      RG_LIC_STYLE_WS_BORDER|RG_LIC_STYLE_ES_AUTOHSCROLL,
      20,128,RG_LIC_EDIT_W,RG_LIC_EDIT_H,
      g_RG_LicWnd,0,0,0
   );

   g_RG_LicStatus=CreateWindowExW(
      0,"STATIC","Enter key and press ENTER",
      RG_LIC_STYLE_WS_VISIBLE|RG_LIC_STYLE_WS_CHILD,
      20,168,380,24,g_RG_LicWnd,0,0,0
   );

   if(g_RG_LicEdit>0)
      SetFocus(g_RG_LicEdit);
}

void RG_LicensePoll()
{
   // Always keep the license decision independent from chart objects.
   if(RG_LicenseAuthorized())
   {
      g_RG_LicActive=true;
      RG_LicenseCloseWindow();
      return;
   }

   g_RG_LicActive=false;

   if(g_RG_LicWnd<=0 || !IsWindow(g_RG_LicWnd))
      RG_LicenseOpenWindow();

   if(g_RG_LicEdit<=0 || !IsWindow(g_RG_LicEdit))
      return;

   bool enter=((GetAsyncKeyState(RG_LIC_VK_RETURN)&0x8000)!=0);
   bool esc=((GetAsyncKeyState(RG_LIC_VK_ESCAPE)&0x8000)!=0);

   if(enter && !g_RG_LicEnterLatch)
   {
      string key="";
      GetWindowTextW(g_RG_LicEdit,key,128);
      g_RG_LicBuffer=RG_LicenseTrim(key);

      if(RG_LicenseAuthorized())
      {
         g_RG_LicActive=true;
         RG_LicenseSetStatus("LICENSE ACTIVE");
         RG_LicenseCloseWindow();
      }
      else
      {
         RG_LicenseSetStatus("INVALID LICENSE / ACCOUNT / SERVER");
      }
   }

   if(esc && !g_RG_LicEscLatch)
      RG_LicenseSetStatus("Activation required - press ENTER");

   g_RG_LicEnterLatch=enter;
   g_RG_LicEscLatch=esc;
}

bool RG_LicenseIsActive()
{
   return(g_RG_LicActive || RG_LicenseAuthorized());
}
