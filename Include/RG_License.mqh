#ifndef __RG_LICENSE_MQH__
#define __RG_LICENSE_MQH__

//====================================================
// RiskGuard Simple Private License
// Account allowlist + broker-company allowlist + per-account expiry
//====================================================

// Comma-separated licensed MT4 account numbers.
#define RG_LICENSE_ACCOUNTS "180033829,167004725,167002950"

// Exact company names returned by AccountCompany().
// AccountServer() is intentionally NOT used for license validation.
#define RG_LICENSE_BROKERS "Inveslo Trading Ltd"

// Per-account expiration dates in YYYY.MM.DD format.
// An empty value after '=' means NO EXPIRY for that account.
// A license is valid through the entire listed calendar day.
#define RG_LICENSE_EXPIRIES "180033829=2027.12.31,167004725=2027.12.31,167002950="

//====================================================
// Account allowlist
//====================================================
bool RG_LicenseAccountMatches()
{
   string list=RG_LICENSE_ACCOUNTS;
   string current=IntegerToString(AccountNumber());
   int len=StringLen(list);
   int start=0;

   if(len<=0)
      return(false);

   while(start<len)
   {
      int comma=StringFind(list,",",start);
      if(comma<0)
         comma=len;

      string item=StringSubstr(list,start,comma-start);
      StringTrimLeft(item);
      StringTrimRight(item);

      if(item==current)
         return(true);

      start=comma+1;
   }

   return(false);
}

//====================================================
// Broker company allowlist
//====================================================
bool RG_LicenseBrokerMatches()
{
   string list=RG_LICENSE_BROKERS;
   string current=AccountCompany();
   StringTrimLeft(current);
   StringTrimRight(current);

   // Some broker installations return the legal company name with a final
   // period (e.g. "Inveslo Trading Ltd."). Ignore trailing punctuation
   // and compare the normalized company name.
   while(StringLen(current)>0)
   {
      int last=StringLen(current)-1;
      int ch=StringGetCharacter(current,last);
      if(ch=='.' || ch==',' || ch==';' || ch==':')
      {
         current=StringSubstr(current,0,last);
         StringTrimRight(current);
      }
      else
         break;
   }

   int len=StringLen(list);
   int start=0;
   if(len<=0 || StringLen(current)<=0)
      return(false);

   while(start<len)
   {
      int comma=StringFind(list,",",start);
      if(comma<0)
         comma=len;

      string item=StringSubstr(list,start,comma-start);
      StringTrimLeft(item);
      StringTrimRight(item);

      if(item==current)
         return(true);

      start=comma+1;
   }

   return(false);
}

//====================================================
// Per-account expiry lookup
// Returns true when an entry exists.
// expiryEnd=0 means no expiry.
//====================================================
bool RG_LicenseGetAccountExpiry(int account,datetime &expiryEnd)
{
   expiryEnd=0;

   string list=RG_LICENSE_EXPIRIES;
   string current=IntegerToString(account);
   int len=StringLen(list);
   int start=0;

   if(len<=0)
      return(false);

   while(start<len)
   {
      int comma=StringFind(list,",",start);
      if(comma<0)
         comma=len;

      string item=StringSubstr(list,start,comma-start);
      StringTrimLeft(item);
      StringTrimRight(item);

      int equals=StringFind(item,"=");
      if(equals>0)
      {
         string accountText=StringSubstr(item,0,equals);
         string dateText=StringSubstr(item,equals+1);
         StringTrimLeft(accountText);
         StringTrimRight(accountText);
         StringTrimLeft(dateText);
         StringTrimRight(dateText);

         if(accountText==current)
         {
            // Empty expiry is an explicit no-expiry license.
            if(StringLen(dateText)==0)
            {
               expiryEnd=0;
               return(true);
            }

            if(StringLen(dateText)!=10)
               return(false);

            datetime dayStart=StrToTime(dateText+" 00:00");
            if(dayStart<=0)
               return(false);

            // Include the complete expiry date, up to 23:59:59.
            expiryEnd=dayStart+86400-1;
            return(true);
         }
      }

      start=comma+1;
   }

   return(false);
}

bool RG_LicenseIsConfigured()
{
   return(StringLen(RG_LICENSE_ACCOUNTS)>0 &&
          StringLen(RG_LICENSE_BROKERS)>0 &&
          StringLen(RG_LICENSE_EXPIRIES)>0);
}

bool RG_LicenseIsExpired()
{
   datetime expiryEnd=0;
   if(!RG_LicenseGetAccountExpiry(AccountNumber(),expiryEnd))
      return(false);

   // Zero means this account has no expiry.
   if(expiryEnd<=0)
      return(false);

   datetime serverNow=TimeCurrent();
   if(serverNow<=0)
      return(false);

   return(serverNow>expiryEnd);
}

bool RG_LicenseIsValid()
{
   datetime expiryEnd=0;

   if(!RG_LicenseIsConfigured())
      return(false);

   if(!RG_LicenseAccountMatches())
      return(false);

   if(!RG_LicenseBrokerMatches())
      return(false);

   // Each allowlisted account must have an expiry entry; blank means no expiry.
   if(!RG_LicenseGetAccountExpiry(AccountNumber(),expiryEnd))
      return(false);

   // No-expiry accounts do not depend on broker server time being available.
   if(expiryEnd<=0)
      return(true);

   datetime serverNow=TimeCurrent();
   if(serverNow<=0)
      return(false);

   return(serverNow<=expiryEnd);
}

