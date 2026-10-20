#ifndef __RG_LICENSE_MQH__
#define __RG_LICENSE_MQH__

//====================================================
// RiskGuard Simple Private License
// RG065 + per-account expiry
//====================================================


// Comma-separated list of licensed MT4 account numbers.
// Keep this list synchronized with RG_LICENSE_EXPIRIES below.
#define RG_LICENSE_ACCOUNTS "180033829,167004725,167002950"
#define RG_LICENSE_SERVER  ""

// Per-account expiration dates in YYYY.MM.DD format.
// Format: "ACCOUNT=YYYY.MM.DD,ACCOUNT=YYYY.MM.DD"
// IMPORTANT: Replace the sample dates below with the actual agreed expiry
// date for each account before distributing the EA.
// A license is valid through the entire listed calendar day (broker server time).
#define RG_LICENSE_EXPIRIES "180033829=2027.12.31,167004725=2027.12.31,167002950=2030.12.31"

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
// Broker/server allowlist
//====================================================
bool RG_LicenseServerMatches()
{
   // Empty server means the license is valid across brokers.
   if(StringLen(RG_LICENSE_SERVER)<=0)
      return(true);

   return(AccountServer()==RG_LICENSE_SERVER);
}

//====================================================
// Per-account expiry lookup
// Returns false when the account has no valid expiry entry.
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
            if(StringLen(dateText)!=10)
               return(false);

            // StrToTime parses the date in broker/server-time context.
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
          StringLen(RG_LICENSE_EXPIRIES)>0);
}

bool RG_LicenseIsExpired()
{
   datetime expiryEnd=0;
   if(!RG_LicenseGetAccountExpiry(AccountNumber(),expiryEnd))
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

   if(!RG_LicenseServerMatches())
      return(false);

   // Every allowlisted account must have its own valid expiry entry.
   if(!RG_LicenseGetAccountExpiry(AccountNumber(),expiryEnd))
      return(false);

   // Fail closed if broker server time is not available.
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

   if(!RG_LicenseServerMatches())
      return("LICENSE LOCKED - INVALID SERVER");

   datetime expiryEnd=0;
   if(!RG_LicenseGetAccountExpiry(AccountNumber(),expiryEnd))
      return("LICENSE LOCKED - EXPIRY NOT CONFIGURED");

   datetime serverNow=TimeCurrent();
   if(serverNow<=0)
      return("LICENSE LOCKED - SERVER TIME UNAVAILABLE");

   if(serverNow>expiryEnd)
      return("LICENSE EXPIRED - "+TimeToString(expiryEnd,TIME_DATE));

   return("LICENSE ACTIVE - UNTIL "+TimeToString(expiryEnd,TIME_DATE));
}

void RG_LicenseApplyStatus()
{
   RG_MainStatus(RG_LicenseStatus());
}

#endif