string RG_LicenseStatus()
{
   if(!RG_LicenseIsConfigured())
      return("LICENSE LOCKED - NOT CONFIGURED");

   if(!RG_LicenseAccountMatches())
      return("LICENSE LOCKED - INVALID ACCOUNT");

   if(!RG_LicenseBrokerMatches())
      return("LICENSE LOCKED - INVALID BROKER");

   datetime expiryEnd=0;
   if(!RG_LicenseGetAccountExpiry(AccountNumber(),expiryEnd))
      return("LICENSE LOCKED - EXPIRY NOT CONFIGURED");

   if(expiryEnd<=0)
      return("LICENSE ACTIVE - NO EXPIRY");

   datetime serverNow=TimeCurrent();
   if(serverNow<=0)
      return("LICENSE LOCKED - SERVER TIME UNAVAILABLE");

   if(serverNow>expiryEnd)
      return("LICENSE EXPIRED - "+TimeToString(expiryEnd,TIME_DATE));

   return("LICENSE ACTIVE - UNTIL "+TimeToString(expiryEnd,TIME_DATE));
}

void RG_LicenseApplyStatus()
{
   bool valid=RG_LicenseIsValid();
   string status=RG_LicenseStatus();

   // Preserve the detailed status in the existing status area.
   RG_MainStatus(status);

   if(ObjectFind(0,RG_GUI_PANEL_TOGGLE)>=0)
   {
      // The button remains the full-width clickable header, but its own text
      // is cleared because MT4 centers button text regardless of ALIGN on
      // some builds. Independent labels provide deterministic left alignment.
      ObjectSetString(0,RG_GUI_PANEL_TOGGLE,OBJPROP_TEXT,"");

      string titleLabel="RG_LICENSE_HEADER_TITLE";
      if(ObjectFind(0,titleLabel)<0)
         ObjectCreate(0,titleLabel,OBJ_LABEL,0,0,0);

      string licenseLabel="RG_LICENSE_HEADER_STATUS";
      if(ObjectFind(0,licenseLabel)<0)
         ObjectCreate(0,licenseLabel,OBJ_LABEL,0,0,0);

      long corner=ObjectGetInteger(0,RG_GUI_PANEL_TOGGLE,OBJPROP_CORNER);
      long x=(long)ObjectGetInteger(0,RG_GUI_PANEL_TOGGLE,OBJPROP_XDISTANCE);
      long y=(long)ObjectGetInteger(0,RG_GUI_PANEL_TOGGLE,OBJPROP_YDISTANCE);
      long width=(long)ObjectGetInteger(0,RG_GUI_PANEL_TOGGLE,OBJPROP_XSIZE);

      // Main title: left aligned, larger font, first line.
      ObjectSetInteger(0,titleLabel,OBJPROP_CORNER,corner);
      ObjectSetInteger(0,titleLabel,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0,titleLabel,OBJPROP_XDISTANCE,x+RG_GUI_S(12));
      ObjectSetInteger(0,titleLabel,OBJPROP_YDISTANCE,y+RG_GUI_S(5));
      ObjectSetInteger(0,titleLabel,OBJPROP_FONTSIZE,RG_GUI_FS(15));
      ObjectSetString(0,titleLabel,OBJPROP_FONT,RG_GUI_FONT);
      ObjectSetString(0,titleLabel,OBJPROP_TEXT,
                      g_RG_GUI_PanelExpanded ? "RiskGuard MT4   [ - ]" : "RiskGuard MT4   [ + ]");
      ObjectSetInteger(0,titleLabel,OBJPROP_COLOR,RG_GUI_TEXT);
      ObjectSetInteger(0,titleLabel,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,titleLabel,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,titleLabel,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,titleLabel,OBJPROP_BACK,false);
      ObjectSetInteger(0,titleLabel,OBJPROP_ZORDER,0);

      // Smaller license status: second line, inset from the right and bottom.
      ObjectSetInteger(0,licenseLabel,OBJPROP_CORNER,corner);
      ObjectSetInteger(0,licenseLabel,OBJPROP_ANCHOR,ANCHOR_RIGHT);
      ObjectSetInteger(0,licenseLabel,OBJPROP_XDISTANCE,x+width-RG_GUI_S(18));
      ObjectSetInteger(0,licenseLabel,OBJPROP_YDISTANCE,y+RG_GUI_S(34));
      ObjectSetInteger(0,licenseLabel,OBJPROP_FONTSIZE,RG_GUI_FS(8));
      ObjectSetString(0,licenseLabel,OBJPROP_FONT,RG_GUI_FONT);
      ObjectSetString(0,licenseLabel,OBJPROP_TEXT,valid ? "LICENSE: ACTIVE" : "LICENSE: LOCKED");
      ObjectSetInteger(0,licenseLabel,OBJPROP_COLOR,valid ? RG_GUI_TEXT : RG_GUI_RED);
      ObjectSetInteger(0,licenseLabel,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,licenseLabel,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,licenseLabel,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,licenseLabel,OBJPROP_BACK,false);
      ObjectSetInteger(0,licenseLabel,OBJPROP_ZORDER,0);
   }

   ChartRedraw();
}

#endif
